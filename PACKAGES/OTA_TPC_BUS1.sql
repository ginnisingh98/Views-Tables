--------------------------------------------------------
--  DDL for Package OTA_TPC_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPC_BUS1" AUTHID CURRENT_USER as
/* $Header: ottpcrhi.pkh 120.0 2005/05/29 07:47:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_tp_measurement_type_id>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the tp_measurement_type_id exists in ota_tp_measurement_types
--   and with the business_group_id, and the measure cost_level is not 'NONE'.
--
-- Prerequisites:
--   Both this parameter and the business_group_id are present.
--
-- In Parameters:
--   p_tp_measurement_type_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_tp_measurement_type_id
  (p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_training_plan_id>------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the training_plan_id exists in ota_training_plans
--   and with the business_group_id.
--
-- Prerequisites:
--   Both this parameter and the business_group_id are present.
--
-- In Parameters:
--   p_training_plan_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_training_plan_id
  (p_training_plan_id          in     ota_training_plan_costs.training_plan_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_booking_id>------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the booking_id exists in ota_delegate_bookings
--   and with the business_group_id.
--
-- Prerequisites:
--   Both this parameter and the business_group_id are present.
--
-- In Parameters:
--   p_booking_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_booking_id
  (p_booking_id                in     ota_training_plan_costs.booking_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_booking_event>----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A shared function to perform the common functions of chk_booking_id
--   and chk_event_id.
--   The values will first be checked by their respective chk_procedures.
--   Validates that the booking_id and event_id are valid for the given
--   cost_level of the measurement type.
--
-- Prerequisites:
--   Booking_id, event_id are present
--   chk_booking_id and chk_event id have been called before calling this
--
-- In Parameters:
--   p_booking_id
--   p_event_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_booking_event
  (p_booking_id                in     ota_training_plan_costs.booking_id%TYPE
  ,p_event_id                  in     ota_training_plan_costs.event_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  ,p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_event_id>--------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the event_id exists in ota_events
--   and with the business_group_id, and that the events start_date is
--   is before the training plans start date.
--
-- Prerequisites:
--   Both this parameter and the business_group_id are present.
--
-- In Parameters:
--   p_event_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_event_id
  (p_event_id                  in     ota_training_plan_costs.event_id%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  ,p_training_plan_id          in     ota_training_plans.training_plan_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_currency_value>---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the currency_code exists in fnd_currencies, if present
--   and that it is present if the measure type is of type 'MONEY'. It also
--   shares the value field validation, as this also depends on the measure
--   UNIT setting, and may therefore need to be validated withe courency_code
--   if the measurement type is 'MONEY'
--
-- Prerequisites:
--   Parameter is present.
--   chk_tp_measurement_type_id has been called first.
--
-- In Parameters:
--   p_currency_code
--   p_object_version_number
--   p_training_plan_cost_id
--   p_object_version_number
--   p_value
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_currency_value
  (p_currency_code             in     ota_training_plan_costs.currency_code%TYPE
  ,p_training_plan_cost_id     in     ota_training_plan_costs.training_plan_cost_id%TYPE
  ,p_object_version_number     in     ota_training_plan_costs.object_version_number%TYPE
  ,p_business_group_id         in     ota_training_plan_costs.business_group_id%TYPE
  ,p_amount                    in     ota_training_plan_costs.amount%TYPE
  ,p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique>----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A shared function to perform the common functions of
--   chk_tp_measurement_type_id
--   chk_booking_id
--   chk_event_id
--   chk_training_plan_id.
--   The values will first be checked by their respective chk_procedures.
--   Validates that the column combination is unique
--
-- Prerequisites:
--   chk_ procedures listed above have already been called
--
-- In Parameters:
--   p_tp_measurement_type_id
--   p_booking_id
--   p_event_id
--   p_training_plan_id
--
-- Post Success:
--   Processing continues if the values are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   This may be called from a form to validate that the combination is unique.
--   Call only on insert, as all columns are non-updateable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique
  (p_tp_measurement_type_id    in     ota_training_plan_costs.tp_measurement_type_id%TYPE
  ,p_event_id                  in     ota_training_plan_costs.event_id%TYPE
  ,p_booking_id                in     ota_training_plan_costs.booking_id%TYPE
  ,p_training_plan_id          in     ota_training_plan_costs.training_plan_id%TYPE
  );
end ota_tpc_bus1;

 

/
