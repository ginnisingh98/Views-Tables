--------------------------------------------------------
--  DDL for Package PAY_PAP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAP_INS" AUTHID CURRENT_USER as
/* $Header: pypaprhi.pkh 120.0 2005/05/29 07:14:36 appldev noship $ */

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
--   p_effective_date
--   a record structure
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
PROCEDURE ins
  (p_effective_date   IN     DATE
  ,p_rec              IN OUT NOCOPY pay_pap_shd.g_rec_type
  ,p_check_accrual_ff    OUT NOCOPY BOOLEAN);
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
--   p_effective_date
--   p_business_group_id
--   p_accrual_plan_element_type_id
--   p_pto_input_value_id
--   p_co_input_value_id
--   p_residual_input_value_id
--   p_accrual_category
--   p_accrual_plan_name
--   p_accrual_units_of_measure
--   p_accrual_start
--   p_ineligible_period_length
--   p_ineligible_period_type
--   p_accrual_formula_id
--   p_co_formula_id
--   p_co_date_input_value_id
--   p_co_exp_date_input_value_id
--   p_residual_date_input_value_id
--   p_description
--   p_ineligibility_formula_id
--   p_payroll_formula_id
--   p_defined_balance_id
--   p_tagging_element_type_id
--   p_balance_element_type_id
--   p_information_category
--   p_information1..30
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
PROCEDURE ins
  (p_effective_date               IN  DATE
  ,p_business_group_id            IN  NUMBER
  ,p_accrual_plan_element_type_id IN  NUMBER
  ,p_pto_input_value_id           IN  NUMBER
  ,p_co_input_value_id            IN  NUMBER
  ,p_residual_input_value_id      IN  NUMBER
  ,p_accrual_category             IN  VARCHAR2
  ,p_accrual_plan_name            IN  VARCHAR2
  ,p_accrual_units_of_measure     IN  VARCHAR2
  ,p_accrual_start                IN  VARCHAR2 DEFAULT NULL
  ,p_ineligible_period_length     IN  NUMBER   DEFAULT NULL
  ,p_ineligible_period_type       IN  VARCHAR2 DEFAULT NULL
  ,p_accrual_formula_id           IN  NUMBER   DEFAULT NULL
  ,p_co_formula_id                IN  NUMBER   DEFAULT NULL
  ,p_co_date_input_value_id       IN  NUMBER   DEFAULT NULL
  ,p_co_exp_date_input_value_id   IN  NUMBER   DEFAULT NULL
  ,p_residual_date_input_value_id IN  NUMBER   DEFAULT NULL
  ,p_description                  IN  VARCHAR2 DEFAULT NULL
  ,p_ineligibility_formula_id     IN  NUMBER   DEFAULT NULL
  ,p_payroll_formula_id           IN  NUMBER   DEFAULT NULL
  ,p_defined_balance_id           IN  NUMBER   DEFAULT NULL
  ,p_tagging_element_type_id      IN  NUMBER   DEFAULT NULL
  ,p_balance_element_type_id      IN  NUMBER   DEFAULT NULL
  ,p_information_category         IN  VARCHAR2 DEFAULT NULL
  ,p_information1                 IN  VARCHAR2 DEFAULT NULL
  ,p_information2                 IN  VARCHAR2 DEFAULT NULL
  ,p_information3                 IN  VARCHAR2 DEFAULT NULL
  ,p_information4                 IN  VARCHAR2 DEFAULT NULL
  ,p_information5                 IN  VARCHAR2 DEFAULT NULL
  ,p_information6                 IN  VARCHAR2 DEFAULT NULL
  ,p_information7                 IN  VARCHAR2 DEFAULT NULL
  ,p_information8                 IN  VARCHAR2 DEFAULT NULL
  ,p_information9                 IN  VARCHAR2 DEFAULT NULL
  ,p_information10                IN  VARCHAR2 DEFAULT NULL
  ,p_information11                IN  VARCHAR2 DEFAULT NULL
  ,p_information12                IN  VARCHAR2 DEFAULT NULL
  ,p_information13                IN  VARCHAR2 DEFAULT NULL
  ,p_information14                IN  VARCHAR2 DEFAULT NULL
  ,p_information15                IN  VARCHAR2 DEFAULT NULL
  ,p_information16                IN  VARCHAR2 DEFAULT NULL
  ,p_information17                IN  VARCHAR2 DEFAULT NULL
  ,p_information18                IN  VARCHAR2 DEFAULT NULL
  ,p_information19                IN  VARCHAR2 DEFAULT NULL
  ,p_information20                IN  VARCHAR2 DEFAULT NULL
  ,p_information21                IN  VARCHAR2 DEFAULT NULL
  ,p_information22                IN  VARCHAR2 DEFAULT NULL
  ,p_information23                IN  VARCHAR2 DEFAULT NULL
  ,p_information24                IN  VARCHAR2 DEFAULT NULL
  ,p_information25                IN  VARCHAR2 DEFAULT NULL
  ,p_information26                IN  VARCHAR2 DEFAULT NULL
  ,p_information27                IN  VARCHAR2 DEFAULT NULL
  ,p_information28                IN  VARCHAR2 DEFAULT NULL
  ,p_information29                IN  VARCHAR2 DEFAULT NULL
  ,p_information30                IN  VARCHAR2 DEFAULT NULL
  ,p_accrual_plan_id              OUT NOCOPY NUMBER
  ,p_object_version_number        OUT NOCOPY NUMBER
  ,p_check_accrual_ff             OUT NOCOPY BOOLEAN);

end pay_pap_ins;

 

/
