--------------------------------------------------------
--  DDL for Package OTA_TPM_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPM_BUS1" AUTHID CURRENT_USER as
/* $Header: ottpmrhi.pkh 120.0 2005/05/29 07:48:29 appldev noship $ */
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
  (p_training_plan_id          in     ota_training_plan_members.training_plan_id%TYPE
  ,p_business_group_id         in     ota_training_plan_members.business_group_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_activity_definition_id>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the activity definition exists in the database
--   and with the business_group_id.
--
-- Prerequisites:
--   call chk_version_definition first
--
-- In Parameters:
--   p_training_plan_member_id
--   p_object_version_number
--   p_activity_definition_id
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
Procedure chk_activity_definition_id (
   p_training_plan_member_id   in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     in     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_definition_id    in     ota_training_plan_members.activity_definition_id%TYPE
  ,p_business_group_id         in     ota_training_plan_members.business_group_id%TYPE
  ) ;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_version_definition>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A shared function to perform the common functions of
--    chk_activity_version_id and
--    chk_activity_definition_id
--   This must be called before the two chk_ procedures mentioned above.
--
--   This validates that only one of activity_version_id and activity_definition_id
--   is set, and that if an update to one of theses columns is happending,
--   there are no per_budget_elements records.
--
-- Prerequisites:
--
-- In Parameters:
--   p_training_plan_member_id
--   p_object_version_number
--   p_activity_version_id
--   p_activity_definition_id
--   p_business_group_id
--   p_training_plan_id
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
Procedure chk_version_definition (
   p_training_plan_member_id   in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     in     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_version_id       in     ota_training_plan_members.activity_version_id%TYPE
  ,p_activity_definition_id    in     ota_training_plan_members.activity_definition_id%TYPE
  ,p_business_group_id         in     ota_training_plan_members.business_group_id%TYPE
  ,p_training_plan_id          in     ota_training_plan_members.training_plan_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_activity_version_id>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the activity_version_id :
--    Exists and is in the same business group as the member record
--    Is within the date range of the plan
--    Has no non-cancelled members in the plan that are superceeding this member.
--
-- Prerequisites:
--   Call chk_version_definition first.
--
-- In Parameters:
--   p_training_plan_member_id
--   p_object_version_number
--   p_activity_version_id
--   p_business_group_id
--   p_training_plan_id
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
Procedure chk_activity_version_id (
   p_training_plan_member_id   in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     in     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_version_id       in     ota_training_plan_members.activity_version_id%TYPE
  ,p_business_group_id         in     ota_training_plan_members.business_group_id%TYPE
  ,p_training_plan_id          in     ota_training_plan_members.training_plan_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_member_status_type_id>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the member_status exists in hr_lookups.
--   An Activity Version whose status is not cancelled cannot have a
--   parent activity definition whose status is not cancelled, in the same plan.
--   An Activity Definition whose status is not cancelled cannot have a
--   child activity version whose status is not cancelled, in the same plan.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_effective_date
--   p_member_status_type_id
--   p_business_group_id
--   p_training_plan_member_id
--   p_object_version_number
--   p_activity_version_id
--   p_activity_definition_id
--   p_training_plan_id
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
Procedure chk_member_status_type_id (
   p_effective_date            in     date
  ,p_member_status_type_id     in     ota_training_plan_members.member_status_type_id%TYPE
  ,p_business_group_id         in     ota_training_plan_members.business_group_id%TYPE
  ,p_training_plan_member_id   in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     in     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_version_id       in     ota_training_plan_members.activity_version_id%TYPE
  ,p_activity_definition_id    in     ota_training_plan_members.activity_definition_id%TYPE
  ,p_training_plan_id          in     ota_training_plan_members.training_plan_id%TYPE
  ,p_target_completion_date    in     ota_training_plan_members.target_completion_date%type
  );

  -- ----------------------------------------------------------------------------
-- |----------------------<chk_unique1>----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A procedure to perform the common functions of
--   chk_activity_version_id
--   chk_activity_definition_id
--   chk_training_plan_id
--   The values will first be checked by their respective chk_procedures.
--   Validates that the column combination is unique
--
-- Prerequisites:
--   chk_ procedures listed above have already been called
--
-- In Parameters:
--   p_training_plan_member_id
--   p_object_version_number
--   p_activity_version_id
--   p_activity_definition_id
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
Procedure chk_unique1 (
   p_training_plan_member_id    in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number      in     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_definition_id     in     ota_training_plan_members.activity_definition_id%TYPE
  ,p_activity_version_id        in     ota_training_plan_members.activity_version_id%TYPE
  ,p_training_plan_id           in     ota_training_plan_members.training_plan_id%TYPE
  ,p_target_completion_date     in     ota_training_plan_members.target_completion_date%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique>----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A procedure to perform the common functions of
--   chk_activity_version_id
--   chk_activity_definition_id
--   chk_training_plan_id
--   The values will first be checked by their respective chk_procedures.
--   Validates that the column combination is unique
--
-- Prerequisites:
--   chk_ procedures listed above have already been called
--
-- In Parameters:
--   p_training_plan_member_id
--   p_object_version_number
--   p_activity_version_id
--   p_activity_definition_id
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
Procedure chk_unique (
   p_training_plan_member_id    in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number      in     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_definition_id     in     ota_training_plan_members.activity_definition_id%TYPE
  ,p_activity_version_id        in     ota_training_plan_members.activity_version_id%TYPE
  ,p_training_plan_id           in     ota_training_plan_members.training_plan_id%TYPE
  );
-- ----------------------------------------------------------------------------
-- |----------------------<chk_delete>-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that no records exist in per_budget_elements for the training_plan_member
--   that is about to be deleted
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_training_plan_member_id
--   p_training_plan_id
--
-- Post Success:
--   Processing continues if the member can be deleted
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
Procedure chk_delete (
   p_training_plan_member_id   in     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_training_plan_id          in     ota_training_plan_members.training_plan_id%TYPE
  );

-- ----------------------------------------------------------------------------
-- |----------------------<chk_source_function>-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that source_function exists in hr_lookups
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_effective_date
--   p_training_plan_member_id
--
-- Post Success:
--   Processing continues if the value is legal.
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


Procedure chk_source_function
  (p_training_plan_member_id 				in number
   ,p_source_function	 			in varchar2
   ,p_effective_date			in date);



-- ----------------------------------------------------------------------------
-- |----------------------<chk_cancellation_reason>-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that cancellation_reason exists in hr_lookups
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_effective_date
--   p_training_plan_member_id
--
-- Post Success:
--   Processing continues if the value is legal.
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


Procedure chk_cancellation_reason
  (p_training_plan_member_id 				in number
   ,p_cancellation_reason	 			in varchar2
   ,p_effective_date			in date);

-- ----------------------------------------------------------------------------
-- |----------------------<chk_tpc_tp_actver_dates>-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that Training Plan Component dates lie well within the Training plan dates and also
--   within the Activity Version Id dates
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_earliest_start_date
--   p_target_completion_date
--   p_object_version_number
--   p_training_plan_member_id
--
-- Post Success:
--   Processing continues if the the dates are legal.
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


Procedure chk_tpc_tp_actver_dates(p_training_plan_id in ota_training_plans.training_plan_id%type
                                  ,p_training_plan_member_id    IN ota_training_plan_members.training_plan_member_id%TYPE
                                  ,p_activity_version_id in ota_training_plan_members.activity_version_id%type
                                  ,p_earliest_start_date in ota_training_plan_members.earliest_start_date%TYPE
                                  ,p_target_completion_date in  ota_training_plan_members.target_completion_date%type
                                  ,p_object_version_number in ota_training_plan_members.object_version_number%type);





end ota_tpm_bus1;

 

/
