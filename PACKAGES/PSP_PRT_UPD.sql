--------------------------------------------------------
--  DDL for Package PSP_PRT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PRT_UPD" AUTHID CURRENT_USER as
/* $Header: PSPRTRHS.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
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
  (p_rec                          in out nocopy psp_prt_shd.g_rec_type
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
  (p_template_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_template_name                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_report_type                  in     varchar2  default hr_api.g_varchar2
  ,p_period_frequency_id          in     number    default hr_api.g_number
  ,p_report_template_code         in     varchar2  default hr_api.g_varchar2
  ,p_approval_type                in     varchar2  default hr_api.g_varchar2
  ,p_preview_effort_report_flag   in     varchar2  default hr_api.g_varchar2
  ,p_hundred_pcent_eff_at_per_asg in     varchar2  default hr_api.g_varchar2
  ,p_selection_match_level        in     varchar2  default hr_api.g_varchar2
  ,p_display_all_emp_distrib_flag in     varchar2  default hr_api.g_varchar2
  ,p_manual_entry_override_flag   in     varchar2  default hr_api.g_varchar2
  ,p_custom_approval_code         in     varchar2  default hr_api.g_varchar2
  ,p_sup_levels                   in     number    default hr_api.g_number
  ,p_notification_reminder_in_day in     number    default hr_api.g_number
  ,p_sprcd_tolerance_amt          in     number    default hr_api.g_number
  ,p_sprcd_tolerance_percent      in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  );
--
end psp_prt_upd;

 

/
