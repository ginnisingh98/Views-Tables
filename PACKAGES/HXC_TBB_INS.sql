--------------------------------------------------------
--  DDL for Package HXC_TBB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TBB_INS" AUTHID CURRENT_USER as
/* $Header: hxctbbrhi.pkh 120.1 2005/07/14 17:23:33 arundell noship $ */

-- --------------------------------------------------------------------------
-- |---------------------------------< ins >--------------------------------|
-- --------------------------------------------------------------------------
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
-- --------------------------------------------------------------------------
procedure ins
  (p_effective_date in date
  ,p_rec            in out nocopy hxc_tbb_shd.g_rec_type
  );

-- --------------------------------------------------------------------------
-- |---------------------------------< ins >--------------------------------|
-- --------------------------------------------------------------------------
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
-- --------------------------------------------------------------------------
procedure ins
  (p_effective_date            in     date
  ,p_type                      in     varchar2
  ,p_scope                     in     varchar2
  ,p_approval_status           in     varchar2
  ,p_measure                   in     number   default null
  ,p_unit_of_measure           in     varchar2 default null
  ,p_start_time                in     date     default null
  ,p_stop_time                 in     date     default null
  ,p_parent_building_block_id  in     number   default null
  ,p_parent_building_block_ovn in     number   default null
  ,p_resource_id               in     number   default null
  ,p_resource_type             in     varchar2 default null
  ,p_approval_style_id         in     number   default null
  ,p_date_from                 in     date     default null
  ,p_date_to                   in     date     default null
  ,p_comment_text              in     varchar2 default null
  ,p_application_set_id        in     number   default null
  ,p_data_set_id               in     number   default null
  ,p_translation_display_key   in     varchar2 default null
  ,p_time_building_block_id       out nocopy number
  ,p_object_version_number        out nocopy number
  );

end hxc_tbb_ins;

 

/
