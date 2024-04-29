--------------------------------------------------------
--  DDL for Package PQH_ACC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ACC_SHD" AUTHID CURRENT_USER as
/* $Header: pqaccrhi.pkh 120.0 2005/05/29 01:23:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (accommodation_id                number(15)
  ,accommodation_name              varchar2(240)
  ,effective_start_date            date
  ,effective_end_date              date
  ,business_group_id               number(15)
  ,location_id                     number(15)
  ,accommodation_desc              varchar2(240)
  ,accommodation_type              varchar2(50)
  ,style                           varchar2(10)
  ,address_line_1                  varchar2(240)
  ,address_line_2                  varchar2(240)
  ,address_line_3                  varchar2(240)
  ,town_or_city                    varchar2(90)
  ,country                         varchar2(90)
  ,postal_code                     varchar2(45)
  ,region_1                        varchar2(120)
  ,region_2                        varchar2(120)
  ,region_3                        varchar2(120)
  ,telephone_number_1              varchar2(60)
  ,telephone_number_2              varchar2(60)
  ,telephone_number_3              varchar2(60)
  ,floor_number                    varchar2(30)
  ,floor_area                      number(9)
  ,floor_area_measure_unit         varchar2(30)
  ,main_rooms                      number(9)         -- Increased length
  ,family_size                     number(9)         -- Increased length
  ,suitability_disabled            varchar2(10)
  ,rental_value                    number(15)
  ,rental_value_currency           varchar2(30)
  ,owner                           varchar2(240)
  ,comments                        varchar2(2000)    -- pseudo column
  ,information_category            varchar2(30)
  ,information1                    varchar2(150)
  ,information2                    varchar2(150)
  ,information3                    varchar2(150)
  ,information4                    varchar2(150)
  ,information5                    varchar2(150)
  ,information6                    varchar2(150)
  ,information7                    varchar2(150)
  ,information8                    varchar2(150)
  ,information9                    varchar2(150)
  ,information10                   varchar2(150)
  ,information11                   varchar2(150)
  ,information12                   varchar2(150)
  ,information13                   varchar2(150)
  ,information14                   varchar2(150)
  ,information15                   varchar2(150)
  ,information16                   varchar2(150)
  ,information17                   varchar2(150)
  ,information18                   varchar2(150)
  ,information19                   varchar2(150)
  ,information20                   varchar2(150)
  ,information21                   varchar2(150)
  ,information22                   varchar2(150)
  ,information23                   varchar2(150)
  ,information24                   varchar2(150)
  ,information25                   varchar2(150)
  ,information26                   varchar2(150)
  ,information27                   varchar2(150)
  ,information28                   varchar2(150)
  ,information29                   varchar2(150)
  ,information30                   varchar2(150)
  ,attribute_category              varchar2(30)
  ,attribute1                      varchar2(150)
  ,attribute2                      varchar2(150)
  ,attribute3                      varchar2(150)
  ,attribute4                      varchar2(150)
  ,attribute5                      varchar2(150)
  ,attribute6                      varchar2(150)
  ,attribute7                      varchar2(150)
  ,attribute8                      varchar2(150)
  ,attribute9                      varchar2(150)
  ,attribute10                     varchar2(150)
  ,attribute11                     varchar2(150)
  ,attribute12                     varchar2(150)
  ,attribute13                     varchar2(150)
  ,attribute14                     varchar2(150)
  ,attribute15                     varchar2(150)
  ,attribute16                     varchar2(150)
  ,attribute17                     varchar2(150)
  ,attribute18                     varchar2(150)
  ,attribute19                     varchar2(150)
  ,attribute20                     varchar2(150)
  ,attribute21                     varchar2(150)
  ,attribute22                     varchar2(150)
  ,attribute23                     varchar2(150)
  ,attribute24                     varchar2(150)
  ,attribute25                     varchar2(150)
  ,attribute26                     varchar2(150)
  ,attribute27                     varchar2(150)
  ,attribute28                     varchar2(150)
  ,attribute29                     varchar2(150)
  ,attribute30                     varchar2(150)
  ,object_version_number           number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'PQH_ACCOMMODATIONS_F';
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
Procedure constraint_error
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
  (p_effective_date                   in date
  ,p_accommodation_id                 in number
  ,p_object_version_number            in number
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
--           p_base_key_value = :accommodation_id).
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
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
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
--           p_base_key_value = :accommodation_id).
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
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
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
--           p_base_key_value = :accommodation_id).
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
Procedure upd_effective_end_date
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_new_effective_end_date in date
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_object_version_number  out nocopy number
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
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_accommodation_id                 in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
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
  (p_accommodation_id               in number
  ,p_accommodation_name             in varchar2
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_location_id                    in number
  ,p_accommodation_desc             in varchar2
  ,p_accommodation_type             in varchar2
  ,p_style                          in varchar2
  ,p_address_line_1                 in varchar2
  ,p_address_line_2                 in varchar2
  ,p_address_line_3                 in varchar2
  ,p_town_or_city                   in varchar2
  ,p_country                        in varchar2
  ,p_postal_code                    in varchar2
  ,p_region_1                       in varchar2
  ,p_region_2                       in varchar2
  ,p_region_3                       in varchar2
  ,p_telephone_number_1             in varchar2
  ,p_telephone_number_2             in varchar2
  ,p_telephone_number_3             in varchar2
  ,p_floor_number                   in varchar2
  ,p_floor_area                     in number
  ,p_floor_area_measure_unit        in varchar2
  ,p_main_rooms                     in number
  ,p_family_size                    in number
  ,p_suitability_disabled           in varchar2
  ,p_rental_value                   in number
  ,p_rental_value_currency          in varchar2
  ,p_owner                          in varchar2
  ,p_comments                       in varchar2
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end pqh_acc_shd;

 

/
