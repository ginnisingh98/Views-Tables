--------------------------------------------------------
--  DDL for Package PER_ASN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASN_BUS" AUTHID CURRENT_USER as
/* $Header: peasnrhi.pkh 120.0.12010000.2 2008/08/06 09:03:04 ubhat ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< Externalized chk_ procedures >------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assessment_type_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assessment_type_id
  (p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_assessment_type_id		in per_assessments.assessment_type_id%TYPE
  ,p_assessment_date		in per_assessments.assessment_date%TYPE
  ,p_business_group_id		in per_assessments.business_group_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assessment_date >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assessment_date
  (p_assessment_date    in  per_assessments.assessment_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_person_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_person_id 		in  per_assessments.person_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_assessment_date    in  per_assessments.assessment_date%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assessor_person_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assessor_person_id
  (p_assessor_person_id	in  per_assessments.assessor_person_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_assessment_date    in  per_assessments.assessment_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_group_date_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_group_date_id
  (p_group_initiator_id	in  per_assessments.group_initiator_id%TYPE
  ,p_group_date    in  per_assessments.group_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_group_initiator_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_group_initiator_id
  (p_group_initiator_id	in  per_assessments.group_initiator_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_group_date    in  per_assessments.group_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_status >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_status 		in 	per_assessments.status%TYPE
  ,p_effective_date	in 	date
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assessment_period >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assessment_period
  (p_assessment_period_start_date in per_assessments.assessment_period_start_date%TYPE
  ,p_assessment_period_end_date in per_assessments.assessment_period_end_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_unique_combination >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_combination
  (p_assessment_id  in per_assessments.assessment_id%TYPE
  ,p_assessment_type_id  in per_assessments.assessment_type_id%TYPE
  ,p_assessment_date	 in per_assessments.assessment_date%TYPE
  ,p_person_id		 in per_assessments.person_id%TYPE
  ,p_assessor_person_id  in per_assessments.assessor_person_id%TYPE
  ,p_group_date 	 in per_assessments.group_date%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assessment_group_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assessment_group_id
  (p_assessment_group_id	in per_assessments.assessment_group_id%TYPE
  ,p_business_group_id  in per_assessments.business_group_id%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |------------------------< chk_appraisal_id >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body
--
-- ACCESS STATUS
--  Internal Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_appraisal_id
  (p_appraisal_id	in per_assessments.assessment_group_id%TYPE
  ,p_business_group_id  in per_assessments.business_group_id%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec in per_asn_shd.g_rec_type
  ,p_effective_date in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec in per_asn_shd.g_rec_type
  ,p_effective_date	in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_asn_shd.g_rec_type);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function gets the legislation code
--
-- Pre Conditions:
--   This private procedure will be called from the user hook procedures.
--
-- In Parameters:
--   the primary key of the table (per_assessments)
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the legislation code is not found then it errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
Function return_legislation_code (
         p_assessment_id        in   number)
         return  varchar2;
--
--
end per_asn_bus;

/
