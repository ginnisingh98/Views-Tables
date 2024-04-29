--------------------------------------------------------
--  DDL for Package BEN_CPG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPG_INS" AUTHID CURRENT_USER as
/* $Header: becpgrhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
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
  (p_group_per_in_ler_id  in  number
  ,p_group_pl_id  in  number
  ,p_group_oipl_id  in  number);
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
  (p_rec                      in out nocopy ben_cpg_shd.g_rec_type
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
  (p_group_per_in_ler_id            in     number
  ,p_group_pl_id                    in     number
  ,p_group_oipl_id                  in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_bdgt_pop_cd                    in     varchar2 default null
  ,p_due_dt                         in     date     default null
  ,p_access_cd                      in     varchar2 default null
  ,p_approval_cd                    in     varchar2 default null
  ,p_approval_date                  in     date     default null
  ,p_approval_comments              in     varchar2 default null
  ,p_submit_cd                      in     varchar2 default null
  ,p_submit_date                    in     date     default null
  ,p_submit_comments                in     varchar2 default null
  ,p_dist_bdgt_val                  in     number   default null
  ,p_ws_bdgt_val                    in     number   default null
  ,p_rsrv_val                       in     number   default null
  ,p_dist_bdgt_mn_val               in     number   default null
  ,p_dist_bdgt_mx_val               in     number   default null
  ,p_dist_bdgt_incr_val             in     number   default null
  ,p_ws_bdgt_mn_val                 in     number   default null
  ,p_ws_bdgt_mx_val                 in     number   default null
  ,p_ws_bdgt_incr_val               in     number   default null
  ,p_rsrv_mn_val                    in     number   default null
  ,p_rsrv_mx_val                    in     number   default null
  ,p_rsrv_incr_val                  in     number   default null
  ,p_dist_bdgt_iss_val              in     number   default null
  ,p_ws_bdgt_iss_val                in     number   default null
  ,p_dist_bdgt_iss_date             in     date     default null
  ,p_ws_bdgt_iss_date               in     date     default null
  ,p_ws_bdgt_val_last_upd_date      in     date     default null
  ,p_dist_bdgt_val_last_upd_date    in     date     default null
  ,p_rsrv_val_last_upd_date         in     date     default null
  ,p_ws_bdgt_val_last_upd_by        in     number   default null
  ,p_dist_bdgt_val_last_upd_by      in     number   default null
  ,p_rsrv_val_last_upd_by           in     number   default null
  ,p_object_version_number             out nocopy number
  );
--
end ben_cpg_ins;

 

/
