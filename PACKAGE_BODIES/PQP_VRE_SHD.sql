--------------------------------------------------------
--  DDL for Package Body PQP_VRE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRE_SHD" AS
/* $Header: pqvrerhi.pkb 120.0.12010000.2 2008/08/08 07:23:09 ubhat ship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pqp_vre_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  )IS
--
  l_proc        VARCHAR2(72) := g_package||'constraint_error';
--
BEGIN
  --
  IF (p_constraint_name = 'PQP_VEHICLE_REPOSITORY_F_PK') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ELSE
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  END IF;
  --
END constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION api_updating
  (p_effective_date                   IN date
  ,p_vehicle_repository_id            IN number
  ,p_object_version_number            IN number
  ) RETURN BOOLEAN IS
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  CURSOR C_Sel1 IS
    SELECT
       vehicle_repository_id
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
   FROM    pqp_vehicle_repository_f
   WHERE   vehicle_repository_id = p_vehicle_repository_id
   AND     p_effective_date
   BETWEEN effective_start_date and effective_end_date;
--
  l_fct_ret     BOOLEAN;
--
BEGIN
  IF (p_effective_date        IS NULL OR
      p_vehicle_repository_id IS NULL OR
      p_object_version_number IS NULL) THEN
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  ELSE
    IF (p_vehicle_repository_id =
        pqp_vre_shd.g_old_rec.vehicle_repository_id and
        p_object_version_number =
        pqp_vre_shd.g_old_rec.object_version_number ) THEN
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    ELSE
      --
      -- Select the current row
      --
      OPEN  C_Sel1;
      FETCH C_Sel1 Into pqp_vre_shd.g_old_rec;
      IF C_Sel1%notfound THEN
         CLOSE C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      END IF;
      CLOSE C_Sel1;
      IF (p_object_version_number
          <> pqp_vre_shd.g_old_rec.object_version_number) THEN
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      END IF;
      l_fct_ret := true;
    END IF;
  END IF;
  RETURN (l_fct_ret);
--
END api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE find_dt_upd_modes
  (p_effective_date         IN  DATE
  ,p_base_key_value         IN  NUMBER
  ,p_correction             OUT NOCOPY BOOLEAN
  ,p_update                 OUT NOCOPY BOOLEAN
  ,p_update_override        OUT NOCOPY BOOLEAN
  ,p_update_change_insert   OUT NOCOPY BOOLEAN
  ) IS
--
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       =>'pqp_vehicle_repository_f'
    ,p_base_key_column       =>'vehicle_repository_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE find_dt_del_modes
  (p_effective_date        IN DATE
  ,p_base_key_value        IN NUMBER
  ,p_zap                   OUT NOCOPY BOOLEAN
  ,p_delete                OUT NOCOPY BOOLEAN
  ,p_future_change         OUT NOCOPY BOOLEAN
  ,p_delete_next_change    OUT NOCOPY BOOLEAN
  ) IS
  --
  l_proc                varchar2(72)    := g_package||'find_dt_del_modes';
  --
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               =>'pqp_vehicle_repository_f'
   ,p_base_key_column               =>'vehicle_repository_id'
   ,p_base_key_value                => p_base_key_value
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd_effective_end_date
  (p_effective_date                   IN  DATE
  ,p_base_key_value                   IN  NUMBER
  ,p_new_effective_end_date           IN  DATE
  ,p_validation_start_date            IN  DATE
  ,p_validation_end_date              IN  DATE
  ,p_object_version_number            OUT NOCOPY NUMBER
  ) IS
--
  l_proc                  VARCHAR2(72) := g_package||'upd_effective_end_date';
  l_object_version_number NUMBER;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name    =>'pqp_vehicle_repository_f'
      ,p_base_key_column    =>'vehicle_repository_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  UPDATE  pqp_vehicle_repository_f t
     SET  t.effective_end_date    = p_new_effective_end_date,
          t.object_version_number = l_object_version_number
   WHERE  t.vehicle_repository_id = p_base_key_value
     AND  p_effective_date
 BETWEEN  t.effective_start_date and t.effective_end_date;
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_effective_date                   IN  DATE
  ,p_datetrack_mode                   IN  VARCHAR2
  ,p_vehicle_repository_id            IN  NUMBER
  ,p_object_version_number            IN  NUMBER
  ,p_validation_start_date            OUT NOCOPY DATE
  ,p_validation_end_date              OUT NOCOPY DATE
  ) IS
--
  l_proc                  VARCHAR2(72) := g_package||'lck';
  l_validation_start_date DATE;
  l_validation_end_date   DATE;
  l_argument              VARCHAR2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  CURSOR  C_Sel1 IS
   SELECT
       vehicle_repository_id
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
    FROM    pqp_vehicle_repository_f
    WHERE   vehicle_repository_id = p_vehicle_repository_id
    AND     p_effective_date
    BETWEEN effective_start_date and effective_end_date
    FOR UPDATE NOWAIT;
  --
  --
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       =>'effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       =>'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       =>'vehicle_repository_id'
                            ,p_argument_value => p_vehicle_repository_id
                            );
  --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument         =>'object_version_number'
                            ,p_argument_value   => p_object_version_number
                            );
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  IF (p_datetrack_mode <> hr_api.g_insert) THEN
    --
    -- We must select and lock the current row.
    --
    OPEN  C_Sel1;
    FETCH C_Sel1 Into pqp_vre_shd.g_old_rec;
    IF C_Sel1%notfound THEN
      CLOSE C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    END IF;
    CLOSE C_Sel1;
    IF (p_object_version_number
          <> pqp_vre_shd.g_old_rec.object_version_number) THEN
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    END IF;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pqp_vehicle_repository_f'
      ,p_base_key_column         => 'vehicle_repository_id'
      ,p_base_key_value          => p_vehicle_repository_id
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
  ELSE
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  END IF;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
EXCEPTION
  WHEN HR_Api.Object_Locked THEN
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pqp_vehicle_repository_f');
    fnd_message.raise_error;
END lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_vehicle_repository_id          IN NUMBER
  ,p_effective_start_date           IN DATE
  ,p_effective_end_date             IN DATE
  ,p_registration_number            IN VARCHAR2
  ,p_vehicle_type                   IN VARCHAR2
  ,p_vehicle_id_number              IN VARCHAR2
  ,p_business_group_id              IN NUMBER
  ,p_make                           IN VARCHAR2
  ,p_model                          IN VARCHAR2
  ,p_initial_registration           IN DATE
  ,p_last_registration_renew_date   IN DATE
  ,p_engine_capacity_in_cc          IN NUMBER
  ,p_fuel_type                      IN VARCHAR2
  ,p_currency_code                  IN VARCHAR2
  ,p_list_price                     IN NUMBER
  ,p_accessory_value_at_startdate   IN NUMBER
  ,p_accessory_value_added_later    IN NUMBER
  ,p_market_value_classic_car       IN NUMBER
  ,p_fiscal_ratings                 IN NUMBER
  ,p_fiscal_ratings_uom             IN VARCHAR2
  ,p_vehicle_provider               IN VARCHAR2
  ,p_vehicle_ownership              IN VARCHAR2
  ,p_shared_vehicle                 IN VARCHAR2
  ,p_vehicle_status                 IN VARCHAR2
  ,p_vehicle_inactivity_reason      IN VARCHAR2
  ,p_asset_number                   IN VARCHAR2
  ,p_lease_contract_number          IN VARCHAR2
  ,p_lease_contract_expiry_date     IN DATE
  ,p_taxation_method                IN VARCHAR2
  ,p_fleet_info                     IN VARCHAR2
  ,p_fleet_transfer_date            IN DATE
  ,p_object_version_number          IN NUMBER
  ,p_color                          IN VARCHAR2
  ,p_seating_capacity               IN NUMBER
  ,p_weight                         IN NUMBER
  ,p_weight_uom                     IN VARCHAR2
  ,p_model_year                     IN NUMBER
  ,p_insurance_number               IN VARCHAR2
  ,p_insurance_expiry_date          IN DATE
  ,p_comments                       IN VARCHAR2
  ,p_vre_attribute_category         IN VARCHAR2
  ,p_vre_attribute1                 IN VARCHAR2
  ,p_vre_attribute2                 IN VARCHAR2
  ,p_vre_attribute3                 IN VARCHAR2
  ,p_vre_attribute4                 IN VARCHAR2
  ,p_vre_attribute5                 IN VARCHAR2
  ,p_vre_attribute6                 IN VARCHAR2
  ,p_vre_attribute7                 IN VARCHAR2
  ,p_vre_attribute8                 IN VARCHAR2
  ,p_vre_attribute9                 IN VARCHAR2
  ,p_vre_attribute10                IN VARCHAR2
  ,p_vre_attribute11                IN VARCHAR2
  ,p_vre_attribute12                IN VARCHAR2
  ,p_vre_attribute13                IN VARCHAR2
  ,p_vre_attribute14                IN VARCHAR2
  ,p_vre_attribute15                IN VARCHAR2
  ,p_vre_attribute16                IN VARCHAR2
  ,p_vre_attribute17                IN VARCHAR2
  ,p_vre_attribute18                IN VARCHAR2
  ,p_vre_attribute19                IN VARCHAR2
  ,p_vre_attribute20                IN VARCHAR2
  ,p_vre_information_category       IN VARCHAR2
  ,p_vre_information1               IN VARCHAR2
  ,p_vre_information2               IN VARCHAR2
  ,p_vre_information3               IN VARCHAR2
  ,p_vre_information4               IN VARCHAR2
  ,p_vre_information5               IN VARCHAR2
  ,p_vre_information6               IN VARCHAR2
  ,p_vre_information7               IN VARCHAR2
  ,p_vre_information8               IN VARCHAR2
  ,p_vre_information9               IN VARCHAR2
  ,p_vre_information10              IN VARCHAR2
  ,p_vre_information11              IN VARCHAR2
  ,p_vre_information12              IN VARCHAR2
  ,p_vre_information13              IN VARCHAR2
  ,p_vre_information14              IN VARCHAR2
  ,p_vre_information15              IN VARCHAR2
  ,p_vre_information16              IN VARCHAR2
  ,p_vre_information17              IN VARCHAR2
  ,p_vre_information18              IN VARCHAR2
  ,p_vre_information19              IN VARCHAR2
  ,p_vre_information20              IN VARCHAR2
  )
  RETURN g_rec_type IS
--
  l_rec   g_rec_type;
--
BEGIN
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.vehicle_repository_id            := p_vehicle_repository_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.registration_number              := p_registration_number;
  l_rec.vehicle_type                     := p_vehicle_type;
  l_rec.vehicle_id_number                := p_vehicle_id_number;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.make                             := p_make;
  l_rec.model                            := p_model;
  l_rec.initial_registration             := p_initial_registration;
  l_rec.last_registration_renew_date     := p_last_registration_renew_date;
  l_rec.engine_capacity_in_cc            := p_engine_capacity_in_cc;
  l_rec.fuel_type                        := p_fuel_type;
  l_rec.currency_code                    := p_currency_code;
  l_rec.list_price                       := p_list_price;
  l_rec.accessory_value_at_startdate     := p_accessory_value_at_startdate;
  l_rec.accessory_value_added_later      := p_accessory_value_added_later;
  l_rec.market_value_classic_car         := p_market_value_classic_car;
  l_rec.fiscal_ratings                   := p_fiscal_ratings;
  l_rec.fiscal_ratings_uom               := p_fiscal_ratings_uom;
  l_rec.vehicle_provider                 := p_vehicle_provider;
  l_rec.vehicle_ownership                := p_vehicle_ownership;
  l_rec.shared_vehicle                   := p_shared_vehicle;
  l_rec.vehicle_status                   := p_vehicle_status;
  l_rec.vehicle_inactivity_reason        := p_vehicle_inactivity_reason;
  l_rec.asset_number                     := p_asset_number;
  l_rec.lease_contract_number            := p_lease_contract_number;
  l_rec.lease_contract_expiry_date       := p_lease_contract_expiry_date;
  l_rec.taxation_method                  := p_taxation_method;
  l_rec.fleet_info                       := p_fleet_info;
  l_rec.fleet_transfer_date              := p_fleet_transfer_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.color                            := p_color;
  l_rec.seating_capacity                 := p_seating_capacity;
  l_rec.weight                           := p_weight;
  l_rec.weight_uom                       := p_weight_uom;
  l_rec.model_year                       := p_model_year;
  l_rec.insurance_number                 := p_insurance_number;
  l_rec.insurance_expiry_date            := p_insurance_expiry_date;
  l_rec.comments                         := p_comments;
  l_rec.vre_attribute_category           := p_vre_attribute_category;
  l_rec.vre_attribute1                   := p_vre_attribute1;
  l_rec.vre_attribute2                   := p_vre_attribute2;
  l_rec.vre_attribute3                   := p_vre_attribute3;
  l_rec.vre_attribute4                   := p_vre_attribute4;
  l_rec.vre_attribute5                   := p_vre_attribute5;
  l_rec.vre_attribute6                   := p_vre_attribute6;
  l_rec.vre_attribute7                   := p_vre_attribute7;
  l_rec.vre_attribute8                   := p_vre_attribute8;
  l_rec.vre_attribute9                   := p_vre_attribute9;
  l_rec.vre_attribute10                  := p_vre_attribute10;
  l_rec.vre_attribute11                  := p_vre_attribute11;
  l_rec.vre_attribute12                  := p_vre_attribute12;
  l_rec.vre_attribute13                  := p_vre_attribute13;
  l_rec.vre_attribute14                  := p_vre_attribute14;
  l_rec.vre_attribute15                  := p_vre_attribute15;
  l_rec.vre_attribute16                  := p_vre_attribute16;
  l_rec.vre_attribute17                  := p_vre_attribute17;
  l_rec.vre_attribute18                  := p_vre_attribute18;
  l_rec.vre_attribute19                  := p_vre_attribute19;
  l_rec.vre_attribute20                  := p_vre_attribute20;
  l_rec.vre_information_category         := p_vre_information_category;
  l_rec.vre_information1                 := p_vre_information1;
  l_rec.vre_information2                 := p_vre_information2;
  l_rec.vre_information3                 := p_vre_information3;
  l_rec.vre_information4                 := p_vre_information4;
  l_rec.vre_information5                 := p_vre_information5;
  l_rec.vre_information6                 := p_vre_information6;
  l_rec.vre_information7                 := p_vre_information7;
  l_rec.vre_information8                 := p_vre_information8;
  l_rec.vre_information9                 := p_vre_information9;
  l_rec.vre_information10                := p_vre_information10;
  l_rec.vre_information11                := p_vre_information11;
  l_rec.vre_information12                := p_vre_information12;
  l_rec.vre_information13                := p_vre_information13;
  l_rec.vre_information14                := p_vre_information14;
  l_rec.vre_information15                := p_vre_information15;
  l_rec.vre_information16                := p_vre_information16;
  l_rec.vre_information17                := p_vre_information17;
  l_rec.vre_information18                := p_vre_information18;
  l_rec.vre_information19                := p_vre_information19;
  l_rec.vre_information20                := p_vre_information20;
  --
  -- Return the plsql record structure.
  --
  RETURN(l_rec);
--
End convert_args;
--
END pqp_vre_shd;

/
