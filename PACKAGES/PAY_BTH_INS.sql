--------------------------------------------------------
--  DDL for Package PAY_BTH_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTH_INS" AUTHID CURRENT_USER as
/* $Header: pybthrhi.pkh 120.0 2005/05/29 03:23:29 appldev noship $ */
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
  (p_session_date                 in     date,
   p_rec                          in out nocopy pay_bth_shd.g_rec_type
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
  (p_session_date                   in     date
  ,p_business_group_id              in     number
  ,p_batch_name                     in     varchar2
  ,p_batch_status                   in     varchar2
  ,p_action_if_exists               in     varchar2 default null
  ,p_batch_reference                in     varchar2 default null
  ,p_batch_source                   in     varchar2 default null
  ,p_batch_type                     in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_date_effective_changes         in     varchar2 default null
  ,p_purge_after_transfer           in     varchar2 default null
  ,p_reject_if_future_changes       in     varchar2 default null
  ,p_batch_id                          out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_reject_if_results_exists       in     varchar2 default null
  ,p_purge_after_rollback           in     varchar2 default null
  ,p_REJECT_ENTRY_NOT_REMOVED       in     varchar2 default null
  ,p_ROLLBACK_ENTRY_UPDATES         in     varchar2 default null
  );
--
end pay_bth_ins;

 

/
