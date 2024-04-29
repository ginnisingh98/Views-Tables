--------------------------------------------------------
--  DDL for Package Body PQP_VRE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRE_INS" AS
/* $Header: pqvrerhi.pkb 120.0.12010000.2 2008/08/08 07:23:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vre_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_vehicle_repository_id_i  NUMBER   DEFAULT NULL;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_base_key_value
  (p_vehicle_repository_id  IN  NUMBER) IS
--
  l_proc       VARCHAR2(72) := g_package||'set_base_key_value';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqp_vre_ins.g_vehicle_repository_id_i := p_vehicle_repository_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END set_base_key_value;
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
PROCEDURE dt_insert_dml
  (p_rec                     IN out nocopy pqp_vre_shd.g_rec_type
  ,p_effective_date          IN DATE
  ,p_datetrack_mode          IN VARCHAR2
  ,p_validation_start_date   IN DATE
  ,p_validation_end_date     IN DATE
  ) IS
-- Cursor to select 'old' created AOL who column values
--
    CURSOR C_Sel1 IS
    SELECT t.created_by,
           t.creation_date
      FROM pqp_vehicle_repository_f t
     WHERE t.vehicle_repository_id = p_rec.vehicle_repository_id
       AND t.effective_start_date =
           pqp_vre_shd.g_old_rec.effective_start_date
       AND t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pqp_vehicle_repository_f.created_by%TYPE;
  l_creation_date       pqp_vehicle_repository_f.creation_date%TYPE;
  l_last_update_date    pqp_vehicle_repository_f.last_update_date%TYPE;
  l_last_updated_by     pqp_vehicle_repository_f.last_updated_by%TYPE;
  l_last_update_login   pqp_vehicle_repository_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pqp_vehicle_repository_f'
      ,p_base_key_column => 'vehicle_repository_id'
      ,p_base_key_value  => p_rec.vehicle_repository_id
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
  IF (p_datetrack_mode <> hr_api.g_insert) THEN
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    OPEN  C_Sel1;
    FETCH C_Sel1 Into l_created_by, l_creation_date;
    IF C_Sel1%notfound THEN
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      CLOSE C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
    CLOSE C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  END IF;
  --
  --
  --
  -- Insert the row into: pqp_vehicle_repository_f
  --
  INSERT INTO pqp_vehicle_repository_f
      (vehicle_repository_id
      ,effective_start_date
      ,effective_end_date
      ,registration_number
      ,vehicle_type
      ,vehicle_id_number
      ,business_group_id
      ,make
      ,model
      ,initial_registration
      ,last_registration_renew_date
      ,engine_capacity_in_cc
      ,fuel_type
      ,currency_code
      ,list_price
      ,accessory_value_at_startdate
      ,accessory_value_added_later
      ,market_value_classic_car
      ,fiscal_ratings
      ,fiscal_ratings_uom
      ,vehicle_provider
      ,vehicle_ownership
      ,shared_vehicle
      ,vehicle_status
      ,vehicle_inactivity_reason
      ,asset_number
      ,lease_contract_number
      ,lease_contract_expiry_date
      ,taxation_method
      ,fleet_info
      ,fleet_transfer_date
      ,object_version_number
      ,color
      ,seating_capacity
      ,weight
      ,weight_uom
      ,model_year
      ,insurance_number
      ,insurance_expiry_date
      ,comments
      ,vre_attribute_category
      ,vre_attribute1
      ,vre_attribute2
      ,vre_attribute3
      ,vre_attribute4
      ,vre_attribute5
      ,vre_attribute6
      ,vre_attribute7
      ,vre_attribute8
      ,vre_attribute9
      ,vre_attribute10
      ,vre_attribute11
      ,vre_attribute12
      ,vre_attribute13
      ,vre_attribute14
      ,vre_attribute15
      ,vre_attribute16
      ,vre_attribute17
      ,vre_attribute18
      ,vre_attribute19
      ,vre_attribute20
      ,vre_information_category
      ,vre_information1
      ,vre_information2
      ,vre_information3
      ,vre_information4
      ,vre_information5
      ,vre_information6
      ,vre_information7
      ,vre_information8
      ,vre_information9
      ,vre_information10
      ,vre_information11
      ,vre_information12
      ,vre_information13
      ,vre_information14
      ,vre_information15
      ,vre_information16
      ,vre_information17
      ,vre_information18
      ,vre_information19
      ,vre_information20
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  VALUES
    (p_rec.vehicle_repository_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.registration_number
    ,p_rec.vehicle_type
    ,p_rec.vehicle_id_number
    ,p_rec.business_group_id
    ,p_rec.make
    ,p_rec.model
    ,p_rec.initial_registration
    ,p_rec.last_registration_renew_date
    ,p_rec.engine_capacity_in_cc
    ,p_rec.fuel_type
    ,p_rec.currency_code
    ,p_rec.list_price
    ,p_rec.accessory_value_at_startdate
    ,p_rec.accessory_value_added_later
    ,p_rec.market_value_classic_car
    ,p_rec.fiscal_ratings
    ,p_rec.fiscal_ratings_uom
    ,p_rec.vehicle_provider
    ,p_rec.vehicle_ownership
    ,p_rec.shared_vehicle
    ,p_rec.vehicle_status
    ,p_rec.vehicle_inactivity_reason
    ,p_rec.asset_number
    ,p_rec.lease_contract_number
    ,p_rec.lease_contract_expiry_date
    ,p_rec.taxation_method
    ,p_rec.fleet_info
    ,p_rec.fleet_transfer_date
    ,p_rec.object_version_number
    ,p_rec.color
    ,p_rec.seating_capacity
    ,p_rec.weight
    ,p_rec.weight_uom
    ,p_rec.model_year
    ,p_rec.insurance_number
    ,p_rec.insurance_expiry_date
    ,p_rec.comments
    ,p_rec.vre_attribute_category
    ,p_rec.vre_attribute1
    ,p_rec.vre_attribute2
    ,p_rec.vre_attribute3
    ,p_rec.vre_attribute4
    ,p_rec.vre_attribute5
    ,p_rec.vre_attribute6
    ,p_rec.vre_attribute7
    ,p_rec.vre_attribute8
    ,p_rec.vre_attribute9
    ,p_rec.vre_attribute10
    ,p_rec.vre_attribute11
    ,p_rec.vre_attribute12
    ,p_rec.vre_attribute13
    ,p_rec.vre_attribute14
    ,p_rec.vre_attribute15
    ,p_rec.vre_attribute16
    ,p_rec.vre_attribute17
    ,p_rec.vre_attribute18
    ,p_rec.vre_attribute19
    ,p_rec.vre_attribute20
    ,p_rec.vre_information_category
    ,p_rec.vre_information1
    ,p_rec.vre_information2
    ,p_rec.vre_information3
    ,p_rec.vre_information4
    ,p_rec.vre_information5
    ,p_rec.vre_information6
    ,p_rec.vre_information7
    ,p_rec.vre_information8
    ,p_rec.vre_information9
    ,p_rec.vre_information10
    ,p_rec.vre_information11
    ,p_rec.vre_information12
    ,p_rec.vre_information13
    ,p_rec.vre_information14
    ,p_rec.vre_information15
    ,p_rec.vre_information16
    ,p_rec.vre_information17
    ,p_rec.vre_information18
    ,p_rec.vre_information19
    ,p_rec.vre_information20
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
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
END dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_dml
  (p_rec                   IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  l_proc        varchar2(72) := g_package||'insert_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_vre_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END insert_dml;
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
PROCEDURE pre_insert
  (p_rec                   IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  Cursor C_Sel1 is select pqp_vehicle_repository_s.nextval from sys.dual;
--
 CURSOR   C_Sel2 IS
   SELECT NULL
     FROM pqp_vehicle_repository_f
    WHERE vehicle_repository_id =
             pqp_vre_ins.g_vehicle_repository_id_i;
--
  l_proc        VARCHAR2(72) := g_package||'pre_insert';
  l_exists      VARCHAR2(1);
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    IF (pqp_vre_ins.g_vehicle_repository_id_i is not null) THEN
    --
    -- Verify registered primary key values not already in use
    --
    OPEN C_Sel2;
    FETCH C_Sel2 INTO l_exists;
    IF C_Sel2%FOUND THEN
       CLOSE C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pqp_vehicle_repository_f');
       fnd_message.raise_error;
    END IF;
    CLOSE C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.vehicle_repository_id :=
      pqp_vre_ins.g_vehicle_repository_id_i;
    pqp_vre_ins.g_vehicle_repository_id_i := null;
  ELSE
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    OPEN C_Sel1;
    FETCH C_Sel1 Into p_rec.vehicle_repository_id;
    CLOSE C_Sel1;
  End If;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_insert;
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
PROCEDURE post_insert
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  ) IS
--
  l_proc        VARCHAR2(72) := g_package||'post_insert';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    --
    pqp_vre_rki.after_insert
      (p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      ,p_vehicle_repository_id        => p_rec.vehicle_repository_id
      ,p_effective_start_date         => p_rec.effective_start_date
      ,p_effective_end_date           => p_rec.effective_end_date
      ,p_registration_number          => p_rec.registration_number
      ,p_vehicle_type                 => p_rec.vehicle_type
      ,p_vehicle_id_number            => p_rec.vehicle_id_number
      ,p_business_group_id            => p_rec.business_group_id
      ,p_make                         => p_rec.make
      ,p_model                        => p_rec.model
      ,p_initial_registration         => p_rec.initial_registration
      ,p_last_registration_renew_date => p_rec.last_registration_renew_date
      ,p_engine_capacity_in_cc        => p_rec.engine_capacity_in_cc
      ,p_fuel_type                    => p_rec.fuel_type
      ,p_currency_code                => p_rec.currency_code
      ,p_list_price                   => p_rec.list_price
      ,p_accessory_value_at_startdate => p_rec.accessory_value_at_startdate
      ,p_accessory_value_added_later  => p_rec.accessory_value_added_later
      ,p_market_value_classic_car     => p_rec.market_value_classic_car
      ,p_fiscal_ratings               => p_rec.fiscal_ratings
      ,p_fiscal_ratings_uom           => p_rec.fiscal_ratings_uom
      ,p_vehicle_provider             => p_rec.vehicle_provider
      ,p_vehicle_ownership            => p_rec.vehicle_ownership
      ,p_shared_vehicle               => p_rec.shared_vehicle
      ,p_vehicle_status               => p_rec.vehicle_status
      ,p_vehicle_inactivity_reason    => p_rec.vehicle_inactivity_reason
      ,p_asset_number                 => p_rec.asset_number
      ,p_lease_contract_number        => p_rec.lease_contract_number
      ,p_lease_contract_expiry_date   => p_rec.lease_contract_expiry_date
      ,p_taxation_method              => p_rec.taxation_method
      ,p_fleet_info                   => p_rec.fleet_info
      ,p_fleet_transfer_date          => p_rec.fleet_transfer_date
      ,p_object_version_number        => p_rec.object_version_number
      ,p_color                        => p_rec.color
      ,p_seating_capacity             => p_rec.seating_capacity
      ,p_weight                       => p_rec.weight
      ,p_weight_uom                   => p_rec.weight_uom
      ,p_model_year                   => p_rec.model_year
      ,p_insurance_number             => p_rec.insurance_number
      ,p_insurance_expiry_date        => p_rec.insurance_expiry_date
      ,p_comments                     => p_rec.comments
      ,p_vre_attribute_category       => p_rec.vre_attribute_category
      ,p_vre_attribute1               => p_rec.vre_attribute1
      ,p_vre_attribute2               => p_rec.vre_attribute2
      ,p_vre_attribute3               => p_rec.vre_attribute3
      ,p_vre_attribute4               => p_rec.vre_attribute4
      ,p_vre_attribute5               => p_rec.vre_attribute5
      ,p_vre_attribute6               => p_rec.vre_attribute6
      ,p_vre_attribute7               => p_rec.vre_attribute7
      ,p_vre_attribute8               => p_rec.vre_attribute8
      ,p_vre_attribute9               => p_rec.vre_attribute9
      ,p_vre_attribute10              => p_rec.vre_attribute10
      ,p_vre_attribute11              => p_rec.vre_attribute11
      ,p_vre_attribute12              => p_rec.vre_attribute12
      ,p_vre_attribute13              => p_rec.vre_attribute13
      ,p_vre_attribute14              => p_rec.vre_attribute14
      ,p_vre_attribute15              => p_rec.vre_attribute15
      ,p_vre_attribute16              => p_rec.vre_attribute16
      ,p_vre_attribute17              => p_rec.vre_attribute17
      ,p_vre_attribute18              => p_rec.vre_attribute18
      ,p_vre_attribute19              => p_rec.vre_attribute19
      ,p_vre_attribute20              => p_rec.vre_attribute20
      ,p_vre_information_category     => p_rec.vre_information_category
      ,p_vre_information1             => p_rec.vre_information1
      ,p_vre_information2             => p_rec.vre_information2
      ,p_vre_information3             => p_rec.vre_information3
      ,p_vre_information4             => p_rec.vre_information4
      ,p_vre_information5             => p_rec.vre_information5
      ,p_vre_information6             => p_rec.vre_information6
      ,p_vre_information7             => p_rec.vre_information7
      ,p_vre_information8             => p_rec.vre_information8
      ,p_vre_information9             => p_rec.vre_information9
      ,p_vre_information10            => p_rec.vre_information10
      ,p_vre_information11            => p_rec.vre_information11
      ,p_vre_information12            => p_rec.vre_information12
      ,p_vre_information13            => p_rec.vre_information13
      ,p_vre_information14            => p_rec.vre_information14
      ,p_vre_information15            => p_rec.vre_information15
      ,p_vre_information16            => p_rec.vre_information16
      ,p_vre_information17            => p_rec.vre_information17
      ,p_vre_information18            => p_rec.vre_information18
      ,p_vre_information19            => p_rec.vre_information19
      ,p_vre_information20            => p_rec.vre_information20
      );
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_F'
        ,p_hook_type   => 'AI');
      --
  END;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_insert;
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
PROCEDURE ins_lck
  (p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_validation_start_date OUT NOCOPY DATE
  ,p_validation_end_date   OUT NOCOPY DATE
  ) IS
--
  l_proc                  VARCHAR2(72) := g_package||'ins_lck';
  l_validation_start_date DATE;
  l_validation_end_date   DATE;
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
    ,p_base_table_name         => 'pqp_vehicle_repository_f'
    ,p_base_key_column         => 'vehicle_repository_id'
    ,p_base_key_value          => p_rec.vehicle_repository_id
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
END ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date IN     DATE
  ,p_rec            IN OUT NOCOPY pqp_vre_shd.g_rec_type
  ) IS
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  pqp_vre_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pqp_vre_bus.insert_validate
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
  -- Call the supporting pre-insert operation
  --
  pqp_vre_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pqp_vre_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pqp_vre_ins.post_insert
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
END ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date                 IN     DATE
  ,p_registration_number            IN     VARCHAR2
  ,p_vehicle_type                   IN     VARCHAR2
  ,p_vehicle_id_number              IN     VARCHAR2
  ,p_business_group_id              IN     NUMBER
  ,p_make                           IN     VARCHAR2
  ,p_engine_capacity_in_cc          IN     NUMBER
  ,p_fuel_type                      IN     VARCHAR2
  ,p_currency_code                  IN     VARCHAR2
  ,p_vehicle_status                 IN     VARCHAR2
  ,p_vehicle_inactivity_reason      IN     VARCHAR2
  ,p_model                          IN     VARCHAR2
  ,p_initial_registration           IN     DATE
  ,p_last_registration_renew_date   IN     DATE
  ,p_list_price                     IN     NUMBER
  ,p_accessory_value_at_startdate   IN     NUMBER
  ,p_accessory_value_added_later    IN     NUMBER
  ,p_market_value_classic_car       IN     NUMBER
  ,p_fiscal_ratings                 IN     NUMBER
  ,p_fiscal_ratings_uom             IN     VARCHAR2
  ,p_vehicle_provider               IN     VARCHAR2
  ,p_vehicle_ownership              IN     VARCHAR2
  ,p_shared_vehicle                 IN     VARCHAR2
  ,p_asset_number                   IN     VARCHAR2
  ,p_lease_contract_number          IN     VARCHAR2
  ,p_lease_contract_expiry_date     IN     DATE
  ,p_taxation_method                IN     VARCHAR2
  ,p_fleet_info                     IN     VARCHAR2
  ,p_fleet_transfer_date            IN     DATE
  ,p_color                          IN     VARCHAR2
  ,p_seating_capacity               IN     NUMBER
  ,p_weight                         IN     NUMBER
  ,p_weight_uom                     IN     VARCHAR2
  ,p_model_year                     IN     NUMBER
  ,p_insurance_number               IN     VARCHAR2
  ,p_insurance_expiry_date          IN     DATE
  ,p_comments                       IN     VARCHAR2
  ,p_vre_attribute_category         IN     VARCHAR2
  ,p_vre_attribute1                 IN     VARCHAR2
  ,p_vre_attribute2                 IN     VARCHAR2
  ,p_vre_attribute3                 IN     VARCHAR2
  ,p_vre_attribute4                 IN     VARCHAR2
  ,p_vre_attribute5                 IN     VARCHAR2
  ,p_vre_attribute6                 IN     VARCHAR2
  ,p_vre_attribute7                 IN     VARCHAR2
  ,p_vre_attribute8                 IN     VARCHAR2
  ,p_vre_attribute9                 IN     VARCHAR2
  ,p_vre_attribute10                IN     VARCHAR2
  ,p_vre_attribute11                IN     VARCHAR2
  ,p_vre_attribute12                IN     VARCHAR2
  ,p_vre_attribute13                IN     VARCHAR2
  ,p_vre_attribute14                IN     VARCHAR2
  ,p_vre_attribute15                IN     VARCHAR2
  ,p_vre_attribute16                IN     VARCHAR2
  ,p_vre_attribute17                IN     VARCHAR2
  ,p_vre_attribute18                IN     VARCHAR2
  ,p_vre_attribute19                IN     VARCHAR2
  ,p_vre_attribute20                IN     VARCHAR2
  ,p_vre_information_category       IN     VARCHAR2
  ,p_vre_information1               IN     VARCHAR2
  ,p_vre_information2               IN     VARCHAR2
  ,p_vre_information3               IN     VARCHAR2
  ,p_vre_information4               IN     VARCHAR2
  ,p_vre_information5               IN     VARCHAR2
  ,p_vre_information6               IN     VARCHAR2
  ,p_vre_information7               IN     VARCHAR2
  ,p_vre_information8               IN     VARCHAR2
  ,p_vre_information9               IN     VARCHAR2
  ,p_vre_information10              IN     VARCHAR2
  ,p_vre_information11              IN     VARCHAR2
  ,p_vre_information12              IN     VARCHAR2
  ,p_vre_information13              IN     VARCHAR2
  ,p_vre_information14              IN     VARCHAR2
  ,p_vre_information15              IN     VARCHAR2
  ,p_vre_information16              IN     VARCHAR2
  ,p_vre_information17              IN     VARCHAR2
  ,p_vre_information18              IN     VARCHAR2
  ,p_vre_information19              IN     VARCHAR2
  ,p_vre_information20              IN     VARCHAR2
  ,p_vehicle_repository_id          OUT NOCOPY NUMBER
  ,p_object_version_number          OUT NOCOPY NUMBER
  ,p_effective_start_date           OUT NOCOPY DATE
  ,p_effective_end_date             OUT NOCOPY DATE
  ) IS
--
  l_rec         pqp_vre_shd.g_rec_type;
  l_proc        VARCHAR2(72) := g_package||'ins';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_vre_shd.convert_args
    (null
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
    ,null
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
  -- Having converted the arguments into the pqp_vre_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_vre_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_vehicle_repository_id            := l_rec.vehicle_repository_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END ins;
--
END pqp_vre_ins;

/
