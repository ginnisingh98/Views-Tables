--------------------------------------------------------
--  DDL for Package Body PAY_ETP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETP_INS" as
/* $Header: pyetprhi.pkb 120.6.12010000.6 2009/07/30 11:56:55 npannamp ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_etp_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_element_type_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_element_type_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_etp_ins.g_element_type_id_i := p_element_type_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
  (p_rec                     in out nocopy pay_etp_shd.g_rec_type
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
    from   pay_element_types_f t
    where  t.element_type_id       = p_rec.element_type_id
    and    t.effective_start_date =
             pay_etp_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_element_types_f.created_by%TYPE;
  l_creation_date       pay_element_types_f.creation_date%TYPE;
  l_last_update_date    pay_element_types_f.last_update_date%TYPE;
  l_last_updated_by     pay_element_types_f.last_updated_by%TYPE;
  l_last_update_login   pay_element_types_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_element_types_f'
      ,p_base_key_column => 'element_type_id'
      ,p_base_key_value  => p_rec.element_type_id
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
  pay_etp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_element_types_f
  --
  insert into pay_element_types_f
      (element_type_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,legislation_code
      ,formula_id
      ,input_currency_code
      ,output_currency_code
      ,classification_id
      ,benefit_classification_id
      ,additional_entry_allowed_flag
      ,adjustment_only_flag
      ,closed_for_entry_flag
      ,element_name
      ,indirect_only_flag
      ,multiple_entries_allowed_flag
      ,multiply_value_flag
      ,post_termination_rule
      ,process_in_run_flag
      ,processing_priority
      ,processing_type
      ,standard_link_flag
      ,comment_id
      ,description
      ,legislation_subgroup
      ,qualifying_age
      ,qualifying_length_of_service
      ,qualifying_units
      ,reporting_name
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,element_information_category
      ,element_information1
      ,element_information2
      ,element_information3
      ,element_information4
      ,element_information5
      ,element_information6
      ,element_information7
      ,element_information8
      ,element_information9
      ,element_information10
      ,element_information11
      ,element_information12
      ,element_information13
      ,element_information14
      ,element_information15
      ,element_information16
      ,element_information17
      ,element_information18
      ,element_information19
      ,element_information20
      ,third_party_pay_only_flag
      ,object_version_number
      ,iterative_flag
      ,iterative_formula_id
      ,iterative_priority
      ,creator_type
      ,retro_summ_ele_id
      ,grossup_flag
      ,process_mode
      ,advance_indicator
      ,advance_payable
      ,advance_deduction
      ,process_advance_entry
      ,proration_group_id
      ,proration_formula_id
      ,recalc_event_group_id
      ,once_each_period_flag
      ,time_definition_type
      ,time_definition_id
      ,advance_element_type_id
      ,deduction_element_type_id
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.element_type_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.formula_id
    ,p_rec.input_currency_code
    ,p_rec.output_currency_code
    ,p_rec.classification_id
    ,p_rec.benefit_classification_id
    ,p_rec.additional_entry_allowed_flag
    ,p_rec.adjustment_only_flag
    ,p_rec.closed_for_entry_flag
    ,p_rec.element_name
    ,p_rec.indirect_only_flag
    ,p_rec.multiple_entries_allowed_flag
    ,p_rec.multiply_value_flag
    ,p_rec.post_termination_rule
    ,p_rec.process_in_run_flag
    ,p_rec.processing_priority
    ,p_rec.processing_type
    ,p_rec.standard_link_flag
    ,p_rec.comment_id
    ,p_rec.description
    ,p_rec.legislation_subgroup
    ,p_rec.qualifying_age
    ,p_rec.qualifying_length_of_service
    ,p_rec.qualifying_units
    ,p_rec.reporting_name
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.element_information_category
    ,p_rec.element_information1
    ,p_rec.element_information2
    ,p_rec.element_information3
    ,p_rec.element_information4
    ,p_rec.element_information5
    ,p_rec.element_information6
    ,p_rec.element_information7
    ,p_rec.element_information8
    ,p_rec.element_information9
    ,p_rec.element_information10
    ,p_rec.element_information11
    ,p_rec.element_information12
    ,p_rec.element_information13
    ,p_rec.element_information14
    ,p_rec.element_information15
    ,p_rec.element_information16
    ,p_rec.element_information17
    ,p_rec.element_information18
    ,p_rec.element_information19
    ,p_rec.element_information20
    ,p_rec.third_party_pay_only_flag
    ,p_rec.object_version_number
    ,p_rec.iterative_flag
    ,p_rec.iterative_formula_id
    ,p_rec.iterative_priority
    ,p_rec.creator_type
    ,p_rec.retro_summ_ele_id
    ,p_rec.grossup_flag
    ,p_rec.process_mode
    ,p_rec.advance_indicator
    ,p_rec.advance_payable
    ,p_rec.advance_deduction
    ,p_rec.process_advance_entry
    ,p_rec.proration_group_id
    ,p_rec.proration_formula_id
    ,p_rec.recalc_event_group_id
    ,p_rec.once_each_period_flag
    ,p_rec.time_definition_type
    ,p_rec.time_definition_id
    ,p_rec.advance_element_type_id
    ,p_rec.deduction_element_type_id
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_etp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_etp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure inserts a row into the HR_APPLICATION_OWNERSHIPS table
--   when the row handler is called in the appropriate mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column  IN varchar2
                               ,p_pk_value   IN varchar2) IS
--
CURSOR csr_definition IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = hr_startup_data_api_support.g_session_id;
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
     --
     FOR c1 IN csr_definition LOOP
       --
       INSERT INTO hr_application_ownerships
         (key_name
         ,key_value
         ,product_name
         )
       VALUES
         (p_pk_column
         ,fnd_number.number_to_canonical(p_pk_value)
         ,c1.product_short_name
         );
     END LOOP;
  END IF;
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  create_app_ownerships(p_pk_column, to_char(p_pk_value));
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pay_etp_shd.g_rec_type
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
  pay_etp_ins.dt_insert_dml
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
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                   in out nocopy pay_etp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pay_element_types_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pay_element_types_f
     where element_type_id =
             pay_etp_ins.g_element_type_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pay_etp_ins.g_element_type_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pay_element_types_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.element_type_id :=
      pay_etp_ins.g_element_type_id_i;
    pay_etp_ins.g_element_type_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.element_type_id;
    Close C_Sel1;
  End If;
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null) then
    hr_comm_api.ins
      (p_comment_id        => p_rec.comment_id
      ,p_source_table_name => 'PAY_ELEMENT_TYPES_F'
      ,p_comment_text      => p_rec.comments
      );
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
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
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                   in pay_etp_shd.g_rec_type
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
    -- insert ownerships if applicable
    create_app_ownerships
      ('ELEMENT_TYPE_ID', p_rec.element_type_id
      );
    --
    --
    pay_etp_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_formula_id
      => p_rec.formula_id
      ,p_input_currency_code
      => p_rec.input_currency_code
      ,p_output_currency_code
      => p_rec.output_currency_code
      ,p_classification_id
      => p_rec.classification_id
      ,p_benefit_classification_id
      => p_rec.benefit_classification_id
      ,p_additional_entry_allowed_fla
      => p_rec.additional_entry_allowed_flag
      ,p_adjustment_only_flag
      => p_rec.adjustment_only_flag
      ,p_closed_for_entry_flag
      => p_rec.closed_for_entry_flag
      ,p_element_name
      => p_rec.element_name
      ,p_indirect_only_flag
      => p_rec.indirect_only_flag
      ,p_multiple_entries_allowed_fla
      => p_rec.multiple_entries_allowed_flag
      ,p_multiply_value_flag
      => p_rec.multiply_value_flag
      ,p_post_termination_rule
      => p_rec.post_termination_rule
      ,p_process_in_run_flag
      => p_rec.process_in_run_flag
      ,p_processing_priority
      => p_rec.processing_priority
      ,p_processing_type
      => p_rec.processing_type
      ,p_standard_link_flag
      => p_rec.standard_link_flag
      ,p_comment_id
      => p_rec.comment_id
      ,p_comments
      => p_rec.comments
      ,p_description
      => p_rec.description
      ,p_legislation_subgroup
      => p_rec.legislation_subgroup
      ,p_qualifying_age
      => p_rec.qualifying_age
      ,p_qualifying_length_of_service
      => p_rec.qualifying_length_of_service
      ,p_qualifying_units
      => p_rec.qualifying_units
      ,p_reporting_name
      => p_rec.reporting_name
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_element_information_category
      => p_rec.element_information_category
      ,p_element_information1
      => p_rec.element_information1
      ,p_element_information2
      => p_rec.element_information2
      ,p_element_information3
      => p_rec.element_information3
      ,p_element_information4
      => p_rec.element_information4
      ,p_element_information5
      => p_rec.element_information5
      ,p_element_information6
      => p_rec.element_information6
      ,p_element_information7
      => p_rec.element_information7
      ,p_element_information8
      => p_rec.element_information8
      ,p_element_information9
      => p_rec.element_information9
      ,p_element_information10
      => p_rec.element_information10
      ,p_element_information11
      => p_rec.element_information11
      ,p_element_information12
      => p_rec.element_information12
      ,p_element_information13
      => p_rec.element_information13
      ,p_element_information14
      => p_rec.element_information14
      ,p_element_information15
      => p_rec.element_information15
      ,p_element_information16
      => p_rec.element_information16
      ,p_element_information17
      => p_rec.element_information17
      ,p_element_information18
      => p_rec.element_information18
      ,p_element_information19
      => p_rec.element_information19
      ,p_element_information20
      => p_rec.element_information20
      ,p_third_party_pay_only_flag
      => p_rec.third_party_pay_only_flag
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_iterative_flag
      => p_rec.iterative_flag
      ,p_iterative_formula_id
      => p_rec.iterative_formula_id
      ,p_iterative_priority
      => p_rec.iterative_priority
      ,p_creator_type
      => p_rec.creator_type
      ,p_retro_summ_ele_id
      => p_rec.retro_summ_ele_id
      ,p_grossup_flag
      => p_rec.grossup_flag
      ,p_process_mode
      => p_rec.process_mode
      ,p_advance_indicator
      => p_rec.advance_indicator
      ,p_advance_payable
      => p_rec.advance_payable
      ,p_advance_deduction
      => p_rec.advance_deduction
      ,p_process_advance_entry
      => p_rec.process_advance_entry
      ,p_proration_group_id
      => p_rec.proration_group_id
      ,p_proration_formula_id
      => p_rec.proration_formula_id
      ,p_recalc_event_group_id
      => p_rec.recalc_event_group_id
      ,p_once_each_period_flag
      => p_rec.once_each_period_flag
      ,p_time_definition_type
      => p_rec.time_definition_type
      ,p_time_definition_id
      => p_rec.time_definition_id
      ,p_advance_element_type_id
      => p_rec.advance_element_type_id
      ,p_deduction_element_type_id
      => p_rec.deduction_element_type_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_TYPES_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in pay_etp_shd.g_rec_type
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
    ,p_base_table_name         => 'pay_element_types_f'
    ,p_base_key_column         => 'element_type_id'
    ,p_base_key_value          => p_rec.element_type_id
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
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date 			 in     date
  ,p_rec            			 in out nocopy pay_etp_shd.g_rec_type
  ,p_processing_priority_warning            out nocopy boolean
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
  l_processing_priority_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  pay_etp_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pay_etp_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    ,p_processing_priority_warning => l_processing_priority_warning
    );
  --
  p_processing_priority_warning := l_processing_priority_warning;
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_etp_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pay_etp_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pay_etp_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_classification_id              in     number
  ,p_additional_entry_allowed_fla   in     varchar2
  ,p_adjustment_only_flag           in     varchar2
  ,p_closed_for_entry_flag          in     varchar2
  ,p_element_name                   in     varchar2
  ,p_indirect_only_flag             in     varchar2
  ,p_multiple_entries_allowed_fla   in     varchar2
  ,p_multiply_value_flag            in     varchar2
  ,p_post_termination_rule          in     varchar2
  ,p_process_in_run_flag            in     varchar2
  ,p_processing_priority            in     number
  ,p_processing_type                in     varchar2
  ,p_standard_link_flag             in     varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_formula_id                     in     number   default null
  ,p_input_currency_code            in     varchar2 default null
  ,p_output_currency_code           in     varchar2 default null
  ,p_benefit_classification_id      in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_legislation_subgroup           in     varchar2 default null
  ,p_qualifying_age                 in     number   default null
  ,p_qualifying_length_of_service   in     number   default null
  ,p_qualifying_units               in     varchar2 default null
  ,p_reporting_name                 in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_element_information_category   in     varchar2 default null
  ,p_element_information1           in     varchar2 default null
  ,p_element_information2           in     varchar2 default null
  ,p_element_information3           in     varchar2 default null
  ,p_element_information4           in     varchar2 default null
  ,p_element_information5           in     varchar2 default null
  ,p_element_information6           in     varchar2 default null
  ,p_element_information7           in     varchar2 default null
  ,p_element_information8           in     varchar2 default null
  ,p_element_information9           in     varchar2 default null
  ,p_element_information10          in     varchar2 default null
  ,p_element_information11          in     varchar2 default null
  ,p_element_information12          in     varchar2 default null
  ,p_element_information13          in     varchar2 default null
  ,p_element_information14          in     varchar2 default null
  ,p_element_information15          in     varchar2 default null
  ,p_element_information16          in     varchar2 default null
  ,p_element_information17          in     varchar2 default null
  ,p_element_information18          in     varchar2 default null
  ,p_element_information19          in     varchar2 default null
  ,p_element_information20          in     varchar2 default null
  ,p_third_party_pay_only_flag      in     varchar2 default null
  ,p_iterative_flag                 in     varchar2 default null
  ,p_iterative_formula_id           in     number   default null
  ,p_iterative_priority             in     number   default null
  ,p_creator_type                   in     varchar2 default null
  ,p_retro_summ_ele_id              in     number   default null
  ,p_grossup_flag                   in     varchar2 default null
  ,p_process_mode                   in     varchar2 default null
  ,p_advance_indicator              in     varchar2 default null
  ,p_advance_payable                in     varchar2 default null
  ,p_advance_deduction              in     varchar2 default null
  ,p_process_advance_entry          in     varchar2 default null
  ,p_proration_group_id             in     number   default null
  ,p_proration_formula_id           in     number   default null
  ,p_recalc_event_group_id          in     number   default null
  ,p_once_each_period_flag          in     varchar2 default 'N'
  ,p_time_definition_type           in     varchar2 default null
  ,p_time_definition_id             in     number   default null
  ,p_advance_element_type_id	    in     number default null
  ,p_deduction_element_type_id	    in     number default null
  ,p_element_type_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_comment_id                        out nocopy number
  ,p_processing_priority_warning       out nocopy boolean
  ) is
--
  l_rec         				pay_etp_shd.g_rec_type;
  l_proc        				varchar2(72) := g_package||'ins';
  l_processing_priority_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_etp_shd.convert_args
    (null
    ,null
    ,null
    ,p_business_group_id
    ,p_legislation_code
    ,p_formula_id
    ,p_input_currency_code
    ,p_output_currency_code
    ,p_classification_id
    ,p_benefit_classification_id
    ,p_additional_entry_allowed_fla
    ,p_adjustment_only_flag
    ,p_closed_for_entry_flag
    ,p_element_name
    ,p_indirect_only_flag
    ,p_multiple_entries_allowed_fla
    ,p_multiply_value_flag
    ,p_post_termination_rule
    ,p_process_in_run_flag
    ,p_processing_priority
    ,p_processing_type
    ,p_standard_link_flag
    ,null
    ,p_comments
    ,p_description
    ,p_legislation_subgroup
    ,p_qualifying_age
    ,p_qualifying_length_of_service
    ,p_qualifying_units
    ,p_reporting_name
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_element_information_category
    ,p_element_information1
    ,p_element_information2
    ,p_element_information3
    ,p_element_information4
    ,p_element_information5
    ,p_element_information6
    ,p_element_information7
    ,p_element_information8
    ,p_element_information9
    ,p_element_information10
    ,p_element_information11
    ,p_element_information12
    ,p_element_information13
    ,p_element_information14
    ,p_element_information15
    ,p_element_information16
    ,p_element_information17
    ,p_element_information18
    ,p_element_information19
    ,p_element_information20
    ,p_third_party_pay_only_flag
    ,null
    ,p_iterative_flag
    ,p_iterative_formula_id
    ,p_iterative_priority
    ,p_creator_type
    ,p_retro_summ_ele_id
    ,p_grossup_flag
    ,p_process_mode
    ,p_advance_indicator
    ,p_advance_payable
    ,p_advance_deduction
    ,p_process_advance_entry
    ,p_proration_group_id
    ,p_proration_formula_id
    ,p_recalc_event_group_id
    ,p_once_each_period_flag
    ,p_time_definition_type
    ,p_time_definition_id
    ,p_advance_element_type_id
    ,p_deduction_element_type_id
    );
  --
  -- Having converted the arguments into the pay_etp_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_etp_ins.ins
    (p_effective_date
    ,l_rec
    ,l_processing_priority_warning
    );
  --
  -- Set the OUT arguments.
  --
  p_element_type_id                  := l_rec.element_type_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  p_comment_id                       := l_rec.comment_id;
  p_processing_priority_warning	     := l_processing_priority_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_etp_ins;

/
