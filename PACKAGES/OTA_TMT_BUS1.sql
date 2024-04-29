--------------------------------------------------------
--  DDL for Package OTA_TMT_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TMT_BUS1" AUTHID CURRENT_USER as
/* $Header: ottmtrhi.pkh 120.0 2005/05/29 07:45:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_tp_measurement_code>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the tp_measurement_code exists in hr_lookups and
--   that the combination with business_group_id is unique.
--
-- Prerequisites:
--   Both this parameter and the business_group_id are present.
--
-- In Parameters:
--   p_effective_date
--   p_tp_measurement_code
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   This can be called for the form to validate if the business_group_id and
--   tp_measurement_code combination are valid. This should only be called
--   for an insert operation.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_tp_measurement_code
  (p_effective_date            in     date
  ,p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_tp_measurement_code>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the tp_measurement_code can be deleted from OTA_TP_MEASUREMENT_CODE
--   by checking that it does not exist in per_budgets.
--
-- Prerequisites:
--   Both this parameter and the business_group_id are present.
--
-- In Parameters:
--   p_tp_measurement_code
--   p_tp_measurement_Type_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the row can be deleted.
--
-- Post Failure:
--   If the row cannot be deleted, an error is raised.
--
-- Developer Implementation Notes:
--   This can be called for the form to validate if the measure type
--   can be deleted.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_del_tp_measurement_code
  (p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |--------------------------------<chk_unit>--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the unit is valid for both insert and update.
--
-- Prerequisites:
--   All parameters are persent.
--
-- In Parameters:
--   p_unit
--   p_business_group_id
--   p_effective_date
--   p_object_version_number
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised and processing stops.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unit
  (p_effective_date            in     date
  ,p_unit                      in     ota_tp_measurement_types.unit%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |--------------------------------<chk_budget_level>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the budget level is valid.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--  p_effective_date
--  p_business_group_id
--  p_budget_level
--  p_tp_measurement_code
--  p_object_version_number
--  p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised and processing stops.
--
-- Developer Implementation Notes:
--   The budget-cost combination check has been passed out to a separate chk
--   procedure, as it is shared with the chk_cost procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_budget_level
  (p_effective_date            in     date
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_budget_level              in     ota_tp_measurement_types.budget_level%TYPE
  ,p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |--------------------------------<chk_budget_cost_combination>-------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the budget level and cost level combination is valid.
--
-- Prerequisites:
--   All parameters are present.
--
-- In Parameters:
--   p_budget_level
--   p_cost_level
--   p_object_version_number
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised and processing stops.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_budget_cost_combination
  (p_budget_level              in     ota_tp_measurement_types.budget_level%TYPE
  ,p_cost_level                in     ota_tp_measurement_types.cost_level%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |--------------------------------<chk_cost_level>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the cost level is valid.
--
-- Prerequisites:
--   All parameters are present.
--
-- In Parameters:
--   p_effective_date
--   p_business_group_id
--   p_cost_level
--   p_object_version_number
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised and processing stops.
--
-- Developer Implementation Notes:
--   The budget-cost combination check has been passed out to a separate chk
--   procedure, as it is shared with the chk_budget procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_cost_level
  (p_effective_date            in     date
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_cost_level                in     ota_tp_measurement_types.cost_level%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |-----------------------<chk_many_budget_values_flag>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the budget values flag is legal.
--
-- Prerequisites:
--   All parameters are present.
--
-- Parameters
--   p_effective_date
--   p_business_group_id
--   p_many_budget_values_flag
--   p_tp_measurement_code
--   p_object_version_number
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised and processing stops.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_many_budget_values_flag
  (p_effective_date            in     date
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_many_budget_values_flag   in     ota_tp_measurement_types.many_budget_values_flag%TYPE
  ,p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |-----------------------<chk_item_type_usage_id>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the item type usage id is legal.
--
-- Prerequisites:
--   All parameters are present.
--
-- Parameters
--   p_item_type_usage_id
--   p_business_group_id
--   p_object_version_number
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised and processing stops.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_item_type_usage_id
  (p_item_type_usage_id        in     ota_tp_measurement_types.item_type_usage_id%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_tp_measurement_type>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the tp_measurement_type_id can be deleted from OTA_TP_MEASUREMENT_CODE
--   by checking that no foreign key references exist.
--
-- Prerequisites:
--   tp_measurement_type_id is valid.
--
-- In Parameters:
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues if the row can be deleted.
--
-- Post Failure:
--   If the row cannot be deleted, an error is raised.
--
-- Developer Implementation Notes:
--   This can be called for the form to validate if the measure type
--   can be deleted.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_del_tp_measurement_type_id
  (p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_legislative_setup>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the tp_measurement_codes are valid for a given legislation.
--   This ensures that measurement types specifically required for a
--   legislation are correctly specified
--
-- Prerequisites:
--   All other chk_ procedures have been called
--
-- In Parameters:
--   p_tp_measurement_type_id
--
-- Post Success:
--   Processing continues if the row can be deleted.
--
-- Post Failure:
--   If the row cannot be deleted, an error is raised.
--
-- Developer Implementation Notes:
--   This can be called for the form to validate if the measure type
--   is correct for the legislation
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_legislative_setup(
  p_legislation_code        in per_business_groups.legislation_code%TYPE
 ,p_tp_measurement_code     in ota_tp_measurement_types.tp_measurement_code%TYPE
 ,p_unit                    in ota_tp_measurement_types.unit%TYPE
 ,p_budget_level            in ota_tp_measurement_types.budget_level%TYPE
 ,p_cost_level              in ota_tp_measurement_types.cost_level%TYPE
 ,p_many_budget_values_flag in ota_tp_measurement_types.many_budget_values_flag%TYPE
 ,p_object_version_number   in ota_tp_measurement_types.object_version_number%TYPE
 ,p_tp_measurement_type_id  in ota_tp_measurement_types.tp_measurement_type_id%TYPE
);
end ota_tmt_bus1;

 

/
