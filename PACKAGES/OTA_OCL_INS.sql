--------------------------------------------------------
--  DDL for Package OTA_OCL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OCL_INS" AUTHID CURRENT_USER as
/* $Header: otoclrhi.pkh 120.1 2007/02/07 09:18:56 niarora noship $ */
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
  ,p_rec                          in out nocopy ota_ocl_shd.g_rec_type
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
  ,p_competence_id                  in     number
  ,p_language_code                    in     varchar2
  ,p_business_group_id              in     number
  ,p_min_proficiency_level_id       in     number   default null
  ,p_ocl_information_category       in     varchar2 default null
  ,p_ocl_information1               in     varchar2 default null
  ,p_ocl_information2               in     varchar2 default null
  ,p_ocl_information3               in     varchar2 default null
  ,p_ocl_information4               in     varchar2 default null
  ,p_ocl_information5               in     varchar2 default null
  ,p_ocl_information6               in     varchar2 default null
  ,p_ocl_information7               in     varchar2 default null
  ,p_ocl_information8               in     varchar2 default null
  ,p_ocl_information9               in     varchar2 default null
  ,p_ocl_information10              in     varchar2 default null
  ,p_ocl_information11              in     varchar2 default null
  ,p_ocl_information12              in     varchar2 default null
  ,p_ocl_information13              in     varchar2 default null
  ,p_ocl_information14              in     varchar2 default null
  ,p_ocl_information15              in     varchar2 default null
  ,p_ocl_information16              in     varchar2 default null
  ,p_ocl_information17              in     varchar2 default null
  ,p_ocl_information18              in     varchar2 default null
  ,p_ocl_information19              in     varchar2 default null
  ,p_ocl_information20              in     varchar2 default null
  ,p_competence_language_id            out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end ota_ocl_ins;

/
