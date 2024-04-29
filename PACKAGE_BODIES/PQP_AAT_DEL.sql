--------------------------------------------------------
--  DDL for Package Body PQP_AAT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAT_DEL" as
/* $Header: pqaatrhi.pkb 120.2.12010000.3 2009/07/01 10:58:37 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package  varchar2(33) := '  pqp_aat_del.';  -- Global package name
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure dt_delete_dml
  (p_rec                     in out nocopy pqp_aat_shd.g_rec_type
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
    pqp_aat_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pqp_assignment_attributes_f
    where       assignment_attribute_id = p_rec.assignment_attribute_id
    and   effective_start_date = p_validation_start_date;
    --
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    pqp_aat_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pqp_assignment_attributes_f
    where        assignment_attribute_id = p_rec.assignment_attribute_id
    and   effective_start_date >= p_validation_start_date;
    --
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< delete_dml >------------------------------|
-- ---------------------------------------------------------------------------+
Procedure delete_dml
  (p_rec                     in out nocopy pqp_aat_shd.g_rec_type
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
  pqp_aat_del.dt_delete_dml
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
-- ---------------------------------------------------------------------------+
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure dt_pre_delete
  (p_rec                     in out nocopy pqp_aat_shd.g_rec_type
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
      := pqp_aat_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pqp_aat_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.assignment_attribute_id
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
-- ---------------------------------------------------------------------------+
-- |------------------------------< pre_delete >------------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure pre_delete
  (p_rec                   in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--
  --
  pqp_aat_del.dt_pre_delete
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
-- ---------------------------------------------------------------------------+
-- |----------------------------< post_delete >-------------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure post_delete
  (p_rec                   in pqp_aat_shd.g_rec_type
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
    pqp_aat_rkd.after_delete
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
     ,p_tp_headteacher_grp_code_o   --added for head Teacher seconded location for salary scale calculation
     => pqp_aat_shd.g_old_rec.tp_headteacher_grp_code
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< del >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure del
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_aat_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
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
  -- Call the supporting delete validate operation
  --
  pqp_aat_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-delete operation
  --
  pqp_aat_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pqp_aat_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pqp_aat_del.post_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 5);
End del;
--
-- ---------------------------------------------------------------------------+
-- |--------------------------------< del >-----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure del
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_assignment_attribute_id          in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ) is
--
  l_rec         pqp_aat_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.assignment_attribute_id         := p_assignment_attribute_id;
  l_rec.object_version_number   := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_aat_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_aat_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
  -- Set the out arguments
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_aat_del;

/
