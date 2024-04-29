--------------------------------------------------------
--  DDL for Package PER_PDS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PDS_INS" AUTHID CURRENT_USER as
/* $Header: pepdsrhi.pkh 120.1 2006/02/21 03:11:57 pdkundu noship $ */
--
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
  (p_period_of_service_id  in  number);
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
--      which will execute all private and Internal Development Use Only validation business rule
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
--
--   p_validate_df_flex
--     Optional parameter used to determine whether descriptive flexfield
--     validation is to be performed or bypassed. API calls that insert a PDS
--     row but are unable to provide mandatory PDS flex field values,
--     eg. CREATE_EMPLOYEE API will have the parameter value set TRUE
--
--   p_effective_date
--     Mandatory parameter used for calls to the standard lookup value
--     derivation procedures.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec              in out nocopy per_pds_shd.g_rec_type,
  p_effective_date   in     date,
  p_validate         in     boolean                default false,
  p_validate_df_flex in     boolean                default true
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
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
--   p_validate_df_flex
--     Optional parameter used to determine whether descriptive flexfield
--     validation is to be performed or bypassed.
--
--   p_effective_date
--     Mandatory parameter used for calls to the standard lookup value
--     derivation procedures.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  --
  -- 70.3 change a start.
  --
  p_period_of_service_id         out nocopy number,
  p_business_group_id            in number,
  p_person_id                    in number,
  p_date_start                   in date,
  p_comments                     in varchar2         default null,
  p_adjusted_svc_date            in date             default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_prior_employment_ssp_weeks   in number           default null,
  p_prior_employment_ssp_paid_to in date             default null,
  p_pds_information_category     in varchar2         default null,
  p_pds_information1             in varchar2         default null,
  p_pds_information2             in varchar2         default null,
  p_pds_information3             in varchar2         default null,
  p_pds_information4             in varchar2         default null,
  p_pds_information5             in varchar2         default null,
  p_pds_information6             in varchar2         default null,
  p_pds_information7             in varchar2         default null,
  p_pds_information8             in varchar2         default null,
  p_pds_information9             in varchar2         default null,
  p_pds_information10            in varchar2         default null,
  p_pds_information11            in varchar2         default null,
  p_pds_information12            in varchar2         default null,
  p_pds_information13            in varchar2         default null,
  p_pds_information14            in varchar2         default null,
  p_pds_information15            in varchar2         default null,
  p_pds_information16            in varchar2         default null,
  p_pds_information17            in varchar2         default null,
  p_pds_information18            in varchar2         default null,
  p_pds_information19            in varchar2         default null,
  p_pds_information20            in varchar2         default null,
  p_pds_information21            in varchar2         default null,
  p_pds_information22            in varchar2         default null,
  p_pds_information23            in varchar2         default null,
  p_pds_information24            in varchar2         default null,
  p_pds_information25            in varchar2         default null,
  p_pds_information26            in varchar2         default null,
  p_pds_information27            in varchar2         default null,
  p_pds_information28            in varchar2         default null,
  p_pds_information29            in varchar2         default null,
  p_pds_information30            in varchar2         default null,
  p_effective_date               in date,
  p_validate                     in boolean          default false,
  p_validate_df_flex             in boolean          default true
  );
  --
  -- 70.3 change a end.
  --
--
end per_pds_ins;

 

/
