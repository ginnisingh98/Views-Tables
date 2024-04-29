--------------------------------------------------------
--  DDL for Package PER_CEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEI_INS" AUTHID CURRENT_USER as
/* $Header: peceirhi.pkh 120.1 2006/10/18 09:02:59 grreddy noship $ */
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
  ,p_rec                          in out nocopy per_cei_shd.g_rec_type
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
  (p_effective_date                 in     date
  ,p_item_name                      in     varchar2
  ,p_legislation_code                    in     varchar2
  ,p_business_group_id              in     number
  ,p_category_name                  in     varchar2
  ,p_uom                            in     varchar2
  ,p_flex_value_set_id              in     number
  ,p_element_type_id                in     number   default null
  ,p_input_value_id                 in     varchar2 default null
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number
  ,p_cagr_api_id                    in     number   default null
  ,p_cagr_api_param_id              in     number   default null
  ,p_beneficial_formula_id          in     number   default null
  ,p_beneficial_rule                in     varchar2 default null
  ,p_ben_rule_value_set_id          in     number   default null
  ,p_mult_entries_allowed_flag      in     varchar2  default null
  ,p_auto_create_entries_flag       in     varchar2  default null -- Added for CEI enhancement
  ,p_opt_id                         in     number
  ,p_cagr_entitlement_item_id          out nocopy number
  ,p_object_version_number             out nocopy number

  );
--
end per_cei_ins;

/
