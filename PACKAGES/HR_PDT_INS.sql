--------------------------------------------------------
--  DDL for Package HR_PDT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDT_INS" AUTHID CURRENT_USER as
/* $Header: hrpdtrhi.pkh 120.1.12010000.1 2008/07/28 03:39:04 appldev ship $ */
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
  (p_person_deployment_id  in  number);
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
  (p_rec                      in out nocopy hr_pdt_shd.g_rec_type
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
  (p_from_business_group_id         in     number
  ,p_to_business_group_id           in     number
  ,p_from_person_id                 in     number
  ,p_person_type_id                 in     number
  ,p_start_date                     in     date
  ,p_status                         in     varchar2
  ,p_to_person_id                   in     number   default null
  ,p_end_date                       in     date     default null
  ,p_deployment_reason              in     varchar2 default null
  ,p_employee_number                in     varchar2 default null
  ,p_leaving_reason                 in     varchar2 default null
  ,p_leaving_person_type_id         in     number   default null
  ,p_permanent                      in     varchar2 default null
  ,p_status_change_reason           in     varchar2 default null
  ,p_deplymt_policy_id              in     number   default null
  ,p_organization_id                in     number   default null
  ,p_location_id                    in     number   default null
  ,p_job_id                         in     number   default null
  ,p_position_id                    in     number   default null
  ,p_grade_id                       in     number   default null
  ,p_supervisor_id                  in     number   default null
  ,p_supervisor_assignment_id       in     number   default null
  ,p_retain_direct_reports          in     varchar2 default null
  ,p_payroll_id                     in     number   default null
  ,p_pay_basis_id                   in     number   default null
  ,p_proposed_salary                in     varchar2 default null
  ,p_people_group_id                in     number   default null
  ,p_soft_coding_keyflex_id         in     number   default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_ass_status_change_reason       in     varchar2 default null
  ,p_assignment_category            in     varchar2 default null
  ,p_per_information_category       in     varchar2 default null
  ,p_per_information1               in     varchar2 default null
  ,p_per_information2               in     varchar2 default null
  ,p_per_information3               in     varchar2 default null
  ,p_per_information4               in     varchar2 default null
  ,p_per_information5               in     varchar2 default null
  ,p_per_information6               in     varchar2 default null
  ,p_per_information7               in     varchar2 default null
  ,p_per_information8               in     varchar2 default null
  ,p_per_information9               in     varchar2 default null
  ,p_per_information10              in     varchar2 default null
  ,p_per_information11              in     varchar2 default null
  ,p_per_information12              in     varchar2 default null
  ,p_per_information13              in     varchar2 default null
  ,p_per_information14              in     varchar2 default null
  ,p_per_information15              in     varchar2 default null
  ,p_per_information16              in     varchar2 default null
  ,p_per_information17              in     varchar2 default null
  ,p_per_information18              in     varchar2 default null
  ,p_per_information19              in     varchar2 default null
  ,p_per_information20              in     varchar2 default null
  ,p_per_information21              in     varchar2 default null
  ,p_per_information22              in     varchar2 default null
  ,p_per_information23              in     varchar2 default null
  ,p_per_information24              in     varchar2 default null
  ,p_per_information25              in     varchar2 default null
  ,p_per_information26              in     varchar2 default null
  ,p_per_information27              in     varchar2 default null
  ,p_per_information28              in     varchar2 default null
  ,p_per_information29              in     varchar2 default null
  ,p_per_information30              in     varchar2 default null
  ,p_person_deployment_id              out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_pdt_ins;

/
