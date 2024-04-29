--------------------------------------------------------
--  DDL for Package IRC_ISC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ISC_INS" AUTHID CURRENT_USER as
/* $Header: iriscrhi.pkh 120.0 2005/07/26 15:11:23 mbocutt noship $ */
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
  (p_search_criteria_id  in  number);
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
--   If an error has occurred, an error message will be raised.
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_isc_shd.g_rec_type
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
--   If an error has occurred, an error message will be raised.
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
  (p_effective_date               in     date
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_search_name                    in     varchar2 default null
  ,p_search_type                    in     varchar2 default null
  ,p_location                       in     varchar2 default null
  ,p_distance_to_location           in     varchar2 default null
  ,p_geocode_location               in     varchar2 default null
  ,p_geocode_country                in     varchar2 default null
  ,p_derived_location               in     varchar2 default null
  ,p_location_id                    in     number   default null
  ,p_longitude                      in     number   default null
  ,p_latitude                       in     number   default null
  ,p_employee                       in     varchar2 default null
  ,p_contractor                     in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_keywords                       in     varchar2 default null
  ,p_travel_percentage              in     number   default null
  ,p_min_salary                     in     number   default null
  ,p_max_salary                     in     number   default null
  ,p_salary_currency                in     varchar2 default null
  ,p_salary_period                  in     varchar2 default null
  ,p_match_competence               in     varchar2 default null
  ,p_match_qualification            in     varchar2 default null
  ,p_job_title                      in     varchar2 default null
  ,p_department                     in     varchar2 default null
  ,p_professional_area              in     varchar2 default null
  ,p_work_at_home                   in     varchar2 default null
  ,p_min_qual_level                 in     number   default null
  ,p_max_qual_level                 in     number   default null
  ,p_use_for_matching               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_isc_information_category       in     varchar2 default null
  ,p_isc_information1               in     varchar2 default null
  ,p_isc_information2               in     varchar2 default null
  ,p_isc_information3               in     varchar2 default null
  ,p_isc_information4               in     varchar2 default null
  ,p_isc_information5               in     varchar2 default null
  ,p_isc_information6               in     varchar2 default null
  ,p_isc_information7               in     varchar2 default null
  ,p_isc_information8               in     varchar2 default null
  ,p_isc_information9               in     varchar2 default null
  ,p_isc_information10              in     varchar2 default null
  ,p_isc_information11              in     varchar2 default null
  ,p_isc_information12              in     varchar2 default null
  ,p_isc_information13              in     varchar2 default null
  ,p_isc_information14              in     varchar2 default null
  ,p_isc_information15              in     varchar2 default null
  ,p_isc_information16              in     varchar2 default null
  ,p_isc_information17              in     varchar2 default null
  ,p_isc_information18              in     varchar2 default null
  ,p_isc_information19              in     varchar2 default null
  ,p_isc_information20              in     varchar2 default null
  ,p_isc_information21              in     varchar2 default null
  ,p_isc_information22              in     varchar2 default null
  ,p_isc_information23              in     varchar2 default null
  ,p_isc_information24              in     varchar2 default null
  ,p_isc_information25              in     varchar2 default null
  ,p_isc_information26              in     varchar2 default null
  ,p_isc_information27              in     varchar2 default null
  ,p_isc_information28              in     varchar2 default null
  ,p_isc_information29              in     varchar2 default null
  ,p_isc_information30              in     varchar2 default null
  ,p_date_posted                    in     varchar2 default null
  ,p_search_criteria_id                out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end irc_isc_ins;

 

/
