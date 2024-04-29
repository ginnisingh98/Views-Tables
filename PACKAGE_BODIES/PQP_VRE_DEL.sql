--------------------------------------------------------
--  DDL for Package Body PQP_VRE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRE_DEL" AS
/* $Header: pqvrerhi.pkb 120.0.12010000.2 2008/08/08 07:23:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vre_del.';  -- Global package name
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
--   2) IF the delete mode is DELETE_NEXT_CHANGE then delete where the
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
PROCEDURE dt_delete_dml
  (p_rec                     IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date          IN DATE
  ,p_datetrack_mode          IN VARCHAR2
  ,p_validation_start_date   IN DATE
  ,p_validation_end_date     IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  IF (p_datetrack_mode = hr_api.g_delete_next_change) THEN
    --
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    DELETE
      FROM pqp_vehicle_repository_f
     WHERE vehicle_repository_id = p_rec.vehicle_repository_id
       AND effective_start_date = p_validation_start_date;
    --
    --
  Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pqp_vehicle_repository_f
    where        vehicle_repository_id = p_rec.vehicle_repository_id
    and   effective_start_date >= p_validation_start_date;
    --
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_dml
  (p_rec                     IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date          IN DATE
  ,p_datetrack_mode          IN VARCHAR2
  ,p_validation_start_date   IN DATE
  ,p_validation_end_date     IN DATE
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_vre_del.dt_delete_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END delete_dml;
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
PROCEDURE dt_pre_delete
  (p_rec                     IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date          IN DATE
  ,p_datetrack_mode          IN VARCHAR2
  ,p_validation_start_date   IN DATE
  ,p_validation_end_date     IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF (p_datetrack_mode <> hr_api.g_zap) THEN
    --
    p_rec.effective_start_date
      := pqp_vre_shd.g_old_rec.effective_start_date;
    --
    IF (p_datetrack_mode = hr_api.g_delete) THEN
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    END IF;
    --
    -- Update the current effective end date record
    --
    pqp_vre_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.vehicle_repository_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
  ELSE
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END dt_pre_delete;
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
PROCEDURE pre_delete
  (p_rec                   IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
 cursor c_get_id (cp_vehicle_repository_id number)
 is
 select pve.veh_repos_extra_info_id
       ,pve.object_version_number
   from pqp_veh_repos_extra_info pve
  where pve.vehicle_repository_id = cp_vehicle_repository_id;

--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_vre_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  -- Delete the rows from the table pqp_veh_repos_extra_info when the
  -- vehicle is being purged from vehicle rep. table.
  --
  If p_datetrack_mode ='ZAP' Then
    For vri_rec in  c_get_id (p_rec.vehicle_repository_id)
    Loop
     pqp_veh_repos_extra_info_api.delete_veh_repos_extra_info
     (p_veh_repos_extra_info_id  => vri_rec.veh_repos_extra_info_id
     ,p_object_version_number    => vri_rec.object_version_number
     );
    End Loop;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_delete;
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
PROCEDURE post_delete
  (p_rec                   in pqp_vre_shd.g_rec_type
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
    pqp_vre_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_vehicle_repository_id
      => p_rec.vehicle_repository_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_effective_start_date_o
      => pqp_vre_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqp_vre_shd.g_old_rec.effective_end_date
      ,p_registration_number_o
      => pqp_vre_shd.g_old_rec.registration_number
      ,p_vehicle_type_o
      => pqp_vre_shd.g_old_rec.vehicle_type
      ,p_vehicle_id_number_o
      => pqp_vre_shd.g_old_rec.vehicle_id_number
      ,p_business_group_id_o
      => pqp_vre_shd.g_old_rec.business_group_id
      ,p_make_o
      => pqp_vre_shd.g_old_rec.make
      ,p_model_o
      => pqp_vre_shd.g_old_rec.model
      ,p_initial_registration_o
      => pqp_vre_shd.g_old_rec.initial_registration
      ,p_last_registration_renew_da_o
      => pqp_vre_shd.g_old_rec.last_registration_renew_date
      ,p_engine_capacity_in_cc_o
      => pqp_vre_shd.g_old_rec.engine_capacity_in_cc
      ,p_fuel_type_o
      => pqp_vre_shd.g_old_rec.fuel_type
      ,p_currency_code_o
      => pqp_vre_shd.g_old_rec.currency_code
      ,p_list_price_o
      => pqp_vre_shd.g_old_rec.list_price
      ,p_accessory_value_at_startda_o
      => pqp_vre_shd.g_old_rec.accessory_value_at_startdate
      ,p_accessory_value_added_late_o
      => pqp_vre_shd.g_old_rec.accessory_value_added_later
      ,p_market_value_classic_car_o
      => pqp_vre_shd.g_old_rec.market_value_classic_car
      ,p_fiscal_ratings_o
      => pqp_vre_shd.g_old_rec.fiscal_ratings
      ,p_fiscal_ratings_uom_o
      => pqp_vre_shd.g_old_rec.fiscal_ratings_uom
      ,p_vehicle_provider_o
      => pqp_vre_shd.g_old_rec.vehicle_provider
      ,p_vehicle_ownership_o
      => pqp_vre_shd.g_old_rec.vehicle_ownership
      ,p_shared_vehicle_o
      => pqp_vre_shd.g_old_rec.shared_vehicle
      ,p_vehicle_status_o
      => pqp_vre_shd.g_old_rec.vehicle_status
      ,p_vehicle_inactivity_reason_o
      => pqp_vre_shd.g_old_rec.vehicle_inactivity_reason
      ,p_asset_number_o
      => pqp_vre_shd.g_old_rec.asset_number
      ,p_lease_contract_number_o
      => pqp_vre_shd.g_old_rec.lease_contract_number
      ,p_lease_contract_expiry_date_o
      => pqp_vre_shd.g_old_rec.lease_contract_expiry_date
      ,p_taxation_method_o
      => pqp_vre_shd.g_old_rec.taxation_method
      ,p_fleet_info_o
      => pqp_vre_shd.g_old_rec.fleet_info
      ,p_fleet_transfer_date_o
      => pqp_vre_shd.g_old_rec.fleet_transfer_date
      ,p_object_version_number_o
      => pqp_vre_shd.g_old_rec.object_version_number
      ,p_color_o
      => pqp_vre_shd.g_old_rec.color
      ,p_seating_capacity_o
      => pqp_vre_shd.g_old_rec.seating_capacity
      ,p_weight_o
      => pqp_vre_shd.g_old_rec.weight
      ,p_weight_uom_o
      => pqp_vre_shd.g_old_rec.weight_uom
      ,p_model_year_o
      => pqp_vre_shd.g_old_rec.model_year
      ,p_insurance_number_o
      => pqp_vre_shd.g_old_rec.insurance_number
      ,p_insurance_expiry_date_o
      => pqp_vre_shd.g_old_rec.insurance_expiry_date
      ,p_comments_o
      => pqp_vre_shd.g_old_rec.comments
      ,p_vre_attribute_category_o
      => pqp_vre_shd.g_old_rec.vre_attribute_category
      ,p_vre_attribute1_o
      => pqp_vre_shd.g_old_rec.vre_attribute1
      ,p_vre_attribute2_o
      => pqp_vre_shd.g_old_rec.vre_attribute2
      ,p_vre_attribute3_o
      => pqp_vre_shd.g_old_rec.vre_attribute3
      ,p_vre_attribute4_o
      => pqp_vre_shd.g_old_rec.vre_attribute4
      ,p_vre_attribute5_o
      => pqp_vre_shd.g_old_rec.vre_attribute5
      ,p_vre_attribute6_o
      => pqp_vre_shd.g_old_rec.vre_attribute6
      ,p_vre_attribute7_o
      => pqp_vre_shd.g_old_rec.vre_attribute7
      ,p_vre_attribute8_o
      => pqp_vre_shd.g_old_rec.vre_attribute8
      ,p_vre_attribute9_o
      => pqp_vre_shd.g_old_rec.vre_attribute9
      ,p_vre_attribute10_o
      => pqp_vre_shd.g_old_rec.vre_attribute10
      ,p_vre_attribute11_o
      => pqp_vre_shd.g_old_rec.vre_attribute11
      ,p_vre_attribute12_o
      => pqp_vre_shd.g_old_rec.vre_attribute12
      ,p_vre_attribute13_o
      => pqp_vre_shd.g_old_rec.vre_attribute13
      ,p_vre_attribute14_o
      => pqp_vre_shd.g_old_rec.vre_attribute14
      ,p_vre_attribute15_o
      => pqp_vre_shd.g_old_rec.vre_attribute15
      ,p_vre_attribute16_o
      => pqp_vre_shd.g_old_rec.vre_attribute16
      ,p_vre_attribute17_o
      => pqp_vre_shd.g_old_rec.vre_attribute17
      ,p_vre_attribute18_o
      => pqp_vre_shd.g_old_rec.vre_attribute18
      ,p_vre_attribute19_o
      => pqp_vre_shd.g_old_rec.vre_attribute19
      ,p_vre_attribute20_o
      => pqp_vre_shd.g_old_rec.vre_attribute20
      ,p_vre_information_category_o
      => pqp_vre_shd.g_old_rec.vre_information_category
      ,p_vre_information1_o
      => pqp_vre_shd.g_old_rec.vre_information1
      ,p_vre_information2_o
      => pqp_vre_shd.g_old_rec.vre_information2
      ,p_vre_information3_o
      => pqp_vre_shd.g_old_rec.vre_information3
      ,p_vre_information4_o
      => pqp_vre_shd.g_old_rec.vre_information4
      ,p_vre_information5_o
      => pqp_vre_shd.g_old_rec.vre_information5
      ,p_vre_information6_o
      => pqp_vre_shd.g_old_rec.vre_information6
      ,p_vre_information7_o
      => pqp_vre_shd.g_old_rec.vre_information7
      ,p_vre_information8_o
      => pqp_vre_shd.g_old_rec.vre_information8
      ,p_vre_information9_o
      => pqp_vre_shd.g_old_rec.vre_information9
      ,p_vre_information10_o
      => pqp_vre_shd.g_old_rec.vre_information10
      ,p_vre_information11_o
      => pqp_vre_shd.g_old_rec.vre_information11
      ,p_vre_information12_o
      => pqp_vre_shd.g_old_rec.vre_information12
      ,p_vre_information13_o
      => pqp_vre_shd.g_old_rec.vre_information13
      ,p_vre_information14_o
      => pqp_vre_shd.g_old_rec.vre_information14
      ,p_vre_information15_o
      => pqp_vre_shd.g_old_rec.vre_information15
      ,p_vre_information16_o
      => pqp_vre_shd.g_old_rec.vre_information16
      ,p_vre_information17_o
      => pqp_vre_shd.g_old_rec.vre_information17
      ,p_vre_information18_o
      => pqp_vre_shd.g_old_rec.vre_information18
      ,p_vre_information19_o
      => pqp_vre_shd.g_old_rec.vre_information19
      ,p_vre_information20_o
      => pqp_vre_shd.g_old_rec.vre_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_F'
        ,p_hook_type   => 'AD');
      --
  end;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE del
  (p_effective_date IN     DATE
  ,p_datetrack_mode IN     VARCHAR2
  ,p_rec            IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ) IS
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
  pqp_vre_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_vehicle_repository_id            => p_rec.vehicle_repository_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  pqp_vre_bus.delete_validate
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
  pqp_vre_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pqp_vre_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pqp_vre_del.post_delete
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
PROCEDURE del
  (p_effective_date                   IN     DATE
  ,p_datetrack_mode                   IN     VARCHAR2
  ,p_vehicle_repository_id            IN     NUMBER
  ,p_object_version_number            IN OUT NOCOPY NUMBER
  ,p_effective_start_date             OUT    NOCOPY DATE
  ,p_effective_end_date               OUT    NOCOPY DATE
  ) IS
--
  l_rec         pqp_vre_shd.g_rec_type;
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
  l_rec.vehicle_repository_id          := p_vehicle_repository_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_vre_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_vre_del.del
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
end pqp_vre_del;

/
