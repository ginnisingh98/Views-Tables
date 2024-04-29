--------------------------------------------------------
--  DDL for Package Body PQP_VAL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAL_DEL" as
/* $Header: pqvalrhi.pkb 120.0.12010000.3 2008/08/08 07:22:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_val_del.';  -- Global package name
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
  (p_rec                     in out nocopy pqp_val_shd.g_rec_type
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
    --
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pqp_vehicle_allocations_f
    where       vehicle_allocation_id = p_rec.vehicle_allocation_id
    and   effective_start_date = p_validation_start_date;
    --
    --
  Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pqp_vehicle_allocations_f
    where        vehicle_allocation_id = p_rec.vehicle_allocation_id
    and   effective_start_date >= p_validation_start_date;
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pqp_val_shd.g_rec_type
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
  pqp_val_del.dt_delete_dml
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
  (p_rec                     in out nocopy pqp_val_shd.g_rec_type
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
      := pqp_val_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pqp_val_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.vehicle_allocation_id
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
  (p_rec                   in out nocopy pqp_val_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc             varchar2(72) := g_package||'pre_delete';
  l_legislation_code varchar2(10);
--
 cursor c_get_extra_info
        (cp_vehicle_allocation_id number) is
 select pva.veh_alloc_extra_info_id
       ,pva.object_version_number
   from pqp_veh_alloc_extra_info pva
  where pva.vehicle_allocation_id = cp_vehicle_allocation_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_val_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  l_legislation_code := pqp_vre_bus.get_legislation_code
                        (pqp_val_shd.g_old_rec.business_group_id);
  --
  If l_legislation_code = 'GB' Then
     Begin
      pqp_val_bus.del_ni_car_entry
      (p_business_group_id => pqp_val_shd.g_old_rec.business_group_id
      ,p_assignment_id     => pqp_val_shd.g_old_rec.assignment_id
      ,p_allocation_id     => p_rec.vehicle_allocation_id
      ,p_effective_date    => p_effective_date
       );
     Exception
       When others Then
       Null;
     End ;
  End if;
  --
  -- Purge the child rows from the table pqp_veh_alloc_extra_info table
  -- for the corresponding vehicle allocation id.
  --
  If p_datetrack_mode = hr_api.g_zap Then
     Begin
       For vxi_rec in c_get_extra_info (p_rec.vehicle_allocation_id)
       Loop
         pqp_veh_alloc_extra_info_api.delete_veh_alloc_extra_info
         (p_veh_alloc_extra_info_id => vxi_rec.veh_alloc_extra_info_id
         ,p_object_version_number   => vxi_rec.object_version_number
         );
       End Loop;
     Exception
       When Others Then
        hr_utility.set_location(' exception:'||l_proc, 9);
        Null;
     End;
  End If;
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
  (p_rec                   in pqp_val_shd.g_rec_type
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
    pqp_val_rkd.after_delete
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
        ,p_hook_type   => 'AD');
      --
  end;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_val_shd.g_rec_type
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
  pqp_val_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_vehicle_allocation_id            => p_rec.vehicle_allocation_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  pqp_val_bus.delete_validate
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
  pqp_val_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );


  --
  -- Delete the row.
  --



  pqp_val_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );


  -- Call the supporting post-delete operation
  --
  pqp_val_del.post_delete
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
  ,p_vehicle_allocation_id            in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
--
  l_rec         pqp_val_shd.g_rec_type;
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
  l_rec.vehicle_allocation_id     := p_vehicle_allocation_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_val_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_val_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
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
end pqp_val_del;

/
