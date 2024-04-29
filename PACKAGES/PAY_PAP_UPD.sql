--------------------------------------------------------
--  DDL for Package PAY_PAP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAP_UPD" AUTHID CURRENT_USER as
/* $Header: pypaprhi.pkh 120.0 2005/05/29 07:14:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--   A record structure
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
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
PROCEDURE upd
  (p_effective_date   IN     DATE
  ,p_rec              IN OUT NOCOPY pay_pap_shd.g_rec_type
  ,p_check_accrual_ff    OUT NOCOPY BOOLEAN);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--   p_effective_date
--   p_pto_input_value_id
--   p_accrual_category
--   p_accrual_units_of_measure
--   p_accrual_start
--   p_ineligible_period_length
--   p_ineligible_period_type
--   p_accrual_formula_id
--   p_co_formula_id
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
--   A fully validated row will be updated for the specified entity
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
Procedure upd
  (p_effective_date               IN     DATE
  ,p_accrual_plan_id              IN     NUMBER
  ,p_pto_input_value_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_accrual_category             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_accrual_start                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ineligible_period_length     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_ineligible_period_type       IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_accrual_formula_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_co_formula_id                IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_description                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ineligibility_formula_id     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_payroll_formula_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_defined_balance_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_tagging_element_type_id      IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_balance_element_type_id      IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_information_category         IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information1                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information2                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information3                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information4                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information5                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information6                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information7                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information8                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information9                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information10                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information11                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information12                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information13                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information14                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information15                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information16                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information17                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information18                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information19                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information20                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information21                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information22                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information23                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information24                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information25                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information26                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information27                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information28                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information29                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information30                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_check_accrual_ff                OUT NOCOPY BOOLEAN);
--
end pay_pap_upd;

 

/
