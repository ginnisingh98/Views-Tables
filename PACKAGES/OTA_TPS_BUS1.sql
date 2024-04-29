--------------------------------------------------------
--  DDL for Package OTA_TPS_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_BUS1" AUTHID CURRENT_USER AS
/* $Header: ottpsrhi.pkh 120.0 2005/05/29 07:50:07 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_unique >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The combination of time_period_id, organization_id, person_id is unique
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_training_plan_id
--  p_object_version_number
--  p_organization_id
--  p_person_id
--  p_time_period_id

-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an existing combination is found, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_unique
  (p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE
  ,p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_time_period_id            IN     ota_training_plans.time_period_id%TYPE
  ) ;
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_org_person >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The person_id and Organization_id cannot both be null or both be set
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_organization_id
--  p_person_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If the parameters are set incorrectly, an error message will be raised.
--
-- Developer Implementation Notes:
--   Call for Insert checking only.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_org_person
  (p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_contact_id              IN      ota_training_plans.contact_id%TYPE
  ) ;
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_organization_id >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The organization_id must exist and be in the same business group
--    as the training plan.
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_organization_id
--  p_business_group_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   Call for insert checking only.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_organization_id
  (p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_person_id >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The person_id must exist and be in the same business group
--    as the training plan.
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_effective_date
--  p_person_id
--  p_business_group_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   Call for insert checking only.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_person_id
  (p_effective_date            IN     date
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  ) ;
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_plan_status_type_id >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The plan_status_type_id must exist in hr_lookups under the correct lookup type.
--    as the training plan.
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_effective_date
--  p_plan_status_type_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_plan_status_type_id
  (p_effective_date            IN     date
  ,p_plan_status_type_id       IN     ota_training_plans.plan_status_type_id%TYPE
  )  ;
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_time_period_id >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The time period cannot change if the plan has members.
--    The time period must exist in per_time_periods
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_training_plan_id
--  p_object_version_number
--  p_time_period_id
--  p_business_group_id
--
-- Post Success:
--   Processing continues
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
PROCEDURE chk_time_period_id
  (p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE
  ,p_time_period_id            IN     ota_training_plans.time_period_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  ) ;
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_period_overlap >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    No two training plans for the same organization or person can exist
--    if they both have a status other than CANCELLED.
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_training_plan_id
--  p_object_version_number
--  p_plan_status_type_id
--  p_time_period_id
--  p_person_id
--  p_organization_id
--
-- Post Success:
--   Processing continues
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
-- ----------------------------------------------------------------------------
PROCEDURE chk_period_overlap
  (p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE
  ,p_plan_status_type_id       IN     ota_training_plans.plan_status_type_id%TYPE
  ,p_time_period_id            IN     ota_training_plans.time_period_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_organization_id           IN     ota_training_plans.organization_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_currency_code >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The currency code must exist in FND_CURRENCIES
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_budget_currency
--  p_training_plan_id
--  p_business_group_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues
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
PROCEDURE chk_currency_code
  ( p_budget_currency        IN ota_training_plans.budget_currency%TYPE
   ,p_training_plan_id       IN ota_training_plans.training_plan_id%TYPE
   ,p_business_group_id      IN ota_training_plans.business_group_id%TYPE
   ,p_object_version_number  IN ota_training_plans.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The name field must not be null.
--    The name must be unique within business group for org plans, whereas for
--    non-org plans unique within business group and person plans.
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_name
--
-- Post Success:
--   Processing continues
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
PROCEDURE chk_name
  (p_name                    IN     ota_training_plans.name%TYPE
  ,p_training_plan_id        IN     ota_training_plans.training_plan_id%TYPE
  ,p_person_id               IN     ota_training_plans.person_id%TYPE
  ,p_contact_id              IN     ota_training_plans.contact_id%TYPE
  ,p_business_group_id       IN     ota_training_plans.business_group_id%TYPE
  ,p_object_version_number   IN     ota_training_plans.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_del_training_plan_id  >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    A training plan cannot be deleted if
--      - Budget records exist in PER_BUDGET_ELEMENTS
--      - Cost records exist in OTA_TRAINING_PLAN_COSTS
--      - Member records exist in OTA_TRAINING_PLAN_MEMBERS
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_training_plan_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an error has occurred or a record is found preventing the plan from
--   being deleted ,an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_del_training_plan_id
  (p_training_plan_id     IN     ota_training_plans.training_plan_id%TYPE
  ) ;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_plan_source  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
--    The plan_source must exist in hr_lookups under the correct lookup type.
--    as the training plan.
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_effective_date
--  p_plan_source
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


PROCEDURE chk_plan_source   (p_training_plan_id 		IN NUMBER
                            ,p_plan_source	 			IN VARCHAR2
                            ,p_effective_date			IN DATE );

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_tp_date_range  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure enforces the rules :
-- Training plan start date should not be less than sysdate.
-- End date cannot be less than start date.
-- The Training plan component dates are always within the
-- range of Training plan dates called only on update
--
-- Prerequisites:
--
-- In Parameters:
--
--  p_start_date
--  p_end_date
--  p_object_version_number
--  p_training_plan_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

 PROCEDURE chk_tp_date_range  (p_training_plan_id IN ota_training_plans.training_plan_id%TYPE
                              ,p_start_date IN ota_training_plans.start_date%TYPE
                              ,p_end_date IN  ota_training_plans.end_date%TYPE DEFAULT NULL
                              ,p_object_version_number IN ota_training_plans.object_version_number%TYPE);

END ota_tps_bus1;

 

/
