--------------------------------------------------------
--  DDL for Package BEN_BMN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BMN_INS" AUTHID CURRENT_USER as
/* $Header: bebmnrhi.pkh 115.7 2002/12/11 10:27:43 lakrish ship $ */

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
  p_rec        in out nocopy ben_bmn_shd.g_rec_type
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
  p_reporting_id                 out nocopy number,
  p_benefit_action_id            in number,
  p_thread_id                    in number,
  p_sequence                     in number,
  p_text                         in varchar2       default null,
  p_rep_typ_cd                   in varchar2       default null,
  p_error_message_code           in varchar2       default null,
  p_national_identifier          in varchar2       default null,
  p_related_person_ler_id        in number         default null,
  p_temporal_ler_id              in number         default null,
  p_ler_id                       in number         default null,
  p_person_id                    in number         default null,
  p_pgm_id                       in number         default null,
  p_pl_id                        in number         default null,
  p_related_person_id            in number         default null,
  p_oipl_id                      in number         default null,
  p_pl_typ_id                    in number         default null,
  p_actl_prem_id                 in number         default null,
  p_val                          in number         default null,
  p_mo_num                       in number         default null,
  p_yr_num                       in number         default null,
  p_object_version_number        out nocopy number
  );
--
end ben_bmn_ins;

 

/
