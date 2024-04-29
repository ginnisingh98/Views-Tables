--------------------------------------------------------
--  DDL for Package GHR_CAA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CAA_INS" AUTHID CURRENT_USER as
/* $Header: ghcaarhi.pkh 120.0 2005/05/29 02:47:19 appldev noship $ */
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
  (p_compl_agency_appeal_id  in  number);
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
  ,p_rec                          in out nocopy ghr_caa_shd.g_rec_type
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
  ,p_complaint_id                   in     number
  ,p_appeal_date                    in     date     default null
  ,p_reason_for_appeal              in     varchar2 default null
  ,p_source_decision_date           in     date     default null
  ,p_docket_num                     in     varchar2 default null
  ,p_agency_recvd_req_for_files     in     date     default null
  ,p_files_due                      in     date     default null
  ,p_files_forwd                    in     date     default null
  ,p_agency_brief_due               in     date     default null
  ,p_agency_brief_forwd             in     date     default null
  ,p_agency_recvd_appellant_brief   in     date     default null
  ,p_decision_date                  in     date     default null
  ,p_dec_recvd_by_agency            in     date     default null
  ,p_decision                       in     varchar2 default null
  ,p_dec_forwd_to_org               in     date     default null
  ,p_agency_rfr_suspense            in     date     default null
  ,p_request_for_rfr                in     date     default null
  ,p_rfr_docket_num                 in     varchar2 default null
  ,p_rfr_requested_by               in     varchar2 default null
  ,p_agency_rfr_due                 in     date     default null
  ,p_rfr_forwd_to_org               in     date     default null
  ,p_org_forwd_rfr_to_agency        in     date     default null
  ,p_agency_forwd_rfr_ofo           in     date     default null
  ,p_rfr_decision_date              in     date     default null
  ,p_agency_recvd_rfr_dec           in     date     default null
  ,p_rfr_decision_forwd_to_org      in     date     default null
  ,p_rfr_decision                   in     varchar2 default null
  ,p_compl_agency_appeal_id            out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end ghr_caa_ins;

 

/
