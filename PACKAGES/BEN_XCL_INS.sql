--------------------------------------------------------
--  DDL for Package BEN_XCL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCL_INS" AUTHID CURRENT_USER as
/* $Header: bexclrhi.pkh 120.0 2005/05/28 12:24:24 appldev noship $ */

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
  p_rec        in out nocopy ben_xcl_shd.g_rec_type
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
  p_ext_chg_evt_log_id           out nocopy number,
  p_chg_evt_cd                   in varchar2,
  p_chg_eff_dt                   in date,
  p_chg_user_id                  in number           default null,
  p_prmtr_01                     in varchar2         default null,
  p_prmtr_02                     in varchar2         default null,
  p_prmtr_03                     in varchar2         default null,
  p_prmtr_04                     in varchar2         default null,
  p_prmtr_05                     in varchar2         default null,
  p_prmtr_06                     in varchar2         default null,
  p_prmtr_07                     in varchar2         default null,
  p_prmtr_08                     in varchar2         default null,
  p_prmtr_09                     in varchar2         default null,
  p_prmtr_10                     in varchar2         default null,
  p_person_id                    in number,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number,
  p_chg_actl_dt                  in date,
  p_new_val1                     in varchar2         default null,
  p_new_val2                     in varchar2         default null,
  p_new_val3                     in varchar2         default null,
  p_new_val4                     in varchar2         default null,
  p_new_val5                     in varchar2         default null,
  p_new_val6                     in varchar2         default null,
  p_old_val1                     in varchar2         default null,
  p_old_val2                     in varchar2         default null,
  p_old_val3                     in varchar2         default null,
  p_old_val4                     in varchar2         default null,
  p_old_val5                     in varchar2         default null,
  p_old_val6                     in varchar2         default null
  );
--
end ben_xcl_ins;

 

/
