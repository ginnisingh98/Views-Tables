--------------------------------------------------------
--  DDL for Package Body PAY_ETP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETP_DEL" as
/* $Header: pyetprhi.pkb 120.6.12010000.6 2009/07/30 11:56:55 npannamp ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_etp_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
  (p_rec                     in out nocopy pay_etp_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    pay_etp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_element_types_f
    where       element_type_id = p_rec.element_type_id
    and   effective_start_date = p_validation_start_date;
    --
    pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    pay_etp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_element_types_f
    where        element_type_id = p_rec.element_type_id
    and   effective_start_date >= p_validation_start_date;
    --
    pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_etp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column      IN varchar2
                               ,p_pk_value       IN varchar2
			       ,p_datetrack_mode IN varchar2) IS
--
BEGIN
  --
  IF ((hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) AND
     p_datetrack_mode = hr_api.g_zap) THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column      IN varchar2
                               ,p_pk_value       IN number
			       ,p_datetrack_mode IN varchar2) IS
--
BEGIN
  delete_app_ownerships(p_pk_column, to_char(p_pk_value), p_datetrack_mode);
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pay_etp_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_etp_del.dt_delete_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
  (p_rec                     in out nocopy pay_etp_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := pay_etp_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_etp_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.element_type_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
  (p_rec                   in out nocopy pay_etp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
-- Cursor C_Sel1 select comments to be deleted
--
  Cursor C_Sel1 is
    select t1.comment_id
    from   pay_element_types_f t1
    where  t1.comment_id is not null
    and    t1.element_type_id = p_rec.element_type_id
    and    t1.effective_start_date <= p_validation_end_date
    and    t1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   pay_element_types_f t2
            where  t2.comment_id = t1.comment_id
            and    t2.element_type_id = t1.element_type_id
            and   (t2.effective_start_date > p_validation_end_date
            or    t2.effective_end_date   < p_validation_start_date));
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete any possible comments
  --
  For Comm_Del In C_Sel1 Loop
    hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
  End Loop;
  --
  --
  pay_etp_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
  (p_rec                   in pay_etp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
      --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('ELEMENT_TYPE_ID', p_rec.element_type_id, p_datetrack_mode
      );
    --
    pay_etp_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
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
      ,p_effective_start_date_o
      => pay_etp_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_etp_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pay_etp_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_etp_shd.g_old_rec.legislation_code
      ,p_formula_id_o
      => pay_etp_shd.g_old_rec.formula_id
      ,p_input_currency_code_o
      => pay_etp_shd.g_old_rec.input_currency_code
      ,p_output_currency_code_o
      => pay_etp_shd.g_old_rec.output_currency_code
      ,p_classification_id_o
      => pay_etp_shd.g_old_rec.classification_id
      ,p_benefit_classification_id_o
      => pay_etp_shd.g_old_rec.benefit_classification_id
      ,p_additional_entry_allowed_f_o
      => pay_etp_shd.g_old_rec.additional_entry_allowed_flag
      ,p_adjustment_only_flag_o
      => pay_etp_shd.g_old_rec.adjustment_only_flag
      ,p_closed_for_entry_flag_o
      => pay_etp_shd.g_old_rec.closed_for_entry_flag
      ,p_element_name_o
      => pay_etp_shd.g_old_rec.element_name
      ,p_indirect_only_flag_o
      => pay_etp_shd.g_old_rec.indirect_only_flag
      ,p_multiple_entries_allowed_f_o
      => pay_etp_shd.g_old_rec.multiple_entries_allowed_flag
      ,p_multiply_value_flag_o
      => pay_etp_shd.g_old_rec.multiply_value_flag
      ,p_post_termination_rule_o
      => pay_etp_shd.g_old_rec.post_termination_rule
      ,p_process_in_run_flag_o
      => pay_etp_shd.g_old_rec.process_in_run_flag
      ,p_processing_priority_o
      => pay_etp_shd.g_old_rec.processing_priority
      ,p_processing_type_o
      => pay_etp_shd.g_old_rec.processing_type
      ,p_standard_link_flag_o
      => pay_etp_shd.g_old_rec.standard_link_flag
      ,p_comment_id_o
      => pay_etp_shd.g_old_rec.comment_id
      ,p_comments_o
      => pay_etp_shd.g_old_rec.comments
      ,p_description_o
      => pay_etp_shd.g_old_rec.description
      ,p_legislation_subgroup_o
      => pay_etp_shd.g_old_rec.legislation_subgroup
      ,p_qualifying_age_o
      => pay_etp_shd.g_old_rec.qualifying_age
      ,p_qualifying_length_of_servi_o
      => pay_etp_shd.g_old_rec.qualifying_length_of_service
      ,p_qualifying_units_o
      => pay_etp_shd.g_old_rec.qualifying_units
      ,p_reporting_name_o
      => pay_etp_shd.g_old_rec.reporting_name
      ,p_attribute_category_o
      => pay_etp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_etp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_etp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_etp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_etp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_etp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_etp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_etp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_etp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_etp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_etp_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_etp_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_etp_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_etp_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_etp_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_etp_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_etp_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_etp_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_etp_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_etp_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_etp_shd.g_old_rec.attribute20
      ,p_element_information_catego_o
      => pay_etp_shd.g_old_rec.element_information_category
      ,p_element_information1_o
      => pay_etp_shd.g_old_rec.element_information1
      ,p_element_information2_o
      => pay_etp_shd.g_old_rec.element_information2
      ,p_element_information3_o
      => pay_etp_shd.g_old_rec.element_information3
      ,p_element_information4_o
      => pay_etp_shd.g_old_rec.element_information4
      ,p_element_information5_o
      => pay_etp_shd.g_old_rec.element_information5
      ,p_element_information6_o
      => pay_etp_shd.g_old_rec.element_information6
      ,p_element_information7_o
      => pay_etp_shd.g_old_rec.element_information7
      ,p_element_information8_o
      => pay_etp_shd.g_old_rec.element_information8
      ,p_element_information9_o
      => pay_etp_shd.g_old_rec.element_information9
      ,p_element_information10_o
      => pay_etp_shd.g_old_rec.element_information10
      ,p_element_information11_o
      => pay_etp_shd.g_old_rec.element_information11
      ,p_element_information12_o
      => pay_etp_shd.g_old_rec.element_information12
      ,p_element_information13_o
      => pay_etp_shd.g_old_rec.element_information13
      ,p_element_information14_o
      => pay_etp_shd.g_old_rec.element_information14
      ,p_element_information15_o
      => pay_etp_shd.g_old_rec.element_information15
      ,p_element_information16_o
      => pay_etp_shd.g_old_rec.element_information16
      ,p_element_information17_o
      => pay_etp_shd.g_old_rec.element_information17
      ,p_element_information18_o
      => pay_etp_shd.g_old_rec.element_information18
      ,p_element_information19_o
      => pay_etp_shd.g_old_rec.element_information19
      ,p_element_information20_o
      => pay_etp_shd.g_old_rec.element_information20
      ,p_third_party_pay_only_flag_o
      => pay_etp_shd.g_old_rec.third_party_pay_only_flag
      ,p_object_version_number_o
      => pay_etp_shd.g_old_rec.object_version_number
      ,p_iterative_flag_o
      => pay_etp_shd.g_old_rec.iterative_flag
      ,p_iterative_formula_id_o
      => pay_etp_shd.g_old_rec.iterative_formula_id
      ,p_iterative_priority_o
      => pay_etp_shd.g_old_rec.iterative_priority
      ,p_creator_type_o
      => pay_etp_shd.g_old_rec.creator_type
      ,p_retro_summ_ele_id_o
      => pay_etp_shd.g_old_rec.retro_summ_ele_id
      ,p_grossup_flag_o
      => pay_etp_shd.g_old_rec.grossup_flag
      ,p_process_mode_o
      => pay_etp_shd.g_old_rec.process_mode
      ,p_advance_indicator_o
      => pay_etp_shd.g_old_rec.advance_indicator
      ,p_advance_payable_o
      => pay_etp_shd.g_old_rec.advance_payable
      ,p_advance_deduction_o
      => pay_etp_shd.g_old_rec.advance_deduction
      ,p_process_advance_entry_o
      => pay_etp_shd.g_old_rec.process_advance_entry
      ,p_proration_group_id_o
      => pay_etp_shd.g_old_rec.proration_group_id
      ,p_proration_formula_id_o
      => pay_etp_shd.g_old_rec.proration_formula_id
      ,p_recalc_event_group_id_o
      => pay_etp_shd.g_old_rec.recalc_event_group_id
      ,p_once_each_period_flag_o
      => pay_etp_shd.g_old_rec.once_each_period_flag
      ,p_time_definition_type_o
      => pay_etp_shd.g_old_rec.time_definition_type
      ,p_time_definition_id_o
      => pay_etp_shd.g_old_rec.time_definition_id
      ,p_advance_element_type_id_o
      => pay_etp_shd.g_old_rec.advance_element_type_id
      ,p_deduction_element_type_id_o
      => pay_etp_shd.g_old_rec.deduction_element_type_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_TYPES_F'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date 		in     date
  ,p_datetrack_mode 		in     varchar2
  ,p_rec            		in out nocopy pay_etp_shd.g_rec_type
  ,p_balance_feeds_warning	   out nocopy boolean
  ,p_processing_rules_warning      out nocopy boolean
  ) is
--
  l_proc                      varchar2(72) := g_package||'del';
  l_validation_start_date     date;
  l_validation_end_date       date;
  l_object_version_number     pay_element_types_f.object_version_number%type;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_balance_feeds_warning     boolean;

  Cursor c_input_values
  is
    select input_value_id, object_version_number
      from pay_input_values_f
     where element_type_id=p_rec.element_type_id
       and p_effective_date between effective_start_date
       and effective_end_date
     for update;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_element_types_f'
      ,p_base_key_column         => 'element_type_id'
      ,p_base_key_value          => p_rec.element_type_id
      ,p_enforce_foreign_locking => false
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
  --
  -- Cascade delete the child entities
  --
  If p_datetrack_mode = hr_api.g_zap Then
    -- We need to delete the database items for the deleted element
    hrdyndbi.delete_element_type_dict (p_rec.element_type_id);
    --                                                                                                  -- We need to delete any payroll frequency rules for the element
    --
    delete from pay_ele_payroll_freq_rules
    where element_type_id = p_rec.element_type_id;
    --
    -- Delete the child retro component usages.
    --
    pay_retro_comp_usage_internal.delete_child_retro_comp_usages
      (p_effective_date                => p_effective_date
      ,p_element_type_id               => p_rec.element_type_id
      );

    --
    -- Delete from TL table
    --
    pay_ett_del.del_tl(p_rec.element_type_id);
    --
  Elsif p_datetrack_mode = hr_api.g_delete Then
    --                                                                                                  -- We need to remove any payroll frequency rules starting after the new end
    -- date
    --
    delete from pay_ele_payroll_freq_rules
    where element_type_id = p_rec.element_type_id
    and start_date > p_effective_date;
  --
  End If;
  --
  For l_input_values in c_input_values
  Loop
    l_object_version_number := l_input_values.object_version_number;
    --
    pay_ivl_del.del
	(p_effective_date 	 => p_effective_date
	,p_datetrack_mode 	 => p_datetrack_mode
	,p_input_value_id 	 => l_input_values.input_value_id
	,p_object_version_number => l_object_version_number
	,p_effective_start_date  => l_effective_start_date
	,p_effective_end_date 	 => l_effective_end_date
	,p_balance_feeds_warning => l_balance_feeds_warning
	);
	--
  End Loop;
  --
  p_balance_feeds_warning := l_balance_feeds_warning;
  --
  If p_datetrack_mode <> hr_api.g_delete_next_change Then
    --
    ben_benefit_contributions_pkg.parent_deleted
     (p_rec.element_type_id,
      p_datetrack_mode,
      p_effective_date,
      'PAY_ELEMENT_TYPES_F');
    --
    pay_status_rules_pkg.parent_deleted
      (p_rec.element_type_id,
       p_effective_date,
       p_datetrack_mode);
    --
    pay_sub_class_rules_pkg.parent_deleted
      (p_rec.element_type_id,
       p_effective_date,
       l_validation_start_date,
       l_validation_end_date,
       p_datetrack_mode,
       'PAY_ELEMENT_TYPES_F');
    --
    pay_formula_result_rules_pkg.parent_deleted
      ('PAY_ELEMENT_TYPES_F',
       p_rec.element_type_id,
       p_effective_date,
       p_datetrack_mode);
    --
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  pay_etp_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_element_type_id                  => p_rec.element_type_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  p_rec.business_group_id    := pay_etp_shd.g_old_rec.business_group_id;
  p_rec.legislation_code     := pay_etp_shd.g_old_rec.legislation_code;
  p_rec.legislation_subgroup := pay_etp_shd.g_old_rec.legislation_subgroup;
  --
  -- Set the processing_rules_warning parameter
  --
  If (l_validation_end_date = hr_api.g_eot and
      p_datetrack_mode = hr_api.g_delete_next_change) Then
    --
    p_processing_rules_warning := True;
    --
  End If;
  --
  -- Call the supporting delete validate operation
  --
  pay_etp_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_etp_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pay_etp_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pay_etp_del.post_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
End del;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< del >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_element_type_id                  in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ,p_balance_feeds_warning	   	 out nocopy boolean
  ,p_processing_rules_warning  		 out nocopy boolean
  ) is
--
  l_rec         		 pay_etp_shd.g_rec_type;
  l_proc        		 varchar2(72) := g_package||'del';
  l_balance_feeds_warning 	 boolean;
  l_processing_rules_warning	 boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.element_type_id          := p_element_type_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the pay_etp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_etp_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     ,l_balance_feeds_warning
	 ,l_processing_rules_warning
     );
  --
  --
  -- Set the out arguments
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_balance_feeds_warning	     := l_balance_feeds_warning;
  p_processing_rules_warning	     := l_processing_rules_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_etp_del;

/
