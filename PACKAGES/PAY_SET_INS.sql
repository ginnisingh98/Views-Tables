--------------------------------------------------------
--  DDL for Package PAY_SET_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SET_INS" AUTHID CURRENT_USER as
/* $Header: pysetrhi.pkh 120.0 2005/05/29 08:39:36 appldev noship $ */

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
  (p_effective_date in            date
  ,p_rec            in out nocopy pay_set_shd.g_rec_type
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
  p_element_type_id              out nocopy number,
  p_effective_date               in date,
  p_template_id                  in number,
  p_classification_name          in varchar2,
  p_additional_entry_allowed_fla in varchar2,
  p_adjustment_only_flag         in varchar2,
  p_closed_for_entry_flag        in varchar2,
  p_element_name                 in varchar2,
  p_indirect_only_flag           in varchar2,
  p_multiple_entries_allowed_fla in varchar2,
  p_multiply_value_flag          in varchar2,
  p_post_termination_rule        in varchar2,
  p_process_in_run_flag          in varchar2,
  p_relative_processing_priority in number,
  p_processing_type              in varchar2         default null,
  p_standard_link_flag           in varchar2,
  p_input_currency_code          in varchar2         default null,
  p_output_currency_code         in varchar2         default null,
  p_benefit_classification_name  in varchar2         default null,
  p_description                  in varchar2         default null,
  p_qualifying_age               in number           default null,
  p_qualifying_length_of_service in number           default null,
  p_qualifying_units             in varchar2         default null,
  p_reporting_name               in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_element_information_category in varchar2         default null,
  p_element_information1         in varchar2         default null,
  p_element_information2         in varchar2         default null,
  p_element_information3         in varchar2         default null,
  p_element_information4         in varchar2         default null,
  p_element_information5         in varchar2         default null,
  p_element_information6         in varchar2         default null,
  p_element_information7         in varchar2         default null,
  p_element_information8         in varchar2         default null,
  p_element_information9         in varchar2         default null,
  p_element_information10        in varchar2         default null,
  p_element_information11        in varchar2         default null,
  p_element_information12        in varchar2         default null,
  p_element_information13        in varchar2         default null,
  p_element_information14        in varchar2         default null,
  p_element_information15        in varchar2         default null,
  p_element_information16        in varchar2         default null,
  p_element_information17        in varchar2         default null,
  p_element_information18        in varchar2         default null,
  p_element_information19        in varchar2         default null,
  p_element_information20        in varchar2         default null,
  p_third_party_pay_only_flag    in varchar2         default null,
  p_skip_formula                 in varchar2         default null,
  p_payroll_formula_id           in number           default null,
  p_exclusion_rule_id            in number           default null,
  p_iterative_flag               in varchar2         default null,
  p_iterative_priority           in number           default null,
  p_iterative_formula_name       in varchar2         default null,
  p_process_mode                 in varchar2         default null,
  p_grossup_flag                 in varchar2         default null,
  p_advance_indicator            in varchar2         default null,
  p_advance_payable              in varchar2         default null,
  p_advance_deduction            in varchar2         default null,
  p_process_advance_entry        in varchar2         default null,
  p_proration_group              in varchar2         default null,
  p_proration_formula            in varchar2         default null,
  p_recalc_event_group           in varchar2         default null,
  p_once_each_period_flag        in varchar2         default null,
  p_object_version_number        out nocopy number
  );
--
end pay_set_ins;

 

/
