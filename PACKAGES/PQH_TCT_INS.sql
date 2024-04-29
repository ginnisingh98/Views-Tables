--------------------------------------------------------
--  DDL for Package PQH_TCT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCT_INS" AUTHID CURRENT_USER as
/* $Header: pqtctrhi.pkh 120.2.12000000.2 2007/04/19 12:48:28 brsinha noship $ */

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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  p_effective_date               in date,
  p_rec        in out nocopy pqh_tct_shd.g_rec_type
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  p_effective_date               in date,
  p_transaction_category_id      out nocopy number,
  p_custom_wf_process_name       in varchar2         default null,
  p_custom_workflow_name         in varchar2         default null,
  p_form_name                    in varchar2,
  p_freeze_status_cd             in varchar2         default null,
  p_future_action_cd             in varchar2,
  p_member_cd                    in varchar2,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_post_style_cd                in varchar2,
  p_post_txn_function            in varchar2,
  p_route_validated_txn_flag     in varchar2,
  p_prevent_approver_skip        in varchar2         default null,
  p_workflow_enable_flag     in varchar2,
  p_enable_flag     in varchar2,
  p_timeout_days                 in number           default null,
  p_object_version_number        out nocopy number,
  p_consolidated_table_route_id  in number,
  p_business_group_id             in   number,
  p_setup_type_cd                 in   varchar2,
  p_master_table_route_id  in number
  );
--
end pqh_tct_ins;

 

/
