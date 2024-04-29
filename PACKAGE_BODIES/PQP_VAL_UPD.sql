--------------------------------------------------------
--  DDL for Package Body PQP_VAL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAL_UPD" as
/* $Header: pqvalrhi.pkb 120.0.12010000.3 2008/08/08 07:22:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_val_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of
--   this procedure are as follows:
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
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
  (p_rec                   in out nocopy pqp_val_shd.g_rec_type
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
        (p_base_table_name => 'pqp_vehicle_allocations_f'
        ,p_base_key_column => 'vehicle_allocation_id'
        ,p_base_key_value  => p_rec.vehicle_allocation_id
        );
    --
    --
    --
    -- Update the pqp_vehicle_allocations_f Row
    --
    update  pqp_vehicle_allocations_f
    set
     vehicle_allocation_id                = p_rec.vehicle_allocation_id
    ,assignment_id                        = p_rec.assignment_id
    ,business_group_id                    = p_rec.business_group_id
    ,across_assignments                   = p_rec.across_assignments
    ,vehicle_repository_id                = p_rec.vehicle_repository_id
    ,usage_type                           = p_rec.usage_type
    ,capital_contribution                 = p_rec.capital_contribution
    ,private_contribution                 = p_rec.private_contribution
    ,default_vehicle                      = p_rec.default_vehicle
    ,fuel_card                            = p_rec.fuel_card
    ,fuel_card_number                     = p_rec.fuel_card_number
    ,calculation_method                   = p_rec.calculation_method
    ,rates_table_id                       = p_rec.rates_table_id
    ,element_type_id                      = p_rec.element_type_id
    ,private_use_flag                     = p_rec.private_use_flag
    ,insurance_number                     = p_rec.insurance_number
    ,insurance_expiry_date                = p_rec.insurance_expiry_date
    ,val_attribute_category               = p_rec.val_attribute_category
    ,val_attribute1                       = p_rec.val_attribute1
    ,val_attribute2                       = p_rec.val_attribute2
    ,val_attribute3                       = p_rec.val_attribute3
    ,val_attribute4                       = p_rec.val_attribute4
    ,val_attribute5                       = p_rec.val_attribute5
    ,val_attribute6                       = p_rec.val_attribute6
    ,val_attribute7                       = p_rec.val_attribute7
    ,val_attribute8                       = p_rec.val_attribute8
    ,val_attribute9                       = p_rec.val_attribute9
    ,val_attribute10                      = p_rec.val_attribute10
    ,val_attribute11                      = p_rec.val_attribute11
    ,val_attribute12                      = p_rec.val_attribute12
    ,val_attribute13                      = p_rec.val_attribute13
    ,val_attribute14                      = p_rec.val_attribute14
    ,val_attribute15                      = p_rec.val_attribute15
    ,val_attribute16                      = p_rec.val_attribute16
    ,val_attribute17                      = p_rec.val_attribute17
    ,val_attribute18                      = p_rec.val_attribute18
    ,val_attribute19                      = p_rec.val_attribute19
    ,val_attribute20                      = p_rec.val_attribute20
    ,val_information_category             = p_rec.val_information_category
    ,val_information1                     = p_rec.val_information1
    ,val_information2                     = p_rec.val_information2
    ,val_information3                     = p_rec.val_information3
    ,val_information4                     = p_rec.val_information4
    ,val_information5                     = p_rec.val_information5
    ,val_information6                     = p_rec.val_information6
    ,val_information7                     = p_rec.val_information7
    ,val_information8                     = p_rec.val_information8
    ,val_information9                     = p_rec.val_information9
    ,val_information10                    = p_rec.val_information10
    ,val_information11                    = p_rec.val_information11
    ,val_information12                    = p_rec.val_information12
    ,val_information13                    = p_rec.val_information13
    ,val_information14                    = p_rec.val_information14
    ,val_information15                    = p_rec.val_information15
    ,val_information16                    = p_rec.val_information16
    ,val_information17                    = p_rec.val_information17
    ,val_information18                    = p_rec.val_information18
    ,val_information19                    = p_rec.val_information19
    ,val_information20                    = p_rec.val_information20
    ,object_version_number                = p_rec.object_version_number
    ,fuel_benefit                         = p_rec.fuel_benefit
    ,sliding_rates_info                   =p_rec.sliding_rates_info
    where   vehicle_allocation_id = p_rec.vehicle_allocation_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    --
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
    --
    pqp_val_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_val_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec                      in out nocopy pqp_val_shd.g_rec_type
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
  pqp_val_upd.dt_update_dml
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
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
  (p_rec                     in out  nocopy   pqp_val_shd.g_rec_type
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
    pqp_val_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.vehicle_allocation_id
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
      pqp_val_del.delete_dml
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
    pqp_val_ins.insert_dml
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
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
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
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec                   in out nocopy pqp_val_shd.g_rec_type
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
-- ----------------------------------------------------------------------------
-- |----------------------------< post_update >-------------------------------|
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
  (p_rec                   in pqp_val_shd.g_rec_type
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
    pqp_val_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_vehicle_allocation_id
      => p_rec.vehicle_allocation_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_across_assignments
      => p_rec.across_assignments
      ,p_vehicle_repository_id
      => p_rec.vehicle_repository_id
      ,p_usage_type
      => p_rec.usage_type
      ,p_capital_contribution
      => p_rec.capital_contribution
      ,p_private_contribution
      => p_rec.private_contribution
      ,p_default_vehicle
      => p_rec.default_vehicle
      ,p_fuel_card
      => p_rec.fuel_card
      ,p_fuel_card_number
      => p_rec.fuel_card_number
      ,p_calculation_method
      => p_rec.calculation_method
      ,p_rates_table_id
      => p_rec.rates_table_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_private_use_flag
      => p_rec.private_use_flag
      ,p_insurance_number
      => p_rec.insurance_number
      ,p_insurance_expiry_date
      => p_rec.insurance_expiry_date
      ,p_val_attribute_category
      => p_rec.val_attribute_category
      ,p_val_attribute1
      => p_rec.val_attribute1
      ,p_val_attribute2
      => p_rec.val_attribute2
      ,p_val_attribute3
      => p_rec.val_attribute3
      ,p_val_attribute4
      => p_rec.val_attribute4
      ,p_val_attribute5
      => p_rec.val_attribute5
      ,p_val_attribute6
      => p_rec.val_attribute6
      ,p_val_attribute7
      => p_rec.val_attribute7
      ,p_val_attribute8
      => p_rec.val_attribute8
      ,p_val_attribute9
      => p_rec.val_attribute9
      ,p_val_attribute10
      => p_rec.val_attribute10
      ,p_val_attribute11
      => p_rec.val_attribute11
      ,p_val_attribute12
      => p_rec.val_attribute12
      ,p_val_attribute13
      => p_rec.val_attribute13
      ,p_val_attribute14
      => p_rec.val_attribute14
      ,p_val_attribute15
      => p_rec.val_attribute15
      ,p_val_attribute16
      => p_rec.val_attribute16
      ,p_val_attribute17
      => p_rec.val_attribute17
      ,p_val_attribute18
      => p_rec.val_attribute18
      ,p_val_attribute19
      => p_rec.val_attribute19
      ,p_val_attribute20
      => p_rec.val_attribute20
      ,p_val_information_category
      => p_rec.val_information_category
      ,p_val_information1
      => p_rec.val_information1
      ,p_val_information2
      => p_rec.val_information2
      ,p_val_information3
      => p_rec.val_information3
      ,p_val_information4
      => p_rec.val_information4
      ,p_val_information5
      => p_rec.val_information5
      ,p_val_information6
      => p_rec.val_information6
      ,p_val_information7
      => p_rec.val_information7
      ,p_val_information8
      => p_rec.val_information8
      ,p_val_information9
      => p_rec.val_information9
      ,p_val_information10
      => p_rec.val_information10
      ,p_val_information11
      => p_rec.val_information11
      ,p_val_information12
      => p_rec.val_information12
      ,p_val_information13
      => p_rec.val_information13
      ,p_val_information14
      => p_rec.val_information14
      ,p_val_information15
      => p_rec.val_information15
      ,p_val_information16
      => p_rec.val_information16
      ,p_val_information17
      => p_rec.val_information17
      ,p_val_information18
      => p_rec.val_information18
      ,p_val_information19
      => p_rec.val_information19
      ,p_val_information20
      => p_rec.val_information20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_fuel_benefit
      => p_rec.fuel_benefit
      ,p_effective_start_date_o
      => pqp_val_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqp_val_shd.g_old_rec.effective_end_date
      ,p_assignment_id_o
      => pqp_val_shd.g_old_rec.assignment_id
      ,p_business_group_id_o
      => pqp_val_shd.g_old_rec.business_group_id
      ,p_across_assignments_o
      => pqp_val_shd.g_old_rec.across_assignments
      ,p_vehicle_repository_id_o
      => pqp_val_shd.g_old_rec.vehicle_repository_id
      ,p_usage_type_o
      => pqp_val_shd.g_old_rec.usage_type
      ,p_capital_contribution_o
      => pqp_val_shd.g_old_rec.capital_contribution
      ,p_private_contribution_o
      => pqp_val_shd.g_old_rec.private_contribution
      ,p_default_vehicle_o
      => pqp_val_shd.g_old_rec.default_vehicle
      ,p_fuel_card_o
      => pqp_val_shd.g_old_rec.fuel_card
      ,p_fuel_card_number_o
      => pqp_val_shd.g_old_rec.fuel_card_number
      ,p_calculation_method_o
      => pqp_val_shd.g_old_rec.calculation_method
      ,p_rates_table_id_o
      => pqp_val_shd.g_old_rec.rates_table_id
      ,p_element_type_id_o
      => pqp_val_shd.g_old_rec.element_type_id
      ,p_private_use_flag_o
      => pqp_val_shd.g_old_rec.private_use_flag
      ,p_insurance_number_o
      => pqp_val_shd.g_old_rec.insurance_number
      ,p_insurance_expiry_date_o
      => pqp_val_shd.g_old_rec.insurance_expiry_date
      ,p_val_attribute_category_o
      => pqp_val_shd.g_old_rec.val_attribute_category
      ,p_val_attribute1_o
      => pqp_val_shd.g_old_rec.val_attribute1
      ,p_val_attribute2_o
      => pqp_val_shd.g_old_rec.val_attribute2
      ,p_val_attribute3_o
      => pqp_val_shd.g_old_rec.val_attribute3
      ,p_val_attribute4_o
      => pqp_val_shd.g_old_rec.val_attribute4
      ,p_val_attribute5_o
      => pqp_val_shd.g_old_rec.val_attribute5
      ,p_val_attribute6_o
      => pqp_val_shd.g_old_rec.val_attribute6
      ,p_val_attribute7_o
      => pqp_val_shd.g_old_rec.val_attribute7
      ,p_val_attribute8_o
      => pqp_val_shd.g_old_rec.val_attribute8
      ,p_val_attribute9_o
      => pqp_val_shd.g_old_rec.val_attribute9
      ,p_val_attribute10_o
      => pqp_val_shd.g_old_rec.val_attribute10
      ,p_val_attribute11_o
      => pqp_val_shd.g_old_rec.val_attribute11
      ,p_val_attribute12_o
      => pqp_val_shd.g_old_rec.val_attribute12
      ,p_val_attribute13_o
      => pqp_val_shd.g_old_rec.val_attribute13
      ,p_val_attribute14_o
      => pqp_val_shd.g_old_rec.val_attribute14
      ,p_val_attribute15_o
      => pqp_val_shd.g_old_rec.val_attribute15
      ,p_val_attribute16_o
      => pqp_val_shd.g_old_rec.val_attribute16
      ,p_val_attribute17_o
      => pqp_val_shd.g_old_rec.val_attribute17
      ,p_val_attribute18_o
      => pqp_val_shd.g_old_rec.val_attribute18
      ,p_val_attribute19_o
      => pqp_val_shd.g_old_rec.val_attribute19
      ,p_val_attribute20_o
      => pqp_val_shd.g_old_rec.val_attribute20
      ,p_val_information_category_o
      => pqp_val_shd.g_old_rec.val_information_category
      ,p_val_information1_o
      => pqp_val_shd.g_old_rec.val_information1
      ,p_val_information2_o
      => pqp_val_shd.g_old_rec.val_information2
      ,p_val_information3_o
      => pqp_val_shd.g_old_rec.val_information3
      ,p_val_information4_o
      => pqp_val_shd.g_old_rec.val_information4
      ,p_val_information5_o
      => pqp_val_shd.g_old_rec.val_information5
      ,p_val_information6_o
      => pqp_val_shd.g_old_rec.val_information6
      ,p_val_information7_o
      => pqp_val_shd.g_old_rec.val_information7
      ,p_val_information8_o
      => pqp_val_shd.g_old_rec.val_information8
      ,p_val_information9_o
      => pqp_val_shd.g_old_rec.val_information9
      ,p_val_information10_o
      => pqp_val_shd.g_old_rec.val_information10
      ,p_val_information11_o
      => pqp_val_shd.g_old_rec.val_information11
      ,p_val_information12_o
      => pqp_val_shd.g_old_rec.val_information12
      ,p_val_information13_o
      => pqp_val_shd.g_old_rec.val_information13
      ,p_val_information14_o
      => pqp_val_shd.g_old_rec.val_information14
      ,p_val_information15_o
      => pqp_val_shd.g_old_rec.val_information15
      ,p_val_information16_o
      => pqp_val_shd.g_old_rec.val_information16
      ,p_val_information17_o
      => pqp_val_shd.g_old_rec.val_information17
      ,p_val_information18_o
      => pqp_val_shd.g_old_rec.val_information18
      ,p_val_information19_o
      => pqp_val_shd.g_old_rec.val_information19
      ,p_val_information20_o
      => pqp_val_shd.g_old_rec.val_information20
      ,p_object_version_number_o
      => pqp_val_shd.g_old_rec.object_version_number
      ,p_fuel_benefit_o
      => pqp_val_shd.g_old_rec.fuel_benefit

      ,p_sliding_rates_info_o
      => pqp_val_shd.g_old_rec.sliding_rates_info
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_F'
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
  (p_rec in out nocopy pqp_val_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqp_val_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqp_val_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.across_assignments = hr_api.g_varchar2) then
    p_rec.across_assignments :=
    pqp_val_shd.g_old_rec.across_assignments;
  End If;
  If (p_rec.vehicle_repository_id = hr_api.g_number) then
    p_rec.vehicle_repository_id :=
    pqp_val_shd.g_old_rec.vehicle_repository_id;
  End If;
  If (p_rec.usage_type = hr_api.g_varchar2) then
    p_rec.usage_type :=
    pqp_val_shd.g_old_rec.usage_type;
  End If;
  If (p_rec.capital_contribution = hr_api.g_number) then
    p_rec.capital_contribution :=
    pqp_val_shd.g_old_rec.capital_contribution;
  End If;
  If (p_rec.private_contribution = hr_api.g_number) then
    p_rec.private_contribution :=
    pqp_val_shd.g_old_rec.private_contribution;
  End If;
  If (p_rec.default_vehicle = hr_api.g_varchar2) then
    p_rec.default_vehicle :=
    pqp_val_shd.g_old_rec.default_vehicle;
  End If;
  If (p_rec.fuel_card = hr_api.g_varchar2) then
    p_rec.fuel_card :=
    pqp_val_shd.g_old_rec.fuel_card;
  End If;
  If (p_rec.fuel_card_number = hr_api.g_varchar2) then
    p_rec.fuel_card_number :=
    pqp_val_shd.g_old_rec.fuel_card_number;
  End If;
  If (p_rec.calculation_method = hr_api.g_varchar2) then
    p_rec.calculation_method :=
    pqp_val_shd.g_old_rec.calculation_method;
  End If;
  If (p_rec.rates_table_id = hr_api.g_number) then
    p_rec.rates_table_id :=
    pqp_val_shd.g_old_rec.rates_table_id;
  End If;
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pqp_val_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.private_use_flag = hr_api.g_varchar2) then
    p_rec.private_use_flag :=
    pqp_val_shd.g_old_rec.private_use_flag;
  End If;
  If (p_rec.insurance_number = hr_api.g_varchar2) then
    p_rec.insurance_number :=
    pqp_val_shd.g_old_rec.insurance_number;
  End If;
  If (p_rec.insurance_expiry_date = hr_api.g_date) then
    p_rec.insurance_expiry_date :=
    pqp_val_shd.g_old_rec.insurance_expiry_date;
  End If;
  If (p_rec.val_attribute_category = hr_api.g_varchar2) then
    p_rec.val_attribute_category :=
    pqp_val_shd.g_old_rec.val_attribute_category;
  End If;
  If (p_rec.val_attribute1 = hr_api.g_varchar2) then
    p_rec.val_attribute1 :=
    pqp_val_shd.g_old_rec.val_attribute1;
  End If;
  If (p_rec.val_attribute2 = hr_api.g_varchar2) then
    p_rec.val_attribute2 :=
    pqp_val_shd.g_old_rec.val_attribute2;
  End If;
  If (p_rec.val_attribute3 = hr_api.g_varchar2) then
    p_rec.val_attribute3 :=
    pqp_val_shd.g_old_rec.val_attribute3;
  End If;
  If (p_rec.val_attribute4 = hr_api.g_varchar2) then
    p_rec.val_attribute4 :=
    pqp_val_shd.g_old_rec.val_attribute4;
  End If;
  If (p_rec.val_attribute5 = hr_api.g_varchar2) then
    p_rec.val_attribute5 :=
    pqp_val_shd.g_old_rec.val_attribute5;
  End If;
  If (p_rec.val_attribute6 = hr_api.g_varchar2) then
    p_rec.val_attribute6 :=
    pqp_val_shd.g_old_rec.val_attribute6;
  End If;
  If (p_rec.val_attribute7 = hr_api.g_varchar2) then
    p_rec.val_attribute7 :=
    pqp_val_shd.g_old_rec.val_attribute7;
  End If;
  If (p_rec.val_attribute8 = hr_api.g_varchar2) then
    p_rec.val_attribute8 :=
    pqp_val_shd.g_old_rec.val_attribute8;
  End If;
  If (p_rec.val_attribute9 = hr_api.g_varchar2) then
    p_rec.val_attribute9 :=
    pqp_val_shd.g_old_rec.val_attribute9;
  End If;
  If (p_rec.val_attribute10 = hr_api.g_varchar2) then
    p_rec.val_attribute10 :=
    pqp_val_shd.g_old_rec.val_attribute10;
  End If;
  If (p_rec.val_attribute11 = hr_api.g_varchar2) then
    p_rec.val_attribute11 :=
    pqp_val_shd.g_old_rec.val_attribute11;
  End If;
  If (p_rec.val_attribute12 = hr_api.g_varchar2) then
    p_rec.val_attribute12 :=
    pqp_val_shd.g_old_rec.val_attribute12;
  End If;
  If (p_rec.val_attribute13 = hr_api.g_varchar2) then
    p_rec.val_attribute13 :=
    pqp_val_shd.g_old_rec.val_attribute13;
  End If;
  If (p_rec.val_attribute14 = hr_api.g_varchar2) then
    p_rec.val_attribute14 :=
    pqp_val_shd.g_old_rec.val_attribute14;
  End If;
  If (p_rec.val_attribute15 = hr_api.g_varchar2) then
    p_rec.val_attribute15 :=
    pqp_val_shd.g_old_rec.val_attribute15;
  End If;
  If (p_rec.val_attribute16 = hr_api.g_varchar2) then
    p_rec.val_attribute16 :=
    pqp_val_shd.g_old_rec.val_attribute16;
  End If;
  If (p_rec.val_attribute17 = hr_api.g_varchar2) then
    p_rec.val_attribute17 :=
    pqp_val_shd.g_old_rec.val_attribute17;
  End If;
  If (p_rec.val_attribute18 = hr_api.g_varchar2) then
    p_rec.val_attribute18 :=
    pqp_val_shd.g_old_rec.val_attribute18;
  End If;
  If (p_rec.val_attribute19 = hr_api.g_varchar2) then
    p_rec.val_attribute19 :=
    pqp_val_shd.g_old_rec.val_attribute19;
  End If;
  If (p_rec.val_attribute20 = hr_api.g_varchar2) then
    p_rec.val_attribute20 :=
    pqp_val_shd.g_old_rec.val_attribute20;
  End If;
  If (p_rec.val_information_category = hr_api.g_varchar2) then
    p_rec.val_information_category :=
    pqp_val_shd.g_old_rec.val_information_category;
  End If;
  If (p_rec.val_information1 = hr_api.g_varchar2) then
    p_rec.val_information1 :=
    pqp_val_shd.g_old_rec.val_information1;
  End If;
  If (p_rec.val_information2 = hr_api.g_varchar2) then
    p_rec.val_information2 :=
    pqp_val_shd.g_old_rec.val_information2;
  End If;
  If (p_rec.val_information3 = hr_api.g_varchar2) then
    p_rec.val_information3 :=
    pqp_val_shd.g_old_rec.val_information3;
  End If;
  If (p_rec.val_information4 = hr_api.g_varchar2) then
    p_rec.val_information4 :=
    pqp_val_shd.g_old_rec.val_information4;
  End If;
  If (p_rec.val_information5 = hr_api.g_varchar2) then
    p_rec.val_information5 :=
    pqp_val_shd.g_old_rec.val_information5;
  End If;
  If (p_rec.val_information6 = hr_api.g_varchar2) then
    p_rec.val_information6 :=
    pqp_val_shd.g_old_rec.val_information6;
  End If;
  If (p_rec.val_information7 = hr_api.g_varchar2) then
    p_rec.val_information7 :=
    pqp_val_shd.g_old_rec.val_information7;
  End If;
  If (p_rec.val_information8 = hr_api.g_varchar2) then
    p_rec.val_information8 :=
    pqp_val_shd.g_old_rec.val_information8;
  End If;
  If (p_rec.val_information9 = hr_api.g_varchar2) then
    p_rec.val_information9 :=
    pqp_val_shd.g_old_rec.val_information9;
  End If;
  If (p_rec.val_information10 = hr_api.g_varchar2) then
    p_rec.val_information10 :=
    pqp_val_shd.g_old_rec.val_information10;
  End If;
  If (p_rec.val_information11 = hr_api.g_varchar2) then
    p_rec.val_information11 :=
    pqp_val_shd.g_old_rec.val_information11;
  End If;
  If (p_rec.val_information12 = hr_api.g_varchar2) then
    p_rec.val_information12 :=
    pqp_val_shd.g_old_rec.val_information12;
  End If;
  If (p_rec.val_information13 = hr_api.g_varchar2) then
    p_rec.val_information13 :=
    pqp_val_shd.g_old_rec.val_information13;
  End If;
  If (p_rec.val_information14 = hr_api.g_varchar2) then
    p_rec.val_information14 :=
    pqp_val_shd.g_old_rec.val_information14;
  End If;
  If (p_rec.val_information15 = hr_api.g_varchar2) then
    p_rec.val_information15 :=
    pqp_val_shd.g_old_rec.val_information15;
  End If;
  If (p_rec.val_information16 = hr_api.g_varchar2) then
    p_rec.val_information16 :=
    pqp_val_shd.g_old_rec.val_information16;
  End If;
  If (p_rec.val_information17 = hr_api.g_varchar2) then
    p_rec.val_information17 :=
    pqp_val_shd.g_old_rec.val_information17;
  End If;
  If (p_rec.val_information18 = hr_api.g_varchar2) then
    p_rec.val_information18 :=
    pqp_val_shd.g_old_rec.val_information18;
  End If;
  If (p_rec.val_information19 = hr_api.g_varchar2) then
    p_rec.val_information19 :=
    pqp_val_shd.g_old_rec.val_information19;
  End If;
  If (p_rec.val_information20 = hr_api.g_varchar2) then
    p_rec.val_information20 :=
    pqp_val_shd.g_old_rec.val_information20;
  End If;
  If (p_rec.fuel_benefit = hr_api.g_varchar2) then
    p_rec.fuel_benefit :=
    pqp_val_shd.g_old_rec.fuel_benefit;
  End If;
  If (p_rec.sliding_rates_info = hr_api.g_varchar2) then
    p_rec.sliding_rates_info :=
    pqp_val_shd.g_old_rec.sliding_rates_info;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_val_shd.g_rec_type
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
  pqp_val_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_vehicle_allocation_id            => p_rec.vehicle_allocation_id
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
  pqp_val_upd.convert_defs(p_rec);
  --
  pqp_val_bus.update_validate
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
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number
  ,p_business_group_id            in     number
  ,p_vehicle_repository_id        in     number
  ,p_across_assignments           in     varchar2
  ,p_usage_type                   in     varchar2
  ,p_capital_contribution         in     number
  ,p_private_contribution         in     number
  ,p_default_vehicle              in     varchar2
  ,p_fuel_card                    in     varchar2
  ,p_fuel_card_number             in     varchar2
  ,p_calculation_method           in     varchar2
  ,p_rates_table_id               in     number
  ,p_element_type_id              in     number
  ,p_private_use_flag             in     varchar2
  ,p_insurance_number             in     varchar2
  ,p_insurance_expiry_date        in     date
  ,p_val_attribute_category       in     varchar2
  ,p_val_attribute1               in     varchar2
  ,p_val_attribute2               in     varchar2
  ,p_val_attribute3               in     varchar2
  ,p_val_attribute4               in     varchar2
  ,p_val_attribute5               in     varchar2
  ,p_val_attribute6               in     varchar2
  ,p_val_attribute7               in     varchar2
  ,p_val_attribute8               in     varchar2
  ,p_val_attribute9               in     varchar2
  ,p_val_attribute10              in     varchar2
  ,p_val_attribute11              in     varchar2
  ,p_val_attribute12              in     varchar2
  ,p_val_attribute13              in     varchar2
  ,p_val_attribute14              in     varchar2
  ,p_val_attribute15              in     varchar2
  ,p_val_attribute16              in     varchar2
  ,p_val_attribute17              in     varchar2
  ,p_val_attribute18              in     varchar2
  ,p_val_attribute19              in     varchar2
  ,p_val_attribute20              in     varchar2
  ,p_val_information_category     in     varchar2
  ,p_val_information1             in     varchar2
  ,p_val_information2             in     varchar2
  ,p_val_information3             in     varchar2
  ,p_val_information4             in     varchar2
  ,p_val_information5             in     varchar2
  ,p_val_information6             in     varchar2
  ,p_val_information7             in     varchar2
  ,p_val_information8             in     varchar2
  ,p_val_information9             in     varchar2
  ,p_val_information10            in     varchar2
  ,p_val_information11            in     varchar2
  ,p_val_information12            in     varchar2
  ,p_val_information13            in     varchar2
  ,p_val_information14            in     varchar2
  ,p_val_information15            in     varchar2
  ,p_val_information16            in     varchar2
  ,p_val_information17            in     varchar2
  ,p_val_information18            in     varchar2
  ,p_val_information19            in     varchar2
  ,p_val_information20            in     varchar2
  ,p_fuel_benefit                 in     varchar2
  ,p_sliding_rates_info           in     varchar2
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ) is
--
  l_rec         pqp_val_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_val_shd.convert_args
    (p_vehicle_allocation_id
    ,null
    ,null
    ,p_assignment_id
    ,p_business_group_id
    ,p_across_assignments
    ,p_vehicle_repository_id
    ,p_usage_type
    ,p_capital_contribution
    ,p_private_contribution
    ,p_default_vehicle
    ,p_fuel_card
    ,p_fuel_card_number
    ,p_calculation_method
    ,p_rates_table_id
    ,p_element_type_id
    ,p_private_use_flag
    ,p_insurance_number
    ,p_insurance_expiry_date
    ,p_val_attribute_category
    ,p_val_attribute1
    ,p_val_attribute2
    ,p_val_attribute3
    ,p_val_attribute4
    ,p_val_attribute5
    ,p_val_attribute6
    ,p_val_attribute7
    ,p_val_attribute8
    ,p_val_attribute9
    ,p_val_attribute10
    ,p_val_attribute11
    ,p_val_attribute12
    ,p_val_attribute13
    ,p_val_attribute14
    ,p_val_attribute15
    ,p_val_attribute16
    ,p_val_attribute17
    ,p_val_attribute18
    ,p_val_attribute19
    ,p_val_attribute20
    ,p_val_information_category
    ,p_val_information1
    ,p_val_information2
    ,p_val_information3
    ,p_val_information4
    ,p_val_information5
    ,p_val_information6
    ,p_val_information7
    ,p_val_information8
    ,p_val_information9
    ,p_val_information10
    ,p_val_information11
    ,p_val_information12
    ,p_val_information13
    ,p_val_information14
    ,p_val_information15
    ,p_val_information16
    ,p_val_information17
    ,p_val_information18
    ,p_val_information19
    ,p_val_information20
    ,p_object_version_number
    ,p_fuel_benefit
    ,p_sliding_rates_info
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_val_upd.upd
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
end pqp_val_upd;

/
