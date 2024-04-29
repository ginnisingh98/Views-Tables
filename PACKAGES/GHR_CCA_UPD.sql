--------------------------------------------------------
--  DDL for Package GHR_CCA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CCA_UPD" AUTHID CURRENT_USER as
/* $Header: ghccarhi.pkh 120.0 2005/05/29 02:50:17 appldev noship $ */
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
  ,p_rec                          in out nocopy ghr_cca_shd.g_rec_type
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
  ,p_compl_appeal_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_appeal_date                  in     date      default hr_api.g_date
  ,p_appealed_to                  in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_appeal            in     varchar2  default hr_api.g_varchar2
  ,p_source_decision_date         in     date      default hr_api.g_date
  ,p_docket_num                   in     varchar2  default hr_api.g_varchar2
  ,p_org_notified_of_appeal       in     date      default hr_api.g_date
  ,p_agency_recvd_req_for_files   in     date      default hr_api.g_date
  ,p_files_due                    in     date      default hr_api.g_date
  ,p_files_forwd                  in     date      default hr_api.g_date
  ,p_agcy_recvd_appellant_brief   in     date      default hr_api.g_date
  ,p_agency_brief_due             in     date      default hr_api.g_date
  ,p_appellant_brief_forwd_org    in     date      default hr_api.g_date
  ,p_org_forwd_brief_to_agency    in     date      default hr_api.g_date
  ,p_agency_brief_forwd           in     date      default hr_api.g_date
  ,p_decision_date                in     date      default hr_api.g_date
  ,p_dec_recvd_by_agency          in     date      default hr_api.g_date
  ,p_decision                     in     varchar2  default hr_api.g_varchar2
  ,p_dec_forwd_to_org             in     date      default hr_api.g_date
  ,p_agency_rfr_suspense          in     date      default hr_api.g_date
  ,p_request_for_rfr              in     date      default hr_api.g_date
  ,p_rfr_docket_num               in     varchar2  default hr_api.g_varchar2
  ,p_rfr_requested_by             in     varchar2  default hr_api.g_varchar2
  ,p_agency_rfr_due               in     date      default hr_api.g_date
  ,p_rfr_forwd_to_org             in     date      default hr_api.g_date
  ,p_org_forwd_rfr_to_agency      in     date      default hr_api.g_date
  ,p_agency_forwd_rfr_ofo         in     date      default hr_api.g_date
  ,p_rfr_decision                 in     varchar2  default hr_api.g_varchar2
  ,p_rfr_decision_date            in     date      default hr_api.g_date
  ,p_agency_recvd_rfr_dec         in     date      default hr_api.g_date
  ,p_rfr_decision_forwd_to_org    in     date      default hr_api.g_date
  );
--
end ghr_cca_upd;

 

/
