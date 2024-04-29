--------------------------------------------------------
--  DDL for Package PER_DPF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DPF_INS" AUTHID CURRENT_USER as
/* $Header: pedpfrhi.pkh 120.0 2005/05/31 07:45:06 appldev noship $ */
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
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.
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
  p_rec            in out nocopy per_dpf_shd.g_rec_type,
  p_effective_date in date
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
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed.
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
  p_deployment_factor_id         out nocopy number,
  p_position_id                  in number           default null,
  p_person_id                    in number           default null,
  p_job_id                       in number           default null,
  p_business_group_id            in number,
  p_work_any_country             in varchar2,
  p_work_any_location            in varchar2,
  p_relocate_domestically        in varchar2,
  p_relocate_internationally     in varchar2,
  p_travel_required              in varchar2,
  p_country1                     in varchar2         default null,
  p_country2                     in varchar2         default null,
  p_country3                     in varchar2         default null,
  p_work_duration                in varchar2         default null,
  p_work_schedule                in varchar2         default null,
  p_work_hours                   in varchar2         default null,
  p_fte_capacity                 in varchar2         default null,
  p_visit_internationally        in varchar2         default null,
  p_only_current_location        in varchar2         default null,
  p_no_country1                  in varchar2         default null,
  p_no_country2                  in varchar2         default null,
  p_no_country3                  in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_earliest_available_date      in date             default null,
  p_available_for_transfer       in varchar2         default null,
  p_relocation_preference        in varchar2         default null,
  p_relocation_required          in varchar2         default null,
  p_passport_required            in varchar2         default null,
  p_location1                    in varchar2         default null,
  p_location2                    in varchar2         default null,
  p_location3                    in varchar2         default null,
  p_other_requirements           in varchar2         default null,
  p_service_minimum              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
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
  p_attribute20                  in varchar2         default null
  );
--
end per_dpf_ins;

 

/
