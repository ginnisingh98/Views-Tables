--------------------------------------------------------
--  DDL for Package PER_ADD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_INS" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_address_id  in  number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--   The following attributes in p_rec are mandatory: address_id,
--   business_group_id, date_from, person_id, primary_flag and style.
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
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--   p_rec
--     The primary key and object version number details for the inserted
--     address record will be returned in p_rec.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. A failure will occur if any of the following conditions are
--   found :
--     1) All of the mandatory arguments have not been set.
--     2) The p_rec.business_group_id business group does not exist.
--     3) The p_rec.date_from value is greater than the p_rec.date_to
--     4) The p_rec.person_id person does not exist.
--     5) The p_rec.primary_flag not in 'Y' or 'N'.
--     6) A primary address already exists for the p_rec.person_id within
--        the date range.
--     7) The p_rec.style value defined is not in the correct address
--        format for the UK.
--     8) The p_rec.address_type value does not exist on hr_lookups.
--     9) The p_rec.country value does not exist on fnd_territories.
--     10)The p_rec.date_to value is less than the p_rec.date_from
--        value.
--     11)The p_rec.postal_code value is more than 8 characters long.
--     12)The p_rec.region_1 value does not exist on fnd_common_lookups
--        or has been disabled or is linked to a non GB address style.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec               in out nocopy per_add_shd.g_rec_type
  ,p_validate          in     boolean default false
  ,p_effective_date    in     date
  ,p_validate_county   in     boolean          default true
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--   Refer to the record interface for details.
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
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--   p_address_id
--     will be set to the primary key value of the inserted address
--   p_object_version_number
--     will be set to the object version number of the inserted address.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back. Refer to the ins record interface for details of possible
--   failures.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_address_id                       out nocopy number
  ,p_business_group_id            in      number           default null -- HR/TCA merge
  ,p_person_id                    in      number           default null -- HR/TCA merge
  ,p_date_from                    in      date
  ,p_primary_flag                 in      varchar2
  ,p_style                        in      varchar2
  ,p_address_line1                in      varchar2         default null
  ,p_address_line2                in      varchar2         default null
  ,p_address_line3                in      varchar2         default null
  ,p_address_type                 in      varchar2         default null
  ,p_comments                     in      long         default null
  ,p_country                      in      varchar2         default null
  ,p_date_to                      in      date             default null
  ,p_postal_code                  in      varchar2         default null
  ,p_region_1                     in      varchar2         default null
  ,p_region_2                     in      varchar2         default null
  ,p_region_3                     in      varchar2         default null
  ,p_telephone_number_1           in      varchar2         default null
  ,p_telephone_number_2           in      varchar2         default null
  ,p_telephone_number_3           in      varchar2         default null
  ,p_town_or_city                 in      varchar2         default null
  ,p_request_id                   in      number           default null
  ,p_program_application_id       in      number           default null
  ,p_program_id                   in      number           default null
  ,p_program_update_date          in      date             default null
  ,p_addr_attribute_category      in      varchar2         default null
  ,p_addr_attribute1              in      varchar2         default null
  ,p_addr_attribute2              in      varchar2         default null
  ,p_addr_attribute3              in      varchar2         default null
  ,p_addr_attribute4              in      varchar2         default null
  ,p_addr_attribute5              in      varchar2         default null
  ,p_addr_attribute6              in      varchar2         default null
  ,p_addr_attribute7              in      varchar2         default null
  ,p_addr_attribute8              in      varchar2         default null
  ,p_addr_attribute9              in      varchar2         default null
  ,p_addr_attribute10             in      varchar2         default null
  ,p_addr_attribute11             in      varchar2         default null
  ,p_addr_attribute12             in      varchar2         default null
  ,p_addr_attribute13             in      varchar2         default null
  ,p_addr_attribute14             in      varchar2         default null
  ,p_addr_attribute15             in      varchar2         default null
  ,p_addr_attribute16             in      varchar2         default null
  ,p_addr_attribute17             in      varchar2         default null
  ,p_addr_attribute18             in      varchar2         default null
  ,p_addr_attribute19             in      varchar2         default null
  ,p_addr_attribute20             in      varchar2         default null
  ,p_add_information13            in      varchar2         default null
  ,p_add_information14            in      varchar2         default null
  ,p_add_information15            in      varchar2         default null
  ,p_add_information16            in      varchar2         default null
  ,p_add_information17            in      varchar2         default null
  ,p_add_information18            in      varchar2         default null
  ,p_add_information19            in      varchar2         default null
  ,p_add_information20            in      varchar2         default null
  ,p_object_version_number           out nocopy  number
  ,p_party_id                     in      number           default null
  ,p_validate                     in      boolean          default false
  ,p_effective_date               in      date
  ,p_validate_county              in      boolean          default true
  );
--
end per_add_ins;

/
