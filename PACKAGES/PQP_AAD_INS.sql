--------------------------------------------------------
--  DDL for Package PQP_AAD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAD_INS" AUTHID CURRENT_USER as
/* $Header: pqaadrhi.pkh 120.0 2005/05/29 01:39:54 appldev noship $ */

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
  p_rec        in out nocopy pqp_aad_shd.g_rec_type
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
  p_analyzed_data_id             out nocopy number,
  p_assignment_id                in number,
  p_data_source                  in varchar2,
  p_tax_year                     in number,
  p_current_residency_status     in varchar2         default null,
  p_nra_to_ra_date               in date             default null,
  p_target_departure_date        in date             default null,
  p_tax_residence_country_code   in varchar2         default null,
  p_treaty_info_update_date      in date             default null,
  p_number_of_days_in_usa        in number           default null,
  p_withldg_allow_eligible_flag  in varchar2         default null,
  p_ra_effective_date            in date             default null,
  p_record_source                in varchar2         default null,
  p_visa_type                    in varchar2         default null,
  p_j_sub_type                   in varchar2         default null,
  p_primary_activity             in varchar2         default null,
  p_non_us_country_code          in varchar2         default null,
  p_citizenship_country_code     in varchar2         default null,
  p_object_version_number        out nocopy number
  ,p_date_8233_signed            in date             default null
  ,p_date_w4_signed              in date             default null
  );
--
end pqp_aad_ins;

 

/
