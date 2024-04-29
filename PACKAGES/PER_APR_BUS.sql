--------------------------------------------------------
--  DDL for Package PER_APR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APR_BUS" AUTHID CURRENT_USER as
/* $Header: peaprrhi.pkh 120.2.12010000.3 2009/08/12 14:18:24 rvagvala ship $ */

-- ---------------------------------------------------------------------------+
-- |------------------------< set_security_group_id >-------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
-- Set the security_group_id in CLIENT_INFO for the appraisals's business
-- group context.

-- Prerequisites:
--   None,

-- In Parameters:
--   Name                           Reqd Type     Description
--   appraisal_id                   Yes  Number   appraisal_id to use for
--                                                deriving the security group
--                                                context.

-- Post Success:
--  The security_group_id will be set in CLIENT_INFO.

-- Post Failure:
--   An error is raised if the appraisal_id does not exist.

-- Access Status:
--   Internal Development Use Only.

-- {End Of Comments}

-- ---------------------------------------------------------------------------+
procedure set_security_group_id
  (
   p_appraisal_id               in per_appraisals.appraisal_id%TYPE,
   p_associated_column1        in varchar2 default null
  );
-- ---------------------------------------------------------------------------+
-- |------------------------< Externalized chk_ procedures >------------------|
-- ---------------------------------------------------------------------------+
-- ---------------------------------------------------------------------------+
-- |------------------------< chk_appraisal_template>-------------------------|
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}
-- ---------------------------------------------------------------------------+
procedure chk_appraisal_template
(p_appraisal_template_id     in      per_appraisals.appraisal_template_id%TYPE
,p_business_group_id         in      per_appraisals.business_group_id%TYPE
,p_effective_date            in      date
);
-- ---------------------------------------------------------------------------+
-- |------------------------< chk_appraisee_appraiser>------------------------|
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}
-- ---------------------------------------------------------------------------+
procedure chk_appraisee_appraiser
(p_person_id                 in      per_people_f.person_id%TYPE
,p_business_group_id         in      per_appraisals.business_group_id%TYPE
,p_effective_date            in      date
,p_person_type               in      varchar2
);


-- ---------------------------------------------------------------------------+
-- |--------------------------<chk_main_appraiser_id>-------------------------+
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}

procedure chk_main_appraiser_id
(p_main_appraiser_id  	     in      per_appraisals.main_appraiser_id%TYPE
,p_business_group_id	     in	     per_appraisals.business_group_id%TYPE
,p_effective_date            in      date
);


-- ---------------------------------------------------------------------------+
-- |------------------------< chk_appraisal_type >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}
-- ---------------------------------------------------------------------------+
procedure chk_appraisal_type
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_type                      in      per_appraisals.type%TYPE
,p_effective_date            in      date
);
-- ---------------------------------------------------------------------------+
-- |------------------------< chk_appraisal_status >--------------------------|
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}
-- ---------------------------------------------------------------------------+
procedure chk_appraisal_status
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_status                    in      per_appraisals.status%TYPE
,p_effective_date            in      date
);
-- ---------------------------------------------------------------------------+
-- |------------------------< chk_appraisal_status >--------------------------|
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}
-- ---------------------------------------------------------------------------+
procedure chk_overall_rating
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_appraisal_template_id     in      per_appraisals.appraisal_template_id%TYPE
,p_overall_performance_level_id in   per_appraisals.overall_performance_level_id
%TYPE
,p_business_group_id         in      per_appraisals.business_group_id%TYPE
);
-- ---------------------------------------------------------------------------+
-- |------------------------< chk_appraisal_period_dates >--------------------|
-- ---------------------------------------------------------------------------+
-- {Start of Comments}
-- see body

-- ACCESS STATUS
--  Internal HR Development Use Only

-- {End of Comments}
-- ---------------------------------------------------------------------------+
procedure chk_appraisal_period_dates
(p_appraisal_id                 in     per_appraisals.appraisal_id%TYPE
,p_object_version_number        in     per_appraisals.object_version_number%TYPE
,p_appraisal_period_start_date  in
		per_appraisals.appraisal_period_start_date%TYPE
,p_appraisal_period_end_date    in
		per_appraisals.appraisal_period_end_date%TYPE
);

-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.

-- Pre Conditions:
--   This private procedure is called from ins procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.

-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure insert_validate(p_rec in per_apr_shd.g_rec_type
			 ,p_effective_date in date);

-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This procedure controls the execution of all update business rules
--   validation.

-- Pre Conditions:
--   This private procedure is called from upd procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.

-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure update_validate(p_rec in per_apr_shd.g_rec_type
			  ,p_effective_date in date);

-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.

-- Pre Conditions:
--   This private procedure is called from del procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.

-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure delete_validate(p_rec in per_apr_shd.g_rec_type);

-- ---------------------------------------------------------------------------+
-- |-----------------------< return_legislation_code >------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This function gets the legislation code

-- Pre Conditions:
--   This private procedure will be called from the user hook procedures.

-- In Parameters:
--   the primary key of the table (per_appraisals)

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If the legislation code is not found then it errors out

-- Developer Implementation Notes:

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}

Function return_legislation_code (
         p_appraisal_id        in   number)
         return  varchar2;


end per_apr_bus;

/
