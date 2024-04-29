--------------------------------------------------------
--  DDL for Package Body PQP_VRE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRE_UPD" AS
/* $Header: pqvrerhi.pkb 120.0.12010000.2 2008/08/08 07:23:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pqp_vre_upd.';  -- Global package name
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
PROCEDURE dt_update_dml
  (p_rec                   IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF (p_datetrack_mode = hr_api.g_correction) THEN
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'pqp_vehicle_repository_f'
        ,p_base_key_column => 'vehicle_repository_id'
        ,p_base_key_value  => p_rec.vehicle_repository_id
        );
    --
    --
    --
    -- Update the pqp_vehicle_repository_f Row
    --
    UPDATE  pqp_vehicle_repository_f
    SET
     vehicle_repository_id                = p_rec.vehicle_repository_id
    ,registration_number                  = p_rec.registration_number
    ,vehicle_type                         = p_rec.vehicle_type
    ,vehicle_id_number                    = p_rec.vehicle_id_number
    ,business_group_id                    = p_rec.business_group_id
    ,make                                 = p_rec.make
    ,model                                = p_rec.model
    ,initial_registration                 = p_rec.initial_registration
    ,last_registration_renew_date         = p_rec.last_registration_renew_date
    ,engine_capacity_in_cc                = p_rec.engine_capacity_in_cc
    ,fuel_type                            = p_rec.fuel_type
    ,currency_code                        = p_rec.currency_code
    ,list_price                           = p_rec.list_price
    ,accessory_value_at_startdate         = p_rec.accessory_value_at_startdate
    ,accessory_value_added_later          = p_rec.accessory_value_added_later
    ,market_value_classic_car             = p_rec.market_value_classic_car
    ,fiscal_ratings                       = p_rec.fiscal_ratings
    ,fiscal_ratings_uom                   = p_rec.fiscal_ratings_uom
    ,vehicle_provider                     = p_rec.vehicle_provider
    ,vehicle_ownership                    = p_rec.vehicle_ownership
    ,shared_vehicle                       = p_rec.shared_vehicle
    ,vehicle_status                       = p_rec.vehicle_status
    ,vehicle_inactivity_reason            = p_rec.vehicle_inactivity_reason
    ,asset_number                         = p_rec.asset_number
    ,lease_contract_number                = p_rec.lease_contract_number
    ,lease_contract_expiry_date           = p_rec.lease_contract_expiry_date
    ,taxation_method                      = p_rec.taxation_method
    ,fleet_info                           = p_rec.fleet_info
    ,fleet_transfer_date                  = p_rec.fleet_transfer_date
    ,object_version_number                = p_rec.object_version_number
    ,color                                = p_rec.color
    ,seating_capacity                     = p_rec.seating_capacity
    ,weight                               = p_rec.weight
    ,weight_uom                            = p_rec.weight_uom
    ,model_year                           = p_rec.model_year
    ,insurance_number                     = p_rec.insurance_number
    ,insurance_expiry_date                = p_rec.insurance_expiry_date
    ,comments                             = p_rec.comments
    ,vre_attribute_category               = p_rec.vre_attribute_category
    ,vre_attribute1                       = p_rec.vre_attribute1
    ,vre_attribute2                       = p_rec.vre_attribute2
    ,vre_attribute3                       = p_rec.vre_attribute3
    ,vre_attribute4                       = p_rec.vre_attribute4
    ,vre_attribute5                       = p_rec.vre_attribute5
    ,vre_attribute6                       = p_rec.vre_attribute6
    ,vre_attribute7                       = p_rec.vre_attribute7
    ,vre_attribute8                       = p_rec.vre_attribute8
    ,vre_attribute9                       = p_rec.vre_attribute9
    ,vre_attribute10                      = p_rec.vre_attribute10
    ,vre_attribute11                      = p_rec.vre_attribute11
    ,vre_attribute12                      = p_rec.vre_attribute12
    ,vre_attribute13                      = p_rec.vre_attribute13
    ,vre_attribute14                      = p_rec.vre_attribute14
    ,vre_attribute15                      = p_rec.vre_attribute15
    ,vre_attribute16                      = p_rec.vre_attribute16
    ,vre_attribute17                      = p_rec.vre_attribute17
    ,vre_attribute18                      = p_rec.vre_attribute18
    ,vre_attribute19                      = p_rec.vre_attribute19
    ,vre_attribute20                      = p_rec.vre_attribute20
    ,vre_information_category             = p_rec.vre_information_category
    ,vre_information1                     = p_rec.vre_information1
    ,vre_information2                     = p_rec.vre_information2
    ,vre_information3                     = p_rec.vre_information3
    ,vre_information4                     = p_rec.vre_information4
    ,vre_information5                     = p_rec.vre_information5
    ,vre_information6                     = p_rec.vre_information6
    ,vre_information7                     = p_rec.vre_information7
    ,vre_information8                     = p_rec.vre_information8
    ,vre_information9                     = p_rec.vre_information9
    ,vre_information10                    = p_rec.vre_information10
    ,vre_information11                    = p_rec.vre_information11
    ,vre_information12                    = p_rec.vre_information12
    ,vre_information13                    = p_rec.vre_information13
    ,vre_information14                    = p_rec.vre_information14
    ,vre_information15                    = p_rec.vre_information15
    ,vre_information16                    = p_rec.vre_information16
    ,vre_information17                    = p_rec.vre_information17
    ,vre_information18                    = p_rec.vre_information18
    ,vre_information19                    = p_rec.vre_information19
    ,vre_information20                    = p_rec.vre_information20
    WHERE   vehicle_repository_id = p_rec.vehicle_repository_id
    AND     effective_start_date  = p_validation_start_date
    AND     effective_end_date    = p_validation_end_date;
    --
    --
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  END IF;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
EXCEPTION
  WHEN hr_api.check_integrity_violated THEN
    -- A check constraint has been violated
    --
    pqp_vre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.unique_integrity_violated THEN
    -- Unique integrity has been violated
    --
    pqp_vre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN OTHERS THEN
    --
    RAISE;
END dt_update_dml;
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
PROCEDURE update_dml
  (p_rec                      IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date           IN DATE
  ,p_datetrack_mode           IN VARCHAR2
  ,p_validation_start_date    IN DATE
  ,p_validation_end_date      IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_vre_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END update_dml;
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
PROCEDURE dt_pre_update
  (p_rec                     IN OUT  NOCOPY   pqp_vre_shd.g_rec_type
  ,p_effective_date          IN DATE
  ,p_datetrack_mode          IN VARCHAR2
  ,p_validation_start_date   IN DATE
  ,p_validation_end_date     IN DATE
  ) IS
--
  l_proc                 VARCHAR2(72) := g_package||'dt_pre_update';
  l_dummy_version_number NUMBER;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  IF (p_datetrack_mode <> hr_api.g_correction) THEN
    --
    -- Update the current effective end date
    --
    pqp_vre_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.vehicle_repository_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    IF (p_datetrack_mode = hr_api.g_update_override) THEN
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pqp_vre_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
    END IF;
    --
    -- We must now insert the updated row
    --
    pqp_vre_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END dt_pre_update;
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
PROCEDURE pre_update
  (p_rec                   IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
BEGIN
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
END pre_update;
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
PROCEDURE post_update
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'post_update';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    --
    pqp_vre_rku.after_update
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
      ,p_registration_number
      => p_rec.registration_number
      ,p_vehicle_type
      => p_rec.vehicle_type
      ,p_vehicle_id_number
      => p_rec.vehicle_id_number
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_make
      => p_rec.make
      ,p_model
      => p_rec.model
      ,p_initial_registration
      => p_rec.initial_registration
      ,p_last_registration_renew_date
      => p_rec.last_registration_renew_date
      ,p_engine_capacity_in_cc
      => p_rec.engine_capacity_in_cc
      ,p_fuel_type
      => p_rec.fuel_type
      ,p_currency_code
      => p_rec.currency_code
      ,p_list_price
      => p_rec.list_price
      ,p_accessory_value_at_startdate
      => p_rec.accessory_value_at_startdate
      ,p_accessory_value_added_later
      => p_rec.accessory_value_added_later
      ,p_market_value_classic_car
      => p_rec.market_value_classic_car
      ,p_fiscal_ratings
      => p_rec.fiscal_ratings
      ,p_fiscal_ratings_uom
      => p_rec.fiscal_ratings_uom
      ,p_vehicle_provider
      => p_rec.vehicle_provider
      ,p_vehicle_ownership
      => p_rec.vehicle_ownership
      ,p_shared_vehicle
      => p_rec.shared_vehicle
      ,p_vehicle_status
      => p_rec.vehicle_status
      ,p_vehicle_inactivity_reason
      => p_rec.vehicle_inactivity_reason
      ,p_asset_number
      => p_rec.asset_number
      ,p_lease_contract_number
      => p_rec.lease_contract_number
      ,p_lease_contract_expiry_date
      =>p_rec.lease_contract_expiry_date
      ,p_taxation_method
      => p_rec.taxation_method
      ,p_fleet_info
      => p_rec.fleet_info
      ,p_fleet_transfer_date
      => p_rec.fleet_transfer_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_color
      => p_rec.color
      ,p_seating_capacity
      => p_rec.seating_capacity
      ,p_weight
      => p_rec.weight
      ,p_weight_uom
      => p_rec.weight_uom
      ,p_model_year
      => p_rec.model_year
      ,p_insurance_number
      => p_rec.insurance_number
      ,p_insurance_expiry_date
      => p_rec.insurance_expiry_date
      ,p_comments
      => p_rec.comments
      ,p_vre_attribute_category
      => p_rec.vre_attribute_category
      ,p_vre_attribute1
      => p_rec.vre_attribute1
      ,p_vre_attribute2
      => p_rec.vre_attribute2
      ,p_vre_attribute3
      => p_rec.vre_attribute3
      ,p_vre_attribute4
      => p_rec.vre_attribute4
      ,p_vre_attribute5
      => p_rec.vre_attribute5
      ,p_vre_attribute6
      => p_rec.vre_attribute6
      ,p_vre_attribute7
      => p_rec.vre_attribute7
      ,p_vre_attribute8
      => p_rec.vre_attribute8
      ,p_vre_attribute9
      => p_rec.vre_attribute9
      ,p_vre_attribute10
      => p_rec.vre_attribute10
      ,p_vre_attribute11
      => p_rec.vre_attribute11
      ,p_vre_attribute12
      => p_rec.vre_attribute12
      ,p_vre_attribute13
      => p_rec.vre_attribute13
      ,p_vre_attribute14
      => p_rec.vre_attribute14
      ,p_vre_attribute15
      => p_rec.vre_attribute15
      ,p_vre_attribute16
      => p_rec.vre_attribute16
      ,p_vre_attribute17
      => p_rec.vre_attribute17
      ,p_vre_attribute18
      => p_rec.vre_attribute18
      ,p_vre_attribute19
      => p_rec.vre_attribute19
      ,p_vre_attribute20
      => p_rec.vre_attribute20
      ,p_vre_information_category
      => p_rec.vre_information_category
      ,p_vre_information1
      => p_rec.vre_information1
      ,p_vre_information2
      => p_rec.vre_information2
      ,p_vre_information3
      => p_rec.vre_information3
      ,p_vre_information4
      => p_rec.vre_information4
      ,p_vre_information5
      => p_rec.vre_information5
      ,p_vre_information6
      => p_rec.vre_information6
      ,p_vre_information7
      => p_rec.vre_information7
      ,p_vre_information8
      => p_rec.vre_information8
      ,p_vre_information9
      => p_rec.vre_information9
      ,p_vre_information10
      => p_rec.vre_information10
      ,p_vre_information11
      => p_rec.vre_information11
      ,p_vre_information12
      => p_rec.vre_information12
      ,p_vre_information13
      => p_rec.vre_information13
      ,p_vre_information14
      => p_rec.vre_information14
      ,p_vre_information15
      => p_rec.vre_information15
      ,p_vre_information16
      => p_rec.vre_information16
      ,p_vre_information17
      => p_rec.vre_information17
      ,p_vre_information18
      => p_rec.vre_information18
      ,p_vre_information19
      => p_rec.vre_information19
      ,p_vre_information20
      => p_rec.vre_information20
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
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_F'
        ,p_hook_type   => 'AU');
      --
  END;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_update;
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
PROCEDURE convert_defs
  (p_rec in out nocopy pqp_vre_shd.g_rec_type
  ) IS
--
BEGIN
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  IF (p_rec.registration_number = hr_api.g_varchar2) THEN
      p_rec.registration_number :=
      pqp_vre_shd.g_old_rec.registration_number;
  END IF;
  IF (p_rec.vehicle_type = hr_api.g_varchar2) THEN
      p_rec.vehicle_type :=
      pqp_vre_shd.g_old_rec.vehicle_type;
  END IF;
  IF (p_rec.vehicle_id_number = hr_api.g_varchar2) THEN
      p_rec.vehicle_id_number :=
      pqp_vre_shd.g_old_rec.vehicle_id_number;
  END IF;
  IF (p_rec.business_group_id = hr_api.g_number) THEN
      p_rec.business_group_id :=
      pqp_vre_shd.g_old_rec.business_group_id;
  END IF;
  IF (p_rec.make = hr_api.g_varchar2) THEN
      p_rec.make :=
      pqp_vre_shd.g_old_rec.make;
  END IF;
  IF (p_rec.model = hr_api.g_varchar2) THEN
      p_rec.model :=
      pqp_vre_shd.g_old_rec.model;
  END IF;
  IF (p_rec.initial_registration = hr_api.g_date) THEN
      p_rec.initial_registration :=
      pqp_vre_shd.g_old_rec.initial_registration;
  END IF;
  IF (p_rec.last_registration_renew_date = hr_api.g_date) THEN
      p_rec.last_registration_renew_date :=
      pqp_vre_shd.g_old_rec.last_registration_renew_date;
  END IF;
  IF (p_rec.engine_capacity_in_cc = hr_api.g_number) THEN
      p_rec.engine_capacity_in_cc :=
      pqp_vre_shd.g_old_rec.engine_capacity_in_cc;
  END IF;
  IF (p_rec.fuel_type = hr_api.g_varchar2) THEN
      p_rec.fuel_type :=
      pqp_vre_shd.g_old_rec.fuel_type;
  END IF;
  IF (p_rec.currency_code = hr_api.g_varchar2) THEN
      p_rec.currency_code :=
      pqp_vre_shd.g_old_rec.currency_code;
  END IF;
  IF (p_rec.list_price = hr_api.g_number) THEN
      p_rec.list_price :=
      pqp_vre_shd.g_old_rec.list_price;
  END IF;
  IF (p_rec.accessory_value_at_startdate = hr_api.g_number) THEN
      p_rec.accessory_value_at_startdate :=
      pqp_vre_shd.g_old_rec.accessory_value_at_startdate;
  END IF;
  IF (p_rec.accessory_value_added_later = hr_api.g_number) THEN
      p_rec.accessory_value_added_later :=
      pqp_vre_shd.g_old_rec.accessory_value_added_later;
  END IF;
  IF (p_rec.market_value_classic_car = hr_api.g_number) THEN
      p_rec.market_value_classic_car :=
      pqp_vre_shd.g_old_rec.market_value_classic_car;
  END IF;
  IF (p_rec.fiscal_ratings = hr_api.g_number) THEN
      p_rec.fiscal_ratings :=
      pqp_vre_shd.g_old_rec.fiscal_ratings;
  END IF;
  IF (p_rec.fiscal_ratings_uom = hr_api.g_varchar2) THEN
      p_rec.fiscal_ratings_uom :=
      pqp_vre_shd.g_old_rec.fiscal_ratings_uom;
  END IF;
  IF (p_rec.vehicle_provider = hr_api.g_varchar2) THEN
      p_rec.vehicle_provider :=
      pqp_vre_shd.g_old_rec.vehicle_provider;
  END IF;
  IF (p_rec.vehicle_ownership = hr_api.g_varchar2) THEN
      p_rec.vehicle_ownership :=
      pqp_vre_shd.g_old_rec.vehicle_ownership;
  END IF;
  IF (p_rec.shared_vehicle = hr_api.g_varchar2) THEN
      p_rec.shared_vehicle :=
      pqp_vre_shd.g_old_rec.shared_vehicle;
  END IF;
  IF (p_rec.vehicle_status = hr_api.g_varchar2) THEN
      p_rec.vehicle_status :=
      pqp_vre_shd.g_old_rec.vehicle_status;
  END IF;
  IF (p_rec.vehicle_inactivity_reason = hr_api.g_varchar2) THEN
      p_rec.vehicle_inactivity_reason :=
      pqp_vre_shd.g_old_rec.vehicle_inactivity_reason;
  END IF;
  IF (p_rec.asset_number = hr_api.g_varchar2) THEN
      p_rec.asset_number :=
      pqp_vre_shd.g_old_rec.asset_number;
  END IF;
  IF (p_rec.lease_contract_number = hr_api.g_varchar2) THEN
      p_rec.lease_contract_number :=
      pqp_vre_shd.g_old_rec.lease_contract_number;
  END IF;
  IF (p_rec.lease_contract_expiry_date = hr_api.g_date) THEN
      p_rec.lease_contract_expiry_date :=
      pqp_vre_shd.g_old_rec.lease_contract_expiry_date;
  END IF;
  IF (p_rec.taxation_method = hr_api.g_varchar2) THEN
      p_rec.taxation_method :=
      pqp_vre_shd.g_old_rec.taxation_method;
  END IF;
  IF (p_rec.fleet_info = hr_api.g_varchar2) THEN
      p_rec.fleet_info :=
      pqp_vre_shd.g_old_rec.fleet_info;
  END IF;
  IF (p_rec.fleet_transfer_date = hr_api.g_date) THEN
      p_rec.fleet_transfer_date :=
      pqp_vre_shd.g_old_rec.fleet_transfer_date;
  END IF;
  IF (p_rec.color = hr_api.g_varchar2) THEN
      p_rec.color :=
      pqp_vre_shd.g_old_rec.color;
  END IF;
  IF (p_rec.seating_capacity = hr_api.g_number) THEN
      p_rec.seating_capacity :=
      pqp_vre_shd.g_old_rec.seating_capacity;
  END IF;
  IF (p_rec.weight = hr_api.g_number) THEN
      p_rec.weight :=
      pqp_vre_shd.g_old_rec.weight;
  END IF;
  IF (p_rec.weight_uom = hr_api.g_varchar2) THEN
      p_rec.weight_uom :=
      pqp_vre_shd.g_old_rec.weight_uom;
  END IF;
  IF (p_rec.model_year = hr_api.g_number) THEN
      p_rec.model_year :=
      pqp_vre_shd.g_old_rec.model_year;
  END IF;
  IF (p_rec.insurance_number = hr_api.g_varchar2) THEN
      p_rec.insurance_number :=
      pqp_vre_shd.g_old_rec.insurance_number;
  END IF;
  IF (p_rec.insurance_expiry_date = hr_api.g_date) THEN
      p_rec.insurance_expiry_date :=
      pqp_vre_shd.g_old_rec.insurance_expiry_date;
  END IF;
  IF (p_rec.comments = hr_api.g_varchar2) THEN
      p_rec.comments :=
      pqp_vre_shd.g_old_rec.comments;
  END IF;
  IF (p_rec.vre_attribute_category = hr_api.g_varchar2) THEN
      p_rec.vre_attribute_category :=
      pqp_vre_shd.g_old_rec.vre_attribute_category;
  END IF;
  IF (p_rec.vre_attribute1 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute1 :=
      pqp_vre_shd.g_old_rec.vre_attribute1;
  END IF;
  IF (p_rec.vre_attribute2 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute2 :=
      pqp_vre_shd.g_old_rec.vre_attribute2;
  END IF;
  IF (p_rec.vre_attribute3 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute3 :=
      pqp_vre_shd.g_old_rec.vre_attribute3;
  END IF;
  IF (p_rec.vre_attribute4 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute4 :=
      pqp_vre_shd.g_old_rec.vre_attribute4;
  END IF;
  IF (p_rec.vre_attribute5 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute5 :=
      pqp_vre_shd.g_old_rec.vre_attribute5;
  END IF;
  IF (p_rec.vre_attribute6 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute6 :=
      pqp_vre_shd.g_old_rec.vre_attribute6;
  END IF;
  IF (p_rec.vre_attribute7 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute7 :=
      pqp_vre_shd.g_old_rec.vre_attribute7;
  END IF;
  IF (p_rec.vre_attribute8 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute8 :=
      pqp_vre_shd.g_old_rec.vre_attribute8;
  END IF;
  IF (p_rec.vre_attribute9 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute9 :=
      pqp_vre_shd.g_old_rec.vre_attribute9;
  END IF;
  IF (p_rec.vre_attribute10 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute10 :=
      pqp_vre_shd.g_old_rec.vre_attribute10;
  END IF;
  IF (p_rec.vre_attribute11 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute11 :=
      pqp_vre_shd.g_old_rec.vre_attribute11;
  END IF;
  IF (p_rec.vre_attribute12 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute12 :=
      pqp_vre_shd.g_old_rec.vre_attribute12;
  END IF;
  IF (p_rec.vre_attribute13 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute13 :=
      pqp_vre_shd.g_old_rec.vre_attribute13;
  END IF;
  IF (p_rec.vre_attribute14 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute14 :=
      pqp_vre_shd.g_old_rec.vre_attribute14;
  END IF;
  IF (p_rec.vre_attribute15 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute15 :=
      pqp_vre_shd.g_old_rec.vre_attribute15;
  END IF;
  IF (p_rec.vre_attribute16 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute16 :=
      pqp_vre_shd.g_old_rec.vre_attribute16;
  END IF;
  IF (p_rec.vre_attribute17 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute17 :=
      pqp_vre_shd.g_old_rec.vre_attribute17;
  END IF;
  IF (p_rec.vre_attribute18 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute18 :=
      pqp_vre_shd.g_old_rec.vre_attribute18;
  END IF;
  IF (p_rec.vre_attribute19 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute19 :=
      pqp_vre_shd.g_old_rec.vre_attribute19;
  END IF;
  IF (p_rec.vre_attribute20 = hr_api.g_varchar2) THEN
      p_rec.vre_attribute20 :=
      pqp_vre_shd.g_old_rec.vre_attribute20;
  END IF;
  IF (p_rec.vre_information_category = hr_api.g_varchar2) THEN
      p_rec.vre_information_category :=
      pqp_vre_shd.g_old_rec.vre_information_category;
  END IF;
  IF (p_rec.vre_information1 = hr_api.g_varchar2) THEN
      p_rec.vre_information1 :=
      pqp_vre_shd.g_old_rec.vre_information1;
  END IF;
  IF (p_rec.vre_information2 = hr_api.g_varchar2) THEN
      p_rec.vre_information2 :=
      pqp_vre_shd.g_old_rec.vre_information2;
  END IF;
  IF (p_rec.vre_information3 = hr_api.g_varchar2) THEN
      p_rec.vre_information3 :=
      pqp_vre_shd.g_old_rec.vre_information3;
  END IF;
  IF (p_rec.vre_information4 = hr_api.g_varchar2) THEN
      p_rec.vre_information4 :=
      pqp_vre_shd.g_old_rec.vre_information4;
  END IF;
  IF (p_rec.vre_information5 = hr_api.g_varchar2) THEN
      p_rec.vre_information5 :=
      pqp_vre_shd.g_old_rec.vre_information5;
  END IF;
  IF (p_rec.vre_information6 = hr_api.g_varchar2) THEN
      p_rec.vre_information6 :=
      pqp_vre_shd.g_old_rec.vre_information6;
  END IF;
  IF (p_rec.vre_information7 = hr_api.g_varchar2) THEN
      p_rec.vre_information7 :=
      pqp_vre_shd.g_old_rec.vre_information7;
  END IF;
  IF (p_rec.vre_information8 = hr_api.g_varchar2) THEN
      p_rec.vre_information8 :=
      pqp_vre_shd.g_old_rec.vre_information8;
  END IF;
  IF (p_rec.vre_information9 = hr_api.g_varchar2) THEN
      p_rec.vre_information9 :=
      pqp_vre_shd.g_old_rec.vre_information9;
  END IF;
  IF (p_rec.vre_information10 = hr_api.g_varchar2) THEN
      p_rec.vre_information10 :=
      pqp_vre_shd.g_old_rec.vre_information10;
  END IF;
  IF (p_rec.vre_information11 = hr_api.g_varchar2) THEN
      p_rec.vre_information11 :=
      pqp_vre_shd.g_old_rec.vre_information11;
  END IF;
  IF (p_rec.vre_information12 = hr_api.g_varchar2) THEN
      p_rec.vre_information12 :=
      pqp_vre_shd.g_old_rec.vre_information12;
  END IF;
  IF (p_rec.vre_information13 = hr_api.g_varchar2) THEN
      p_rec.vre_information13 :=
      pqp_vre_shd.g_old_rec.vre_information13;
  END IF;
  IF (p_rec.vre_information14 = hr_api.g_varchar2) THEN
      p_rec.vre_information14 :=
      pqp_vre_shd.g_old_rec.vre_information14;
  END IF;
  IF (p_rec.vre_information15 = hr_api.g_varchar2) THEN
      p_rec.vre_information15 :=
      pqp_vre_shd.g_old_rec.vre_information15;
  END IF;
  IF (p_rec.vre_information16 = hr_api.g_varchar2) THEN
      p_rec.vre_information16 :=
      pqp_vre_shd.g_old_rec.vre_information16;
  END IF;
  IF (p_rec.vre_information17 = hr_api.g_varchar2) THEN
      p_rec.vre_information17 :=
      pqp_vre_shd.g_old_rec.vre_information17;
  END IF;
  IF (p_rec.vre_information18 = hr_api.g_varchar2) THEN
      p_rec.vre_information18 :=
      pqp_vre_shd.g_old_rec.vre_information18;
  END IF;
  IF (p_rec.vre_information19 = hr_api.g_varchar2) THEN
      p_rec.vre_information19 :=
      pqp_vre_shd.g_old_rec.vre_information19;
  END IF;
  IF (p_rec.vre_information20 = hr_api.g_varchar2) THEN
      p_rec.vre_information20 :=
      pqp_vre_shd.g_old_rec.vre_information20;
  END IF;

  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date IN     DATE
  ,p_datetrack_mode IN     VARCHAR2
  ,p_rec            IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ) IS
--
  l_proc                        VARCHAR2(72) := g_package||'upd';
  l_validation_start_date       DATE;
  l_validation_end_date         DATE;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
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
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pqp_vre_upd.convert_defs(p_rec);
  --


  pqp_vre_bus.update_validate
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
END upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN     DATE
  ,p_datetrack_mode               IN     VARCHAR2
  ,p_vehicle_repository_id        IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_registration_number          IN     VARCHAR2
  ,p_vehicle_type                 IN     VARCHAR2
  ,p_vehicle_id_number            IN     VARCHAR2
  ,p_business_group_id            IN     NUMBER
  ,p_make                         IN     VARCHAR2
  ,p_engine_capacity_in_cc        IN     NUMBER
  ,p_fuel_type                    IN     VARCHAR2
  ,p_currency_code                IN     VARCHAR2
  ,p_vehicle_status               IN     VARCHAR2
  ,p_vehicle_inactivity_reason    IN     VARCHAR2
  ,p_model                        IN     VARCHAR2
  ,p_initial_registration         IN     DATE
  ,p_last_registration_renew_date IN     DATE
  ,p_list_price                   IN     NUMBER
  ,p_accessory_value_at_startdate IN     NUMBER
  ,p_accessory_value_added_later  IN     NUMBER
  ,p_market_value_classic_car     IN     NUMBER
  ,p_fiscal_ratings               IN     NUMBER
  ,p_fiscal_ratings_uom           IN     VARCHAR2
  ,p_vehicle_provider             IN     VARCHAR2
  ,p_vehicle_ownership            IN     VARCHAR2
  ,p_shared_vehicle               IN     VARCHAR2
  ,p_asset_number                 IN     VARCHAR2
  ,p_lease_contract_number        IN     VARCHAR2
  ,p_lease_contract_expiry_date   IN     DATE
  ,p_taxation_method              IN     VARCHAR2
  ,p_fleet_info                   IN     VARCHAR2
  ,p_fleet_transfer_date          IN     DATE
  ,p_color                        IN     VARCHAR2
  ,p_seating_capacity             IN     NUMBER
  ,p_weight                       IN     NUMBER
  ,p_weight_uom                   IN     VARCHAR2
  ,p_model_year                   IN     NUMBER
  ,p_insurance_number             IN     VARCHAR2
  ,p_insurance_expiry_date        IN     DATE
  ,p_comments                     IN     VARCHAR2
  ,p_vre_attribute_category       IN     VARCHAR2
  ,p_vre_attribute1               IN     VARCHAR2
  ,p_vre_attribute2               IN     VARCHAR2
  ,p_vre_attribute3               IN     VARCHAR2
  ,p_vre_attribute4               IN     VARCHAR2
  ,p_vre_attribute5               IN     VARCHAR2
  ,p_vre_attribute6               IN     VARCHAR2
  ,p_vre_attribute7               IN     VARCHAR2
  ,p_vre_attribute8               IN     VARCHAR2
  ,p_vre_attribute9               IN     VARCHAR2
  ,p_vre_attribute10              IN     VARCHAR2
  ,p_vre_attribute11              IN     VARCHAR2
  ,p_vre_attribute12              IN     VARCHAR2
  ,p_vre_attribute13              IN     VARCHAR2
  ,p_vre_attribute14              IN     VARCHAR2
  ,p_vre_attribute15              IN     VARCHAR2
  ,p_vre_attribute16              IN     VARCHAR2
  ,p_vre_attribute17              IN     VARCHAR2
  ,p_vre_attribute18              IN     VARCHAR2
  ,p_vre_attribute19              IN     VARCHAR2
  ,p_vre_attribute20              IN     VARCHAR2
  ,p_vre_information_category     IN     VARCHAR2
  ,p_vre_information1             IN     VARCHAR2
  ,p_vre_information2             IN     VARCHAR2
  ,p_vre_information3             IN     VARCHAR2
  ,p_vre_information4             IN     VARCHAR2
  ,p_vre_information5             IN     VARCHAR2
  ,p_vre_information6             IN     VARCHAR2
  ,p_vre_information7             IN     VARCHAR2
  ,p_vre_information8             IN     VARCHAR2
  ,p_vre_information9             IN     VARCHAR2
  ,p_vre_information10            IN     VARCHAR2
  ,p_vre_information11            IN     VARCHAR2
  ,p_vre_information12            IN     VARCHAR2
  ,p_vre_information13            IN     VARCHAR2
  ,p_vre_information14            IN     VARCHAR2
  ,p_vre_information15            IN     VARCHAR2
  ,p_vre_information16            IN     VARCHAR2
  ,p_vre_information17            IN     VARCHAR2
  ,p_vre_information18            IN     VARCHAR2
  ,p_vre_information19            IN     VARCHAR2
  ,p_vre_information20            IN     VARCHAR2
  ,p_effective_start_date         OUT NOCOPY DATE
  ,p_effective_end_date           OUT NOCOPY DATE
  ) IS
--
  l_rec         pqp_vre_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_vre_shd.convert_args
    (p_vehicle_repository_id
    ,null
    ,null
    ,p_registration_number
    ,p_vehicle_type
    ,p_vehicle_id_number
    ,p_business_group_id
    ,p_make
    ,p_model
    ,p_initial_registration
    ,p_last_registration_renew_date
    ,p_engine_capacity_in_cc
    ,p_fuel_type
    ,p_currency_code
    ,p_list_price
    ,p_accessory_value_at_startdate
    ,p_accessory_value_added_later
    ,p_market_value_classic_car
    ,p_fiscal_ratings
    ,p_fiscal_ratings_uom
    ,p_vehicle_provider
    ,p_vehicle_ownership
    ,p_shared_vehicle
    ,p_vehicle_status
    ,p_vehicle_inactivity_reason
    ,p_asset_number
    ,p_lease_contract_number
    ,p_lease_contract_expiry_date
    ,p_taxation_method
    ,p_fleet_info
    ,p_fleet_transfer_date
    ,p_object_version_number
    ,p_color
    ,p_seating_capacity
    ,p_weight
    ,p_weight_uom
    ,p_model_year
    ,p_insurance_number
    ,p_insurance_expiry_date
    ,p_comments
    ,p_vre_attribute_category
    ,p_vre_attribute1
    ,p_vre_attribute2
    ,p_vre_attribute3
    ,p_vre_attribute4
    ,p_vre_attribute5
    ,p_vre_attribute6
    ,p_vre_attribute7
    ,p_vre_attribute8
    ,p_vre_attribute9
    ,p_vre_attribute10
    ,p_vre_attribute11
    ,p_vre_attribute12
    ,p_vre_attribute13
    ,p_vre_attribute14
    ,p_vre_attribute15
    ,p_vre_attribute16
    ,p_vre_attribute17
    ,p_vre_attribute18
    ,p_vre_attribute19
    ,p_vre_attribute20
    ,p_vre_information_category
    ,p_vre_information1
    ,p_vre_information2
    ,p_vre_information3
    ,p_vre_information4
    ,p_vre_information5
    ,p_vre_information6
    ,p_vre_information7
    ,p_vre_information8
    ,p_vre_information9
    ,p_vre_information10
    ,p_vre_information11
    ,p_vre_information12
    ,p_vre_information13
    ,p_vre_information14
    ,p_vre_information15
    ,p_vre_information16
    ,p_vre_information17
    ,p_vre_information18
    ,p_vre_information19
    ,p_vre_information20
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_vre_upd.upd
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
END upd;
--
END pqp_vre_upd;

/
