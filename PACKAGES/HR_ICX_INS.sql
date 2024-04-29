--------------------------------------------------------
--  DDL for Package HR_ICX_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ICX_INS" AUTHID CURRENT_USER as
/* $Header: hricxrhi.pkh 120.0 2005/05/31 00:51:03 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
procedure ins_or_sel
         (p_segment1               in  varchar2 default null,
          p_segment2               in  varchar2 default null,
          p_segment3               in  varchar2 default null,
          p_segment4               in  varchar2 default null,
          p_segment5               in  varchar2 default null,
          p_segment6               in  varchar2 default null,
          p_segment7               in  varchar2 default null,
          p_segment8               in  varchar2 default null,
          p_segment9               in  varchar2 default null,
          p_segment10              in  varchar2 default null,
          p_segment11              in  varchar2 default null,
          p_segment12              in  varchar2 default null,
          p_segment13              in  varchar2 default null,
          p_segment14              in  varchar2 default null,
          p_segment15              in  varchar2 default null,
          p_segment16              in  varchar2 default null,
          p_segment17              in  varchar2 default null,
          p_segment18              in  varchar2 default null,
          p_segment19              in  varchar2 default null,
          p_segment20              in  varchar2 default null,
          p_segment21              in  varchar2 default null,
          p_segment22              in  varchar2 default null,
          p_segment23              in  varchar2 default null,
          p_segment24              in  varchar2 default null,
          p_segment25              in  varchar2 default null,
          p_segment26              in  varchar2 default null,
          p_segment27              in  varchar2 default null,
          p_segment28              in  varchar2 default null,
          p_segment29              in  varchar2 default null,
          p_segment30              in  varchar2 default null,
          p_context_type           in  varchar2 default null,
          p_item_context_id        out nocopy number,
          p_concatenated_segments  out nocopy varchar2
          );
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
  ,p_rec                          in out nocopy hr_icx_shd.g_rec_type
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
  ,p_id_flex_num                    in     number
  ,p_summary_flag                   in     varchar2
  ,p_enabled_flag                   in     varchar2
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_segment1                       in     varchar2 default null
  ,p_segment2                       in     varchar2 default null
  ,p_segment3                       in     varchar2 default null
  ,p_segment4                       in     varchar2 default null
  ,p_segment5                       in     varchar2 default null
  ,p_segment6                       in     varchar2 default null
  ,p_segment7                       in     varchar2 default null
  ,p_segment8                       in     varchar2 default null
  ,p_segment9                       in     varchar2 default null
  ,p_segment10                      in     varchar2 default null
  ,p_segment11                      in     varchar2 default null
  ,p_segment12                      in     varchar2 default null
  ,p_segment13                      in     varchar2 default null
  ,p_segment14                      in     varchar2 default null
  ,p_segment15                      in     varchar2 default null
  ,p_segment16                      in     varchar2 default null
  ,p_segment17                      in     varchar2 default null
  ,p_segment18                      in     varchar2 default null
  ,p_segment19                      in     varchar2 default null
  ,p_segment20                      in     varchar2 default null
  ,p_segment21                      in     varchar2 default null
  ,p_segment22                      in     varchar2 default null
  ,p_segment23                      in     varchar2 default null
  ,p_segment24                      in     varchar2 default null
  ,p_segment25                      in     varchar2 default null
  ,p_segment26                      in     varchar2 default null
  ,p_segment27                      in     varchar2 default null
  ,p_segment28                      in     varchar2 default null
  ,p_segment29                      in     varchar2 default null
  ,p_segment30                      in     varchar2 default null
  ,p_item_context_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_icx_ins;

 

/
