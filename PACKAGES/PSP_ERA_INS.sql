--------------------------------------------------------
--  DDL for Package PSP_ERA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERA_INS" AUTHID CURRENT_USER as
/* $Header: PSPEARHS.pls 120.1 2006/03/26 01:08:35 dpaudel noship $ */
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
  (p_effort_report_approval_id  in  number);
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
  (p_rec                      in out nocopy psp_era_shd.g_rec_type
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
  (p_effort_report_detail_id        in     number   default null
  ,p_wf_role_name                   in     varchar2 default null
  ,p_wf_orig_system_id              in     number   default null
  ,p_wf_orig_system                 in     varchar2 default null
  ,p_approver_order_num             in     number   default null
  ,p_approval_status                in     varchar2 default null
  ,p_response_date                  in     date     default null
  ,p_actual_cost_share              in     number   default null
  ,p_overwritten_effort_percent     in     number   default null
  ,p_wf_item_key                    in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_pera_information_category      in     varchar2 default null
  ,p_pera_information1              in     varchar2 default null
  ,p_pera_information2              in     varchar2 default null
  ,p_pera_information3              in     varchar2 default null
  ,p_pera_information4              in     varchar2 default null
  ,p_pera_information5              in     varchar2 default null
  ,p_pera_information6              in     varchar2 default null
  ,p_pera_information7              in     varchar2 default null
  ,p_pera_information8              in     varchar2 default null
  ,p_pera_information9              in     varchar2 default null
  ,p_pera_information10             in     varchar2 default null
  ,p_pera_information11             in     varchar2 default null
  ,p_pera_information12             in     varchar2 default null
  ,p_pera_information13             in     varchar2 default null
  ,p_pera_information14             in     varchar2 default null
  ,p_pera_information15             in     varchar2 default null
  ,p_pera_information16             in     varchar2 default null
  ,p_pera_information17             in     varchar2 default null
  ,p_pera_information18             in     varchar2 default null
  ,p_pera_information19             in     varchar2 default null
  ,p_pera_information20             in     varchar2 default null
  ,p_wf_role_display_name           in     varchar2 default null
  ,p_notification_id                in     number   default null
  ,p_eff_information_category       in     varchar2 default null
  ,p_eff_information1               in     varchar2 default null
  ,p_eff_information2               in     varchar2 default null
  ,p_eff_information3               in     varchar2 default null
  ,p_eff_information4               in     varchar2 default null
  ,p_eff_information5               in     varchar2 default null
  ,p_eff_information6               in     varchar2 default null
  ,p_eff_information7               in     varchar2 default null
  ,p_eff_information8               in     varchar2 default null
  ,p_eff_information9               in     varchar2 default null
  ,p_eff_information10              in     varchar2 default null
  ,p_eff_information11              in     varchar2 default null
  ,p_eff_information12              in     varchar2 default null
  ,p_eff_information13              in     varchar2 default null
  ,p_eff_information14              in     varchar2 default null
  ,p_eff_information15              in     varchar2 default null
  ,p_effort_report_approval_id         out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end psp_era_ins;

 

/
