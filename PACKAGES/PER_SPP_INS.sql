--------------------------------------------------------
--  DDL for Package PER_SPP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SPP_INS" AUTHID CURRENT_USER as
/* $Header: pespprhi.pkh 120.1 2005/12/12 21:15:29 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
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
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
  (p_effective_date in     date
  ,p_rec            in out nocopy per_spp_shd.g_rec_type
  ,p_replace_future_spp in boolean default false  -- Added for bug 2977842.
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
--   (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_step_id                        in     number
  ,p_auto_increment_flag            in     varchar2
--  ,p_parent_spine_id                in     number
  ,p_reason                         in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_increment_number               in     number   default null
  ,p_information1                   in varchar2 default null
  ,p_information2                   in varchar2 default null
  ,p_information3                   in varchar2 default null
  ,p_information4                   in varchar2 default null
  ,p_information5                   in varchar2 default null
  ,p_information6                   in varchar2 default null
  ,p_information7                   in varchar2 default null
  ,p_information8                   in varchar2 default null
  ,p_information9                   in varchar2 default null
  ,p_information10                  in varchar2 default null
  ,p_information11                  in varchar2 default null
  ,p_information12                  in varchar2 default null
  ,p_information13                  in varchar2 default null
  ,p_information14                  in varchar2 default null
  ,p_information15                  in varchar2 default null
  ,p_information16                  in varchar2 default null
  ,p_information17                  in varchar2 default null
  ,p_information18                  in varchar2 default null
  ,p_information19                  in varchar2 default null
  ,p_information20                  in varchar2 default null
  ,p_information21                  in varchar2 default null
  ,p_information22                  in varchar2 default null
  ,p_information23                  in varchar2 default null
  ,p_information24                  in varchar2 default null
  ,p_information25                  in varchar2 default null
  ,p_information26                  in varchar2 default null
  ,p_information27                  in varchar2 default null
  ,p_information28                  in varchar2 default null
  ,p_information29                  in varchar2 default null
  ,p_information30                  in varchar2 default null
  ,p_information_category           in varchar2 default null
  ,p_placement_id                      out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_replace_future_spp             in boolean default false --Bug 2977842.
  );
--
end per_spp_ins;

 

/
