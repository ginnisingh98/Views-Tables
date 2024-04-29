--------------------------------------------------------
--  DDL for Package PQH_STS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_STS_UPD" AUTHID CURRENT_USER as
/* $Header: pqstsrhi.pkh 120.0 2005/05/29 02:43 appldev noship $ */
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_sts_shd.g_rec_type
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
  (p_effective_date               in     date
  ,p_statutory_situation_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_name               in     varchar2  default hr_api.g_varchar2
  ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_sub_type                     in     varchar2  default hr_api.g_varchar2
  ,p_source                       in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
  ,p_is_default                   in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_type                 in     varchar2  default hr_api.g_varchar2
  ,p_employee_agreement_needed    in     varchar2  default hr_api.g_varchar2
  ,p_manager_agreement_needed     in     varchar2  default hr_api.g_varchar2
  ,p_print_arrette                in     varchar2  default hr_api.g_varchar2
  ,p_reserve_position             in     varchar2  default hr_api.g_varchar2
  ,p_allow_progressions           in     varchar2  default hr_api.g_varchar2
  ,p_extend_probation_period      in     varchar2  default hr_api.g_varchar2
  ,p_remuneration_paid            in     varchar2  default hr_api.g_varchar2
  ,p_pay_share                    in     number    default hr_api.g_number
  ,p_pay_periods                  in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_first_period_max_duration    in     number    default hr_api.g_number
  ,p_min_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_whole_career    in     number    default hr_api.g_number
  ,p_renewable_allowed            in     varchar2  default hr_api.g_varchar2
  ,p_max_no_of_renewals           in     number    default hr_api.g_number
  ,p_max_duration_per_renewal     in     number    default hr_api.g_number
  ,p_max_tot_continuous_duration  in     number    default hr_api.g_number
  ,p_remunerate_assign_status_id  in     number    default hr_api.g_number
  );
--
end pqh_sts_upd;

 

/
