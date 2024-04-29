--------------------------------------------------------
--  DDL for Package PQP_VRE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRE_SHD" AUTHID CURRENT_USER as
/* $Header: pqvrerhi.pkh 120.0.12010000.1 2008/07/28 11:26:09 appldev ship $ */

--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
TYPE g_rec_type IS RECORD
  (vehicle_repository_id           NUMBER(10)
  ,effective_start_date            DATE
  ,effective_end_date              DATE
  ,registration_number             VARCHAR2(30)
  ,vehicle_type                    VARCHAR2(30)
  ,vehicle_id_number               VARCHAR2(50)
  ,business_group_id               NUMBER(15)
  ,make                            VARCHAR2(30)
  ,model                           VARCHAR2(30)
  ,initial_registration            DATE
  ,last_registration_renew_date    DATE
  ,engine_capacity_in_cc           NUMBER
  ,fuel_type                       VARCHAR2(30)
  ,currency_code                   VARCHAR2(30)
  ,list_price                      NUMBER(11,2)
  ,accessory_value_at_startdate    NUMBER(11,2)
  ,accessory_value_added_later     NUMBER(11,2)
  ,market_value_classic_car        NUMBER(11,2)
  ,fiscal_ratings                  NUMBER
  ,fiscal_ratings_uom              VARCHAR2(30)
  ,vehicle_provider                VARCHAR2(60)
  ,vehicle_ownership               VARCHAR2(30)
  ,shared_vehicle                  VARCHAR2(30)
  ,vehicle_status                  VARCHAR2(30)
  ,vehicle_inactivity_reason       VARCHAR2(30)
  ,asset_number                    VARCHAR2(80)
  ,lease_contract_number           VARCHAR2(80)
  ,lease_contract_expiry_date      DATE
  ,taxation_method                 VARCHAR2(80)
  ,fleet_info                      VARCHAR2(120)
  ,fleet_transfer_date             DATE
  ,object_version_number           NUMBER(9)
  ,color                           VARCHAR2(30)
  ,seating_capacity                NUMBER
  ,weight                          NUMBER(15,2)
  ,weight_uom                      VARCHAR2(30)
  ,model_year                      NUMBER
  ,insurance_number                VARCHAR2(80)
  ,insurance_expiry_date           DATE
  ,comments                        VARCHAR2(180)
  ,vre_attribute_category          VARCHAR2(30)
  ,vre_attribute1                  VARCHAR2(150)
  ,vre_attribute2                  VARCHAR2(150)
  ,vre_attribute3                  VARCHAR2(150)
  ,vre_attribute4                  VARCHAR2(150)
  ,vre_attribute5                  VARCHAR2(150)
  ,vre_attribute6                  VARCHAR2(150)
  ,vre_attribute7                  VARCHAR2(150)
  ,vre_attribute8                  VARCHAR2(150)
  ,vre_attribute9                  VARCHAR2(150)
  ,vre_attribute10                 VARCHAR2(150)
  ,vre_attribute11                 VARCHAR2(150)
  ,vre_attribute12                 VARCHAR2(150)
  ,vre_attribute13                 VARCHAR2(150)
  ,vre_attribute14                 VARCHAR2(150)
  ,vre_attribute15                 VARCHAR2(150)
  ,vre_attribute16                 VARCHAR2(150)
  ,vre_attribute17                 VARCHAR2(150)
  ,vre_attribute18                 VARCHAR2(150)
  ,vre_attribute19                 VARCHAR2(150)
  ,vre_attribute20                 VARCHAR2(150)
  ,vre_information_category        VARCHAR2(30)
  ,vre_information1                VARCHAR2(150)
  ,vre_information2                VARCHAR2(150)
  ,vre_information3                VARCHAR2(150)
  ,vre_information4                VARCHAR2(150)
  ,vre_information5                VARCHAR2(150)
  ,vre_information6                VARCHAR2(150)
  ,vre_information7                VARCHAR2(150)
  ,vre_information8                VARCHAR2(150)
  ,vre_information9                VARCHAR2(150)
  ,vre_information10               VARCHAR2(150)
  ,vre_information11               VARCHAR2(150)
  ,vre_information12               VARCHAR2(150)
  ,vre_information13               VARCHAR2(150)
  ,vre_information14               VARCHAR2(150)
  ,vre_information15               VARCHAR2(150)
  ,vre_information16               VARCHAR2(150)
  ,vre_information17               VARCHAR2(150)
  ,vre_information18               VARCHAR2(150)
  ,vre_information19               VARCHAR2(150)
  ,vre_information20               VARCHAR2(150)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant VARCHAR2(30) := 'PQP_VEHICLE_REPOSITORY_F';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
--  {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   IN DATE
  ,p_vehicle_repository_id            IN NUMBER
  ,p_object_version_number            IN NUMBER
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack update modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the update modes
--   available where TRUE indicates that the corresponding update mode
--   is available.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :vehicle_repository_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack update mode of
--   UPDATE. To implement this you would have to set and return a Boolean
--   value of FALSE after the call to the dt_api.find_dt_upd_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE find_dt_upd_modes
  (p_effective_date         IN DATE
  ,p_base_key_value         IN NUMBER
  ,p_correction             OUT NOCOPY boolean
  ,p_update                 OUT NOCOPY boolean
  ,p_update_override        OUT NOCOPY boolean
  ,p_update_change_insert   OUT NOCOPY boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack delete modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the delete modes
--   available where TRUE indicates that the corresponding delete mode is
--   available.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :vehicle_repository_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack delete mode of
--   ZAP. To implement this you would have to set and return a Boolean value
--   of FALSE after the call to the dt_api.find_dt_del_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE find_dt_del_modes
  (p_effective_date        IN  DATE
  ,p_base_key_value        IN  NUMBER
  ,p_zap                   OUT NOCOPY boolean
  ,p_delete                OUT NOCOPY boolean
  ,p_future_change         OUT NOCOPY boolean
  ,p_delete_next_change    OUT NOCOPY boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will update the specified datetrack row with the
--   specified new effective end date. The object version number is also
--   set to the next object version number. DateTrack modes which call
--   this procedure are: UPDATE, UPDATE_CHANGE_INSERT,
--   UPDATE_OVERRIDE, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE.
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_new_effective_end_date
--     Specifies the new effective end date which will be set for the
--     row as of the effective date.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :vehicle_repository_id).
--
-- Post Success:
--   The specified row will be updated with the new effective end date and
--   object_version_number.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
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
PROCEDURE upd_effective_end_date
  (p_effective_date         IN DATE
  ,p_base_key_value         IN NUMBER
  ,p_new_effective_end_date IN DATE
  ,p_validation_start_date  IN DATE
  ,p_validation_end_date    IN DATE
  ,p_object_version_number  OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) If a comment exists the text is selected from hr_comments.
--   3) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Prerequisites:
--   When attempting to call the lck procedure the object version number,
--   primary key, effective date and datetrack mode must be specified.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update or delete mode.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_effective_date                   IN  DATE
  ,p_datetrack_mode                   IN  VARCHAR2
  ,p_vehicle_repository_id            IN  NUMBER
  ,p_object_version_number            IN  NUMBER
  ,p_validation_start_date            OUT NOCOPY DATE
  ,p_validation_end_date              OUT NOCOPY DATE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
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
  Return g_rec_type;
--
end pqp_vre_shd;

/
