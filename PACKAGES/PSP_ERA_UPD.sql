--------------------------------------------------------
--  DDL for Package PSP_ERA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERA_UPD" AUTHID CURRENT_USER as
/* $Header: PSPEARHS.pls 120.1 2006/03/26 01:08:35 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
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
Procedure upd
  (p_rec                          in out nocopy psp_era_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
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
Procedure upd
  (p_effort_report_approval_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effort_report_detail_id      in     number    default hr_api.g_number
  ,p_wf_role_name                 in     varchar2  default hr_api.g_varchar2
  ,p_wf_orig_system_id            in     number    default hr_api.g_number
  ,p_wf_orig_system               in     varchar2  default hr_api.g_varchar2
  ,p_approver_order_num           in     number    default hr_api.g_number
  ,p_approval_status              in     varchar2  default hr_api.g_varchar2
  ,p_response_date                in     date      default hr_api.g_date
  ,p_actual_cost_share            in     number    default hr_api.g_number
  ,p_overwritten_effort_percent   in     number    default hr_api.g_number
  ,p_wf_item_key                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_pera_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_pera_information1            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information2            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information3            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information4            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information5            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information6            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information7            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information8            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information9            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information10           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information11           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information12           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information13           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information14           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information15           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information16           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information17           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information18           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information19           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information20           in     varchar2  default hr_api.g_varchar2
  ,p_wf_role_display_name         in     varchar2  default hr_api.g_varchar2
  ,p_notification_id              in     number    default hr_api.g_number
  ,p_eff_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eff_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information15            in     varchar2  default hr_api.g_varchar2
  );
--
end psp_era_upd;

 

/
