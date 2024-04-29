--------------------------------------------------------
--  DDL for Package PER_RES_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RES_INS" AUTHID CURRENT_USER as
/* $Header: peresrhi.pkh 115.2 2003/04/02 13:37:20 eumenyio noship $ */
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
  ,p_rec                          in out nocopy per_res_shd.g_rec_type
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
  ,p_start_date                     in     date
  ,p_collective_agreement_id        in     number
  ,p_cagr_entitlement_item_id       in     number
  ,p_category_name                  in     varchar2
  ,p_cagr_entitlement_id            in     number
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number
  ,p_assignment_id                  in     number   default null
  ,p_end_date                       in     date     default null
  ,p_element_type_id                in     number   default null
  ,p_input_value_id                 in     number   default null
  ,p_cagr_api_id                    in     number   default null
  ,p_cagr_api_param_id              in     number   default null
  ,p_cagr_entitlement_line_id       in     number   default null
  ,p_value                          in     varchar2 default null
  ,p_units_of_measure               in     varchar2 default null
  ,p_range_from                     in     varchar2 default null
  ,p_range_to                       in     varchar2 default null
  ,p_grade_spine_id                 in     number   default null
  ,p_parent_spine_id                in     number   default null
  ,p_step_id                        in     number   default null
  ,p_from_step_id                   in     number   default null
  ,p_to_step_id                     in     number   default null
  ,p_beneficial_flag                in     varchar2 default null
  ,p_oipl_id                        in     number   default null
  ,p_chosen_flag                    in     varchar2 default null
  ,p_cagr_request_id                in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_eligy_prfl_id                  in     number   default null
  ,p_formula_id                     in     number   default null
  ,p_cagr_entitlement_result_id        out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end per_res_ins;

 

/
