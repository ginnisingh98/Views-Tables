--------------------------------------------------------
--  DDL for Package HR_CTX_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CTX_INS" AUTHID CURRENT_USER as
/* $Header: hrctxrhi.pkh 120.0 2005/05/30 23:30 appldev noship $ */
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
  (p_context_id  in  number);
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
  (p_rec                      in out nocopy hr_ctx_shd.g_rec_type
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
  (p_view_name                      in     varchar2
  ,p_param_1                        in     varchar2 default null
  ,p_param_2                        in     varchar2 default null
  ,p_param_3                        in     varchar2 default null
  ,p_param_4                        in     varchar2 default null
  ,p_param_5                        in     varchar2 default null
  ,p_param_6                        in     varchar2 default null
  ,p_param_7                        in     varchar2 default null
  ,p_param_8                        in     varchar2 default null
  ,p_param_9                        in     varchar2 default null
  ,p_param_10                       in     varchar2 default null
  ,p_param_11                       in     varchar2 default null
  ,p_param_12                       in     varchar2 default null
  ,p_param_13                       in     varchar2 default null
  ,p_param_14                       in     varchar2 default null
  ,p_param_15                       in     varchar2 default null
  ,p_param_16                       in     varchar2 default null
  ,p_param_17                       in     varchar2 default null
  ,p_param_18                       in     varchar2 default null
  ,p_param_19                       in     varchar2 default null
  ,p_param_20                       in     varchar2 default null
  ,p_param_21                       in     varchar2 default null
  ,p_param_22                       in     varchar2 default null
  ,p_param_23                       in     varchar2 default null
  ,p_param_24                       in     varchar2 default null
  ,p_param_25                       in     varchar2 default null
  ,p_param_26                       in     varchar2 default null
  ,p_param_27                       in     varchar2 default null
  ,p_param_28                       in     varchar2 default null
  ,p_param_29                       in     varchar2 default null
  ,p_param_30                       in     varchar2 default null
  ,p_context_id                        out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_ctx_ins;

 

/
