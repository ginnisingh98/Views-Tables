--------------------------------------------------------
--  DDL for Package PQP_SHP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SHP_INS" AUTHID CURRENT_USER as
/* $Header: pqshprhi.pkh 120.0.12010000.1 2008/07/28 11:23:18 appldev ship $ */
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
  (
    p_rec                          in out nocopy pqp_shp_shd.g_rec_type
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
  (p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_employer_name                  in     varchar2 default null
  ,p_employer_address               in     varchar2 default null
  ,p_employer_type                  in     varchar2 default null
  ,p_employer_subtype               in     varchar2 default null
  ,p_period_years                   in     number   default null
  ,p_period_days                    in     number   default null
  ,p_description                    in     varchar2 default null
  ,p_continuous_service             in     varchar2 default null
  ,p_all_assignments                in     varchar2 default null
  ,p_shp_attribute_category         in     varchar2 default null
  ,p_shp_attribute1                 in     varchar2 default null
  ,p_shp_attribute2                 in     varchar2 default null
  ,p_shp_attribute3                 in     varchar2 default null
  ,p_shp_attribute4                 in     varchar2 default null
  ,p_shp_attribute5                 in     varchar2 default null
  ,p_shp_attribute6                 in     varchar2 default null
  ,p_shp_attribute7                 in     varchar2 default null
  ,p_shp_attribute8                 in     varchar2 default null
  ,p_shp_attribute9                 in     varchar2 default null
  ,p_shp_attribute10                in     varchar2 default null
  ,p_shp_attribute11                in     varchar2 default null
  ,p_shp_attribute12                in     varchar2 default null
  ,p_shp_attribute13                in     varchar2 default null
  ,p_shp_attribute14                in     varchar2 default null
  ,p_shp_attribute15                in     varchar2 default null
  ,p_shp_attribute16                in     varchar2 default null
  ,p_shp_attribute17                in     varchar2 default null
  ,p_shp_attribute18                in     varchar2 default null
  ,p_shp_attribute19                in     varchar2 default null
  ,p_shp_attribute20                in     varchar2 default null
  ,p_shp_information_category       in     varchar2 default null
  ,p_shp_information1               in     varchar2 default null
  ,p_shp_information2               in     varchar2 default null
  ,p_shp_information3               in     varchar2 default null
  ,p_shp_information4               in     varchar2 default null
  ,p_shp_information5               in     varchar2 default null
  ,p_shp_information6               in     varchar2 default null
  ,p_shp_information7               in     varchar2 default null
  ,p_shp_information8               in     varchar2 default null
  ,p_shp_information9               in     varchar2 default null
  ,p_shp_information10              in     varchar2 default null
  ,p_shp_information11              in     varchar2 default null
  ,p_shp_information12              in     varchar2 default null
  ,p_shp_information13              in     varchar2 default null
  ,p_shp_information14              in     varchar2 default null
  ,p_shp_information15              in     varchar2 default null
  ,p_shp_information16              in     varchar2 default null
  ,p_shp_information17              in     varchar2 default null
  ,p_shp_information18              in     varchar2 default null
  ,p_shp_information19              in     varchar2 default null
  ,p_shp_information20              in     varchar2 default null
  ,p_service_history_period_id         out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end pqp_shp_ins;

/
