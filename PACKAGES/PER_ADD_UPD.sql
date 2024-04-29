--------------------------------------------------------
--  DDL for Package PER_ADD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_UPD" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy per_add_shd.g_rec_type)
         Return per_add_shd.g_rec_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--   p_rec
--     Contains the attributes of the address record.
--   p_validate_county
--     if true, then if the geocodes (VERTEX) data is installed then a US
--     address will be validated against it. This is the default behaviour.
--     If set to false then region_1 will not be validated.
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
--   p_rec.object_version_number will be set with the new object_version_number
--   for the address.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the business rules/conditions
--   are found:
--     1) All of the mandatory arguments have not been set.
--     2) An attempt is made to update on of the following attributes:
--        address_id, business_group_id, person_id and style.
--     3) The p_rec.date_from is greater than p_rec.date_to.
--     4) If the address being updated is a primary address, the new value
--        for p_rec.date_from should not leave any non-primary addresses
--        without a corresponding primary within the date range.
--     5) The value for p_rec.primary_flag must be in 'Y' or 'N'.
--     6) If the address is updated to a primary address, no other primary
--        addresses should exist within the same date range.
--     7) The p_rec.address_type does not exist, or has been disabled, or
--        is not currently date effective on hr_lookups.
--     8) The p_rec.country value does exist on fnd_territories.
--     9) The p_rec.date_to value is less than p_rec.date_from.
--     10)If the address being updated is a primary address, the new value
--        for p_rec.date_to should not leave any non-primary addresses
--        without a corresponding primary within the date range.
--     11)The p_rec.postal_code should not be more than 8 characters long.
--     12)The p_rec.region_1 value should exist on fnd_common_lookups.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                in out nocopy per_add_shd.g_rec_type
  ,p_validate           in     boolean  default false
  ,p_effective_date     in     date
  ,p_prflagval_override in     boolean  default false
  ,p_validate_county    in     boolean  default true
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd>-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--   p_validate_county
--     if true, then if the geocodes (VERTEX) data is installed then a US
--     address will be validated against it. This is the default behaviour.
--     If set to false then region_1 will not be validated.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--   p_object_version_number will be set with the new object_version_number
--   for the address.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the upd record interface for details of possible
--   failures.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_address_id                   in number
  ,p_business_group_id            in number           default hr_api.g_number
  ,p_person_id                    in number           default hr_api.g_number
-- 70.2 change start.
  ,p_date_from                    in date             default hr_api.g_date
-- 70.2 change end.
-- Start of fix for Bug #2431588
  ,p_primary_flag                 in varchar2         default hr_api.g_varchar2
-- End of fix for Bug #2431588
  ,p_address_line1                in varchar2         default hr_api.g_varchar2
  ,p_address_line2                in varchar2         default hr_api.g_varchar2
  ,p_address_line3                in varchar2         default hr_api.g_varchar2
  ,p_address_type                 in varchar2         default hr_api.g_varchar2
  ,p_comments                     in long             default hr_api.g_varchar2
  ,p_country                      in varchar2         default hr_api.g_varchar2
  ,p_date_to                      in date             default hr_api.g_date
  ,p_postal_code                  in varchar2         default hr_api.g_varchar2
  ,p_region_1                     in varchar2         default hr_api.g_varchar2
  ,p_region_2                     in varchar2         default hr_api.g_varchar2
  ,p_region_3                     in varchar2         default hr_api.g_varchar2
  ,p_telephone_number_1           in varchar2         default hr_api.g_varchar2
  ,p_telephone_number_2           in varchar2         default hr_api.g_varchar2
  ,p_telephone_number_3           in varchar2         default hr_api.g_varchar2
  ,p_town_or_city                 in varchar2         default hr_api.g_varchar2
  ,p_request_id                   in number           default hr_api.g_number
  ,p_program_application_id       in number           default hr_api.g_number
  ,p_program_id                   in number           default hr_api.g_number
  ,p_program_update_date          in date             default hr_api.g_date
  ,p_addr_attribute_category      in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute1              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute2              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute3              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute4              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute5              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute6              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute7              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute8              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute9              in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute10             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute11             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute12             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute13             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute14             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute15             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute16             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute17             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute18             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute19             in varchar2         default hr_api.g_varchar2
  ,p_addr_attribute20             in varchar2         default hr_api.g_varchar2
  ,p_add_information13            in varchar2         default hr_api.g_varchar2
  ,p_add_information14            in varchar2         default hr_api.g_varchar2
  ,p_add_information15            in varchar2         default hr_api.g_varchar2
  ,p_add_information16            in varchar2         default hr_api.g_varchar2
  ,p_add_information17            in varchar2         default hr_api.g_varchar2
  ,p_add_information18            in varchar2         default hr_api.g_varchar2
  ,p_add_information19            in varchar2         default hr_api.g_varchar2
  ,p_add_information20            in varchar2         default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_party_id                     in number           default hr_api.g_number
  ,p_validate                     in boolean          default false
  ,p_effective_date               in date
  ,p_prflagval_override           in boolean          default false
  ,p_validate_county              in boolean          default true
  ,p_style                        in varchar2         default hr_api.g_varchar2
  );
--
end per_add_upd;

/
