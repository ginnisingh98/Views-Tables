--------------------------------------------------------
--  DDL for Package PQH_BGT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BGT_INS" AUTHID CURRENT_USER as
/* $Header: pqbgtrhi.pkh 120.0 2005/05/29 01:31:50 appldev noship $ */

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
  p_rec        in out nocopy pqh_bgt_shd.g_rec_type
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
  p_budget_id                    out nocopy number,
  p_business_group_id            in number           default null,
  p_start_organization_id        in number           default null,
  p_org_structure_version_id     in number           default null,
  p_budgeted_entity_cd           in varchar2         default null,
  p_budget_style_cd              in varchar2,
  p_budget_name                  in varchar2,
  p_period_set_name              in varchar2,
  p_budget_start_date            in date,
  p_budget_end_date              in date,
  p_gl_budget_name               in varchar2         default null,
  p_psb_budget_flag              in varchar2         default 'N',
  p_transfer_to_gl_flag          in varchar2         default null,
  p_transfer_to_grants_flag      in varchar2         default null,
  p_status                       in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_budget_unit1_id              in number           default null,
  p_budget_unit2_id              in number           default null,
  p_budget_unit3_id              in number           default null,
  p_gl_set_of_books_id           in number           default null,
  p_budget_unit1_aggregate       in varchar2         default null,
  p_budget_unit2_aggregate       in varchar2         default null,
  p_budget_unit3_aggregate       in varchar2         default null,
  p_position_control_flag        in varchar2         default null,
  p_valid_grade_reqd_flag        in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_dflt_budget_set_id           in number           default null
  );
--
end pqh_bgt_ins;

 

/
