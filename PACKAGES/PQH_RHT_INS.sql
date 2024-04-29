--------------------------------------------------------
--  DDL for Package PQH_RHT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RHT_INS" AUTHID CURRENT_USER as
/* $Header: pqrhtrhi.pkh 120.0 2005/05/29 02:29:21 appldev noship $ */

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
  p_rec        in out nocopy pqh_rht_shd.g_rec_type
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
  p_routing_history_id           out nocopy number,
  p_approval_cd                  in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_forwarded_by_assignment_id   in number           default null,
  p_forwarded_by_member_id       in number           default null,
  p_forwarded_by_position_id     in number           default null,
  p_forwarded_by_user_id         in number           default null,
  p_forwarded_by_role_id         in number           default null,
  p_forwarded_to_assignment_id   in number           default null,
  p_forwarded_to_member_id       in number           default null,
  p_forwarded_to_position_id     in number           default null,
  p_forwarded_to_user_id         in number           default null,
  p_forwarded_to_role_id         in number           default null,
  p_notification_date            in date,
  p_pos_structure_version_id     in number           default null,
  p_routing_category_id          in number,
  p_transaction_category_id      in number,
  p_transaction_id               in number,
  p_user_action_cd               in varchar2,
  p_from_range_name              in varchar2           default null,
  p_to_range_name                in varchar2           default null,
  p_list_range_name              in varchar2           default null,
  p_object_version_number        out nocopy number
  );
--
end pqh_rht_ins;

 

/
