--------------------------------------------------------
--  DDL for Package PER_CPN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPN_INS" AUTHID CURRENT_USER as
/* $Header: pecpnrhi.pkh 120.0 2005/05/31 07:14:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) If the p_validate parameter has been set to true then a savepoint is
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
--   6) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     process and is rollbacked at the end of the process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate parameter has been set to true
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
  p_rec        		in out nocopy per_cpn_shd.g_rec_type,
  p_effective_date	in date    default null,
  p_validate   		in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Pre Conditions:
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
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
  p_competence_id                out nocopy number,
  p_name                         in varchar2,
  p_business_group_id            in number           default null,
  p_object_version_number        out nocopy number,
  p_description                  in varchar2         default null,
  p_date_from 			 in date,
  p_date_to 			 in date 	     default null,
  p_behavioural_indicator        in varchar2         default null,
  p_certification_required       in varchar2         default 'N',
  p_evaluation_method            in varchar2         default null,
  p_renewal_period_frequency     in number           default null,
  p_renewal_period_units         in varchar2         default null,
  p_rating_scale_id		 in number	     default null,
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
  p_effective_date               in date             ,
  p_validate                     in boolean   	     default false,
  p_competence_alias             in varchar2         default null,
  p_competence_definition_id     in number           default null
 ,p_competence_cluster            in varchar2        default null
 ,p_unit_standard_id              in varchar2        default null
 ,p_credit_type                   in varchar2        default null
 ,p_credits                       in number          default null
 ,p_level_type                    in varchar2        default null
 ,p_level_number                  in number          default null
 ,p_field                         in varchar2        default null
 ,p_sub_field                     in varchar2        default null
 ,p_provider                      in varchar2        default null
 ,p_qa_organization               in varchar2        default null
 ,p_information_category          in varchar2        default null
 ,p_information1                  in varchar2        default null
 ,p_information2                  in varchar2        default null
 ,p_information3                  in varchar2        default null
 ,p_information4                  in varchar2        default null
 ,p_information5                  in varchar2        default null
 ,p_information6                  in varchar2        default null
 ,p_information7                  in varchar2        default null
 ,p_information8                  in varchar2        default null
 ,p_information9                  in varchar2        default null
 ,p_information10                 in varchar2        default null
 ,p_information11                 in varchar2        default null
 ,p_information12                 in varchar2        default null
 ,p_information13                 in varchar2        default null
 ,p_information14                 in varchar2        default null
 ,p_information15                 in varchar2        default null
 ,p_information16                 in varchar2        default null
 ,p_information17                 in varchar2        default null
 ,p_information18                 in varchar2        default null
 ,p_information19                 in varchar2        default null
 ,p_information20                 in varchar2        default null
 );
--
end per_cpn_ins;

 

/
