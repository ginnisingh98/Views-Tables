--------------------------------------------------------
--  DDL for Package Body PQP_AAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAT_UPD" as
/* $Header: pqaatrhi.pkb 120.2.12010000.3 2009/07/01 10:58:37 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package  varchar2(33) := '  pqp_aat_upd.';  -- Global package name
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< dt_update_dml >-----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure dt_update_dml
  (p_rec                   in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = hr_api.g_correction) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'pqp_assignment_attributes_f'
        ,p_base_key_column => 'assignment_attribute_id'
        ,p_base_key_value  => p_rec.assignment_attribute_id
        );
    --
    pqp_aat_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pqp_assignment_attributes_f Row
    --
    update  pqp_assignment_attributes_f
    set
     assignment_attribute_id              = p_rec.assignment_attribute_id
    ,business_group_id                    = p_rec.business_group_id
    ,assignment_id                        = p_rec.assignment_id
    ,contract_type                        = p_rec.contract_type
    ,work_pattern                         = p_rec.work_pattern
    ,start_day                            = p_rec.start_day
    ,object_version_number                = p_rec.object_version_number
    ,primary_company_car                  = p_rec.primary_company_car
    ,primary_car_fuel_benefit             = p_rec.primary_car_fuel_benefit
    ,primary_class_1a                     = p_rec.primary_class_1a
    ,primary_capital_contribution         = p_rec.primary_capital_contribution
    ,primary_private_contribution         = p_rec.primary_private_contribution
    ,secondary_company_car                = p_rec.secondary_company_car
    ,secondary_car_fuel_benefit           = p_rec.secondary_car_fuel_benefit
    ,secondary_class_1a                   = p_rec.secondary_class_1a
    ,secondary_capital_contribution       = p_rec.secondary_capital_contribution
    ,secondary_private_contribution       = p_rec.secondary_private_contribution
    ,company_car_calc_method              = p_rec.company_car_calc_method
    ,company_car_rates_table_id           = p_rec.company_car_rates_table_id
    ,company_car_secondary_table_id       = p_rec.company_car_secondary_table_id
    ,private_car                          = p_rec.private_car
    ,private_car_calc_method              = p_rec.private_car_calc_method
    ,private_car_rates_table_id           = p_rec.private_car_rates_table_id
    ,private_car_essential_table_id       = p_rec.private_car_essential_table_id
    ,tp_is_teacher                        = p_rec.tp_is_teacher
    ,tp_headteacher_grp_code   = p_rec.tp_headteacher_grp_code --added for head Teacher seconded location for salary scale calculation
    ,tp_safeguarded_grade                 = p_rec.tp_safeguarded_grade
    ,tp_safeguarded_grade_id              = p_rec.tp_safeguarded_grade_id
    ,tp_safeguarded_rate_type             = p_rec.tp_safeguarded_rate_type
    ,tp_safeguarded_rate_id               = p_rec.tp_safeguarded_rate_id
    ,tp_safeguarded_spinal_point_id       = p_rec.tp_safeguarded_spinal_point_id
    ,tp_elected_pension                   = p_rec.tp_elected_pension
    ,tp_fast_track                        = p_rec.tp_fast_track
    ,aat_attribute_category               = p_rec.aat_attribute_category
    ,aat_attribute1                       = p_rec.aat_attribute1
    ,aat_attribute2                       = p_rec.aat_attribute2
    ,aat_attribute3                       = p_rec.aat_attribute3
    ,aat_attribute4                       = p_rec.aat_attribute4
    ,aat_attribute5                       = p_rec.aat_attribute5
    ,aat_attribute6                       = p_rec.aat_attribute6
    ,aat_attribute7                       = p_rec.aat_attribute7
    ,aat_attribute8                       = p_rec.aat_attribute8
    ,aat_attribute9                       = p_rec.aat_attribute9
    ,aat_attribute10                      = p_rec.aat_attribute10
    ,aat_attribute11                      = p_rec.aat_attribute11
    ,aat_attribute12                      = p_rec.aat_attribute12
    ,aat_attribute13                      = p_rec.aat_attribute13
    ,aat_attribute14                      = p_rec.aat_attribute14
    ,aat_attribute15                      = p_rec.aat_attribute15
    ,aat_attribute16                      = p_rec.aat_attribute16
    ,aat_attribute17                      = p_rec.aat_attribute17
    ,aat_attribute18                      = p_rec.aat_attribute18
    ,aat_attribute19                      = p_rec.aat_attribute19
    ,aat_attribute20                      = p_rec.aat_attribute20
    ,aat_information_category             = p_rec.aat_information_category
    ,aat_information1                     = p_rec.aat_information1
    ,aat_information2                     = p_rec.aat_information2
    ,aat_information3                     = p_rec.aat_information3
    ,aat_information4                     = p_rec.aat_information4
    ,aat_information5                     = p_rec.aat_information5
    ,aat_information6                     = p_rec.aat_information6
    ,aat_information7                     = p_rec.aat_information7
    ,aat_information8                     = p_rec.aat_information8
    ,aat_information9                     = p_rec.aat_information9
    ,aat_information10                    = p_rec.aat_information10
    ,aat_information11                    = p_rec.aat_information11
    ,aat_information12                    = p_rec.aat_information12
    ,aat_information13                    = p_rec.aat_information13
    ,aat_information14                    = p_rec.aat_information14
    ,aat_information15                    = p_rec.aat_information15
    ,aat_information16                    = p_rec.aat_information16
    ,aat_information17                    = p_rec.aat_information17
    ,aat_information18                    = p_rec.aat_information18
    ,aat_information19                    = p_rec.aat_information19
    ,aat_information20                    = p_rec.aat_information20
    ,lgps_process_flag                    = p_rec.lgps_process_flag
    ,lgps_exclusion_type                  = p_rec.lgps_exclusion_type
    ,lgps_pensionable_pay                 = p_rec.lgps_pensionable_pay
    ,lgps_trans_arrang_flag               = p_rec.lgps_trans_arrang_flag
    ,lgps_membership_number               = p_rec.lgps_membership_number
    where   assignment_attribute_id = p_rec.assignment_attribute_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
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
End dt_update_dml;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< update_dml >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure update_dml
  (p_rec                      in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_aat_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< dt_pre_update >-----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--      the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details.
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
-- ---------------------------------------------------------------------------+
Procedure dt_pre_update
  (p_rec                     in out nocopy     pqp_aat_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    pqp_aat_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.assignment_attribute_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pqp_aat_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
    End If;
    --
    -- We must now insert the updated row
    --
    pqp_aat_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< pre_update >------------------------------|
-- ---------------------------------------------------------------------------+
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
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure pre_update
  (p_rec                   in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< post_update >-------------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure post_update
  (p_rec                   in pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_aat_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
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
      ,p_tp_headteacher_grp_code --added for head Teacher seconded location for salary scale calculation
      =>p_rec.tp_headteacher_grp_code
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
      ,p_effective_start_date_o
      => pqp_aat_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqp_aat_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pqp_aat_shd.g_old_rec.business_group_id
      ,p_assignment_id_o
      => pqp_aat_shd.g_old_rec.assignment_id
      ,p_contract_type_o
      => pqp_aat_shd.g_old_rec.contract_type
      ,p_work_pattern_o
      => pqp_aat_shd.g_old_rec.work_pattern
      ,p_start_day_o
      => pqp_aat_shd.g_old_rec.start_day
      ,p_object_version_number_o
      => pqp_aat_shd.g_old_rec.object_version_number
      ,p_primary_company_car_o
      => pqp_aat_shd.g_old_rec.primary_company_car
      ,p_primary_car_fuel_benefit_o
      => pqp_aat_shd.g_old_rec.primary_car_fuel_benefit
      ,p_primary_class_1a_o
      => pqp_aat_shd.g_old_rec.primary_class_1a
      ,p_primary_capital_contributi_o
      => pqp_aat_shd.g_old_rec.primary_capital_contribution
      ,p_primary_private_contributi_o
      => pqp_aat_shd.g_old_rec.primary_private_contribution
      ,p_secondary_company_car_o
      => pqp_aat_shd.g_old_rec.secondary_company_car
      ,p_secondary_car_fuel_benefit_o
      => pqp_aat_shd.g_old_rec.secondary_car_fuel_benefit
      ,p_secondary_class_1a_o
      => pqp_aat_shd.g_old_rec.secondary_class_1a
      ,p_secondary_capital_contribu_o
      => pqp_aat_shd.g_old_rec.secondary_capital_contribution
      ,p_secondary_private_contribu_o
      => pqp_aat_shd.g_old_rec.secondary_private_contribution
      ,p_company_car_calc_method_o
      => pqp_aat_shd.g_old_rec.company_car_calc_method
      ,p_company_car_rates_table_id_o
      => pqp_aat_shd.g_old_rec.company_car_rates_table_id
      ,p_company_car_secondary_tabl_o
      => pqp_aat_shd.g_old_rec.company_car_secondary_table_id
      ,p_private_car_o
      => pqp_aat_shd.g_old_rec.private_car
      ,p_private_car_calc_method_o
      => pqp_aat_shd.g_old_rec.private_car_calc_method
      ,p_private_car_rates_table_id_o
      => pqp_aat_shd.g_old_rec.private_car_rates_table_id
      ,p_private_car_essential_tabl_o
      => pqp_aat_shd.g_old_rec.private_car_essential_table_id
      ,p_tp_is_teacher_o
      => pqp_aat_shd.g_old_rec.tp_is_teacher
      ,p_tp_headteacher_grp_code_o		--added for head Teacher seconded location for salary scale calculation
      =>pqp_aat_shd.g_old_rec.tp_headteacher_grp_code
      ,p_tp_safeguarded_grade_o
      => pqp_aat_shd.g_old_rec.tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id_o
      => pqp_aat_shd.g_old_rec.tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type_o
      => pqp_aat_shd.g_old_rec.tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id_o
      => pqp_aat_shd.g_old_rec.tp_safeguarded_rate_id
      ,p_tp_spinal_point_id_o
      => pqp_aat_shd.g_old_rec.tp_safeguarded_spinal_point_id
      ,p_tp_elected_pension_o
      => pqp_aat_shd.g_old_rec.tp_elected_pension
      ,p_tp_fast_track_o
      => pqp_aat_shd.g_old_rec.tp_fast_track
      ,p_aat_attribute_category_o
      => pqp_aat_shd.g_old_rec.aat_attribute_category
      ,p_aat_attribute1_o
      => pqp_aat_shd.g_old_rec.aat_attribute1
      ,p_aat_attribute2_o
      => pqp_aat_shd.g_old_rec.aat_attribute2
      ,p_aat_attribute3_o
      => pqp_aat_shd.g_old_rec.aat_attribute3
      ,p_aat_attribute4_o
      => pqp_aat_shd.g_old_rec.aat_attribute4
      ,p_aat_attribute5_o
      => pqp_aat_shd.g_old_rec.aat_attribute5
      ,p_aat_attribute6_o
      => pqp_aat_shd.g_old_rec.aat_attribute6
      ,p_aat_attribute7_o
      => pqp_aat_shd.g_old_rec.aat_attribute7
      ,p_aat_attribute8_o
      => pqp_aat_shd.g_old_rec.aat_attribute8
      ,p_aat_attribute9_o
      => pqp_aat_shd.g_old_rec.aat_attribute9
      ,p_aat_attribute10_o
      => pqp_aat_shd.g_old_rec.aat_attribute10
      ,p_aat_attribute11_o
      => pqp_aat_shd.g_old_rec.aat_attribute11
      ,p_aat_attribute12_o
      => pqp_aat_shd.g_old_rec.aat_attribute12
      ,p_aat_attribute13_o
      => pqp_aat_shd.g_old_rec.aat_attribute13
      ,p_aat_attribute14_o
      => pqp_aat_shd.g_old_rec.aat_attribute14
      ,p_aat_attribute15_o
      => pqp_aat_shd.g_old_rec.aat_attribute15
      ,p_aat_attribute16_o
      => pqp_aat_shd.g_old_rec.aat_attribute16
      ,p_aat_attribute17_o
      => pqp_aat_shd.g_old_rec.aat_attribute17
      ,p_aat_attribute18_o
      => pqp_aat_shd.g_old_rec.aat_attribute18
      ,p_aat_attribute19_o
      => pqp_aat_shd.g_old_rec.aat_attribute19
      ,p_aat_attribute20_o
      => pqp_aat_shd.g_old_rec.aat_attribute20
      ,p_aat_information_category_o
      => pqp_aat_shd.g_old_rec.aat_information_category
      ,p_aat_information1_o
      => pqp_aat_shd.g_old_rec.aat_information1
      ,p_aat_information2_o
      => pqp_aat_shd.g_old_rec.aat_information2
      ,p_aat_information3_o
      => pqp_aat_shd.g_old_rec.aat_information3
      ,p_aat_information4_o
      => pqp_aat_shd.g_old_rec.aat_information4
      ,p_aat_information5_o
      => pqp_aat_shd.g_old_rec.aat_information5
      ,p_aat_information6_o
      => pqp_aat_shd.g_old_rec.aat_information6
      ,p_aat_information7_o
      => pqp_aat_shd.g_old_rec.aat_information7
      ,p_aat_information8_o
      => pqp_aat_shd.g_old_rec.aat_information8
      ,p_aat_information9_o
      => pqp_aat_shd.g_old_rec.aat_information9
      ,p_aat_information10_o
      => pqp_aat_shd.g_old_rec.aat_information10
      ,p_aat_information11_o
      => pqp_aat_shd.g_old_rec.aat_information11
      ,p_aat_information12_o
      => pqp_aat_shd.g_old_rec.aat_information12
      ,p_aat_information13_o
      => pqp_aat_shd.g_old_rec.aat_information13
      ,p_aat_information14_o
      => pqp_aat_shd.g_old_rec.aat_information14
      ,p_aat_information15_o
      => pqp_aat_shd.g_old_rec.aat_information15
      ,p_aat_information16_o
      => pqp_aat_shd.g_old_rec.aat_information16
      ,p_aat_information17_o
      => pqp_aat_shd.g_old_rec.aat_information17
      ,p_aat_information18_o
      => pqp_aat_shd.g_old_rec.aat_information18
      ,p_aat_information19_o
      => pqp_aat_shd.g_old_rec.aat_information19
      ,p_aat_information20_o
      => pqp_aat_shd.g_old_rec.aat_information20
	,p_lgps_process_flag_o
      => pqp_aat_shd.g_old_rec.lgps_process_flag
      ,p_lgps_exclusion_type_o
      => pqp_aat_shd.g_old_rec.lgps_exclusion_type
      ,p_lgps_pensionable_pay_o
      => pqp_aat_shd.g_old_rec.lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag_o
      => pqp_aat_shd.g_old_rec.lgps_trans_arrang_flag
      ,p_lgps_membership_number_o
      => pqp_aat_shd.g_old_rec.lgps_membership_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ASSIGNMENT_ATTRIBUTES_F'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------------< convert_defs >-----------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure convert_defs
  (p_rec in out nocopy pqp_aat_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqp_aat_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqp_aat_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.contract_type = hr_api.g_varchar2) then
    p_rec.contract_type :=
    pqp_aat_shd.g_old_rec.contract_type;
  End If;
  If (p_rec.work_pattern = hr_api.g_varchar2) then
    p_rec.work_pattern :=
    pqp_aat_shd.g_old_rec.work_pattern;
  End If;
  If (p_rec.start_day = hr_api.g_varchar2) then
    p_rec.start_day :=
    pqp_aat_shd.g_old_rec.start_day;
  End If;
  If (p_rec.primary_company_car = hr_api.g_number) then
    p_rec.primary_company_car :=
    pqp_aat_shd.g_old_rec.primary_company_car;
  End If;
  If (p_rec.primary_car_fuel_benefit = hr_api.g_varchar2) then
    p_rec.primary_car_fuel_benefit :=
    pqp_aat_shd.g_old_rec.primary_car_fuel_benefit;
  End If;
  If (p_rec.primary_class_1a = hr_api.g_varchar2) then
    p_rec.primary_class_1a :=
    pqp_aat_shd.g_old_rec.primary_class_1a;
  End If;
  If (p_rec.primary_capital_contribution = hr_api.g_number) then
    p_rec.primary_capital_contribution :=
    pqp_aat_shd.g_old_rec.primary_capital_contribution;
  End If;
  If (p_rec.primary_private_contribution = hr_api.g_number) then
    p_rec.primary_private_contribution :=
    pqp_aat_shd.g_old_rec.primary_private_contribution;
  End If;
  If (p_rec.secondary_company_car = hr_api.g_number) then
    p_rec.secondary_company_car :=
    pqp_aat_shd.g_old_rec.secondary_company_car;
  End If;
  If (p_rec.secondary_car_fuel_benefit = hr_api.g_varchar2) then
    p_rec.secondary_car_fuel_benefit :=
    pqp_aat_shd.g_old_rec.secondary_car_fuel_benefit;
  End If;
  If (p_rec.secondary_class_1a = hr_api.g_varchar2) then
    p_rec.secondary_class_1a :=
    pqp_aat_shd.g_old_rec.secondary_class_1a;
  End If;
  If (p_rec.secondary_capital_contribution = hr_api.g_number) then
    p_rec.secondary_capital_contribution :=
    pqp_aat_shd.g_old_rec.secondary_capital_contribution;
  End If;
  If (p_rec.secondary_private_contribution = hr_api.g_number) then
    p_rec.secondary_private_contribution :=
    pqp_aat_shd.g_old_rec.secondary_private_contribution;
  End If;
  If (p_rec.company_car_calc_method = hr_api.g_varchar2) then
    p_rec.company_car_calc_method :=
    pqp_aat_shd.g_old_rec.company_car_calc_method;
  End If;
  If (p_rec.company_car_rates_table_id = hr_api.g_number) then
    p_rec.company_car_rates_table_id :=
    pqp_aat_shd.g_old_rec.company_car_rates_table_id;
  End If;
  If (p_rec.company_car_secondary_table_id = hr_api.g_number) then
    p_rec.company_car_secondary_table_id :=
    pqp_aat_shd.g_old_rec.company_car_secondary_table_id;
  End If;
  If (p_rec.private_car = hr_api.g_number) then
    p_rec.private_car :=
    pqp_aat_shd.g_old_rec.private_car;
  End If;
  If (p_rec.private_car_calc_method = hr_api.g_varchar2) then
    p_rec.private_car_calc_method :=
    pqp_aat_shd.g_old_rec.private_car_calc_method;
  End If;
  If (p_rec.private_car_rates_table_id = hr_api.g_number) then
    p_rec.private_car_rates_table_id :=
    pqp_aat_shd.g_old_rec.private_car_rates_table_id;
  End If;
  If (p_rec.private_car_essential_table_id = hr_api.g_number) then
    p_rec.private_car_essential_table_id :=
    pqp_aat_shd.g_old_rec.private_car_essential_table_id;
  End If;
  If (p_rec.tp_is_teacher = hr_api.g_varchar2) then
    p_rec.tp_is_teacher :=
    pqp_aat_shd.g_old_rec.tp_is_teacher;
  End If;
   --added for head Teacher seconded location for salary scale calculation
   If (p_rec.tp_headteacher_grp_code = hr_api.g_number) then
    p_rec.tp_headteacher_grp_code :=
    pqp_aat_shd.g_old_rec.tp_headteacher_grp_code;
  End If;
  If (p_rec.tp_safeguarded_grade = hr_api.g_varchar2) then
    p_rec.tp_safeguarded_grade :=
    pqp_aat_shd.g_old_rec.tp_safeguarded_grade;
  End If;
  If (p_rec.tp_safeguarded_grade_id = hr_api.g_number) then
      p_rec.tp_safeguarded_grade_id :=
      pqp_aat_shd.g_old_rec.tp_safeguarded_grade_id;
  End If;
  If (p_rec.tp_safeguarded_rate_type = hr_api.g_varchar2) then
    p_rec.tp_safeguarded_rate_type :=
    pqp_aat_shd.g_old_rec.tp_safeguarded_rate_type;
  End If;
  If (p_rec.tp_safeguarded_rate_id = hr_api.g_number) then
      p_rec.tp_safeguarded_rate_id :=
      pqp_aat_shd.g_old_rec.tp_safeguarded_rate_id;
  End If;
  If (p_rec.tp_safeguarded_spinal_point_id = hr_api.g_number) then
        p_rec.tp_safeguarded_spinal_point_id :=
        pqp_aat_shd.g_old_rec.tp_safeguarded_spinal_point_id;
  End If;
  If (p_rec.tp_elected_pension = hr_api.g_varchar2) then
    p_rec.tp_elected_pension :=
    pqp_aat_shd.g_old_rec.tp_elected_pension;
  End If;
  If (p_rec.tp_fast_track = hr_api.g_varchar2) then
    p_rec.tp_fast_track :=
    pqp_aat_shd.g_old_rec.tp_fast_track;
  End If;
  If (p_rec.aat_attribute_category = hr_api.g_varchar2) then
    p_rec.aat_attribute_category :=
    pqp_aat_shd.g_old_rec.aat_attribute_category;
  End If;
  If (p_rec.aat_attribute1 = hr_api.g_varchar2) then
    p_rec.aat_attribute1 :=
    pqp_aat_shd.g_old_rec.aat_attribute1;
  End If;
  If (p_rec.aat_attribute2 = hr_api.g_varchar2) then
    p_rec.aat_attribute2 :=
    pqp_aat_shd.g_old_rec.aat_attribute2;
  End If;
  If (p_rec.aat_attribute3 = hr_api.g_varchar2) then
    p_rec.aat_attribute3 :=
    pqp_aat_shd.g_old_rec.aat_attribute3;
  End If;
  If (p_rec.aat_attribute4 = hr_api.g_varchar2) then
    p_rec.aat_attribute4 :=
    pqp_aat_shd.g_old_rec.aat_attribute4;
  End If;
  If (p_rec.aat_attribute5 = hr_api.g_varchar2) then
    p_rec.aat_attribute5 :=
    pqp_aat_shd.g_old_rec.aat_attribute5;
  End If;
  If (p_rec.aat_attribute6 = hr_api.g_varchar2) then
    p_rec.aat_attribute6 :=
    pqp_aat_shd.g_old_rec.aat_attribute6;
  End If;
  If (p_rec.aat_attribute7 = hr_api.g_varchar2) then
    p_rec.aat_attribute7 :=
    pqp_aat_shd.g_old_rec.aat_attribute7;
  End If;
  If (p_rec.aat_attribute8 = hr_api.g_varchar2) then
    p_rec.aat_attribute8 :=
    pqp_aat_shd.g_old_rec.aat_attribute8;
  End If;
  If (p_rec.aat_attribute9 = hr_api.g_varchar2) then
    p_rec.aat_attribute9 :=
    pqp_aat_shd.g_old_rec.aat_attribute9;
  End If;
  If (p_rec.aat_attribute10 = hr_api.g_varchar2) then
    p_rec.aat_attribute10 :=
    pqp_aat_shd.g_old_rec.aat_attribute10;
  End If;
  If (p_rec.aat_attribute11 = hr_api.g_varchar2) then
    p_rec.aat_attribute11 :=
    pqp_aat_shd.g_old_rec.aat_attribute11;
  End If;
  If (p_rec.aat_attribute12 = hr_api.g_varchar2) then
    p_rec.aat_attribute12 :=
    pqp_aat_shd.g_old_rec.aat_attribute12;
  End If;
  If (p_rec.aat_attribute13 = hr_api.g_varchar2) then
    p_rec.aat_attribute13 :=
    pqp_aat_shd.g_old_rec.aat_attribute13;
  End If;
  If (p_rec.aat_attribute14 = hr_api.g_varchar2) then
    p_rec.aat_attribute14 :=
    pqp_aat_shd.g_old_rec.aat_attribute14;
  End If;
  If (p_rec.aat_attribute15 = hr_api.g_varchar2) then
    p_rec.aat_attribute15 :=
    pqp_aat_shd.g_old_rec.aat_attribute15;
  End If;
  If (p_rec.aat_attribute16 = hr_api.g_varchar2) then
    p_rec.aat_attribute16 :=
    pqp_aat_shd.g_old_rec.aat_attribute16;
  End If;
  If (p_rec.aat_attribute17 = hr_api.g_varchar2) then
    p_rec.aat_attribute17 :=
    pqp_aat_shd.g_old_rec.aat_attribute17;
  End If;
  If (p_rec.aat_attribute18 = hr_api.g_varchar2) then
    p_rec.aat_attribute18 :=
    pqp_aat_shd.g_old_rec.aat_attribute18;
  End If;
  If (p_rec.aat_attribute19 = hr_api.g_varchar2) then
    p_rec.aat_attribute19 :=
    pqp_aat_shd.g_old_rec.aat_attribute19;
  End If;
  If (p_rec.aat_attribute20 = hr_api.g_varchar2) then
    p_rec.aat_attribute20 :=
    pqp_aat_shd.g_old_rec.aat_attribute20;
  End If;
  If (p_rec.aat_information_category = hr_api.g_varchar2) then
    p_rec.aat_information_category :=
    pqp_aat_shd.g_old_rec.aat_information_category;
  End If;
  If (p_rec.aat_information1 = hr_api.g_varchar2) then
    p_rec.aat_information1 :=
    pqp_aat_shd.g_old_rec.aat_information1;
  End If;
  If (p_rec.aat_information2 = hr_api.g_varchar2) then
    p_rec.aat_information2 :=
    pqp_aat_shd.g_old_rec.aat_information2;
  End If;
  If (p_rec.aat_information3 = hr_api.g_varchar2) then
    p_rec.aat_information3 :=
    pqp_aat_shd.g_old_rec.aat_information3;
  End If;
  If (p_rec.aat_information4 = hr_api.g_varchar2) then
    p_rec.aat_information4 :=
    pqp_aat_shd.g_old_rec.aat_information4;
  End If;
  If (p_rec.aat_information5 = hr_api.g_varchar2) then
    p_rec.aat_information5 :=
    pqp_aat_shd.g_old_rec.aat_information5;
  End If;
  If (p_rec.aat_information6 = hr_api.g_varchar2) then
    p_rec.aat_information6 :=
    pqp_aat_shd.g_old_rec.aat_information6;
  End If;
  If (p_rec.aat_information7 = hr_api.g_varchar2) then
    p_rec.aat_information7 :=
    pqp_aat_shd.g_old_rec.aat_information7;
  End If;
  If (p_rec.aat_information8 = hr_api.g_varchar2) then
    p_rec.aat_information8 :=
    pqp_aat_shd.g_old_rec.aat_information8;
  End If;
  If (p_rec.aat_information9 = hr_api.g_varchar2) then
    p_rec.aat_information9 :=
    pqp_aat_shd.g_old_rec.aat_information9;
  End If;
  If (p_rec.aat_information10 = hr_api.g_varchar2) then
    p_rec.aat_information10 :=
    pqp_aat_shd.g_old_rec.aat_information10;
  End If;
  If (p_rec.aat_information11 = hr_api.g_varchar2) then
    p_rec.aat_information11 :=
    pqp_aat_shd.g_old_rec.aat_information11;
  End If;
  If (p_rec.aat_information12 = hr_api.g_varchar2) then
    p_rec.aat_information12 :=
    pqp_aat_shd.g_old_rec.aat_information12;
  End If;
  If (p_rec.aat_information13 = hr_api.g_varchar2) then
    p_rec.aat_information13 :=
    pqp_aat_shd.g_old_rec.aat_information13;
  End If;
  If (p_rec.aat_information14 = hr_api.g_varchar2) then
    p_rec.aat_information14 :=
    pqp_aat_shd.g_old_rec.aat_information14;
  End If;
  If (p_rec.aat_information15 = hr_api.g_varchar2) then
    p_rec.aat_information15 :=
    pqp_aat_shd.g_old_rec.aat_information15;
  End If;
  If (p_rec.aat_information16 = hr_api.g_varchar2) then
    p_rec.aat_information16 :=
    pqp_aat_shd.g_old_rec.aat_information16;
  End If;
  If (p_rec.aat_information17 = hr_api.g_varchar2) then
    p_rec.aat_information17 :=
    pqp_aat_shd.g_old_rec.aat_information17;
  End If;
  If (p_rec.aat_information18 = hr_api.g_varchar2) then
    p_rec.aat_information18 :=
    pqp_aat_shd.g_old_rec.aat_information18;
  End If;
  If (p_rec.aat_information19 = hr_api.g_varchar2) then
    p_rec.aat_information19 :=
    pqp_aat_shd.g_old_rec.aat_information19;
  End If;
  If (p_rec.aat_information20 = hr_api.g_varchar2) then
    p_rec.aat_information20 :=
    pqp_aat_shd.g_old_rec.aat_information20;
  End If;
  If (p_rec.lgps_process_flag = hr_api.g_varchar2) then
    p_rec.lgps_process_flag :=
    pqp_aat_shd.g_old_rec.lgps_process_flag;
  End If;
  If (p_rec.lgps_exclusion_type = hr_api.g_varchar2) then
    p_rec.lgps_exclusion_type :=
    pqp_aat_shd.g_old_rec.lgps_exclusion_type;
  End If;
  If (p_rec.lgps_pensionable_pay = hr_api.g_varchar2) then
    p_rec.lgps_pensionable_pay :=
    pqp_aat_shd.g_old_rec.lgps_pensionable_pay;
  End If;
  If (p_rec.lgps_trans_arrang_flag = hr_api.g_varchar2) then
    p_rec.lgps_trans_arrang_flag :=
    pqp_aat_shd.g_old_rec.lgps_trans_arrang_flag;
  End If;
  If (p_rec.lgps_membership_number = hr_api.g_varchar2) then
    p_rec.lgps_membership_number :=
    pqp_aat_shd.g_old_rec.lgps_membership_number;
  End If;

  --
End convert_defs;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_aat_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  pqp_aat_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_assignment_attribute_id          => p_rec.assignment_attribute_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pqp_aat_upd.convert_defs(p_rec);
  --
  pqp_aat_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Update the row.
  --
  update_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date                  => l_validation_end_date
    );
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
End upd;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< upd >-------------------------------------|
-- ---------------------------------------------------------------------------+
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_assignment_attribute_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_contract_type                in     varchar2  default hr_api.g_varchar2
  ,p_work_pattern                 in     varchar2  default hr_api.g_varchar2
  ,p_start_day                    in     varchar2  default hr_api.g_varchar2
  ,p_primary_company_car          in     number    default hr_api.g_number
  ,p_primary_car_fuel_benefit     in     varchar2  default hr_api.g_varchar2
  ,p_primary_class_1a             in     varchar2  default hr_api.g_varchar2
  ,p_primary_capital_contribution in     number    default hr_api.g_number
  ,p_primary_private_contribution in     number    default hr_api.g_number
  ,p_secondary_company_car        in     number    default hr_api.g_number
  ,p_secondary_car_fuel_benefit   in     varchar2  default hr_api.g_varchar2
  ,p_secondary_class_1a           in     varchar2  default hr_api.g_varchar2
  ,p_secondary_capital_contributi in     number    default hr_api.g_number
  ,p_secondary_private_contributi in     number    default hr_api.g_number
  ,p_company_car_calc_method      in     varchar2  default hr_api.g_varchar2
  ,p_company_car_rates_table_id   in     number    default hr_api.g_number
  ,p_company_car_secondary_table  in     number    default hr_api.g_number
  ,p_private_car                  in     number    default hr_api.g_number
  ,p_private_car_calc_method      in     varchar2  default hr_api.g_varchar2
  ,p_private_car_rates_table_id   in     number    default hr_api.g_number
  ,p_private_car_essential_table  in     number    default hr_api.g_number
  ,p_tp_is_teacher                in     varchar2  default hr_api.g_varchar2
  ,p_tp_headteacher_grp_code in number default hr_api.g_number  --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade         in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_grade_id      in     number    default hr_api.g_number
  ,p_tp_safeguarded_rate_type     in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_rate_id       in     number    default hr_api.g_number
  ,p_tp_spinal_point_id           in     number    default hr_api.g_number
  ,p_tp_elected_pension           in     varchar2  default hr_api.g_varchar2
  ,p_tp_fast_track                in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_aat_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_aat_information1             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information2             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information3             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information4             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information5             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information6             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information7             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information8             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information9             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information10            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information11            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information12            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information13            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information14            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information15            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information16            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information17            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information18            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information19            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information20            in     varchar2  default hr_api.g_varchar2
  ,p_lgps_process_flag            in     varchar2  default hr_api.g_varchar2
  ,p_lgps_exclusion_type          in     varchar2  default hr_api.g_varchar2
  ,p_lgps_pensionable_pay         in     varchar2  default hr_api.g_varchar2
  ,p_lgps_trans_arrang_flag       in     varchar2  default hr_api.g_varchar2
  ,p_lgps_membership_number       in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
--
  l_rec         pqp_aat_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_aat_shd.convert_args
    (p_assignment_attribute_id
    ,null
    ,null
    ,p_business_group_id
    ,p_assignment_id
    ,p_contract_type
    ,p_work_pattern
    ,p_start_day
    ,p_object_version_number
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
    ,p_tp_headteacher_grp_code   --added for head Teacher seconded location for salary scale calculation
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
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_aat_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_aat_upd;

/
