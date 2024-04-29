--------------------------------------------------------
--  DDL for Package PER_HU_PENSION_OBJECTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_PENSION_OBJECTS" AUTHID CURRENT_USER AS
/* $Header: pehupqpp.pkh 120.0.12010000.1 2008/07/28 04:49:48 appldev ship $ */
--------------------------------------------------------------------------------
-- create_pension_objects
--------------------------------------------------------------------------------
--
-- Description:
-- This procedure is the self-service wrapper procedure to the following API:
--
--  pay_element_extra_info_api.create_element_extra_info
--
--
-- Pre-requisites
-- All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
-- p_return_status will return value indicating success.
--
-- Post Failure:
-- p_return_status will return value indication failure.
--
-- Access Status:
-- Internal Development use only.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_pension_objects_swi(p_validate                      IN     NUMBER  DEFAULT hr_api.g_false_num
                                ,p_element_name             IN VARCHAR2
                               ,p_reporting_name            IN VARCHAR2
                               ,p_element_description       IN VARCHAR2
                               ,p_business_group_id         IN NUMBER
                               ,p_effective_start_date      IN DATE
                               ,p_standard_link_flag        IN VARCHAR2
                               ,p_post_termination_rule     IN VARCHAR2
                               ,p_third_party_pay_only      IN VARCHAR2
                               ,p_contribution_type         IN VARCHAR2
                               ,p_pension_scheme_name       IN VARCHAR2
                               ,p_pension_provider          IN VARCHAR2
                               ,p_pension_type              IN VARCHAR2
                               ,p_pension_category          IN VARCHAR2
                               ,p_pension_year_start_date   IN VARCHAR2
                               ,p_employee_deduction_method IN VARCHAR2
                               ,p_employer_deduction_method IN VARCHAR2
                               ,p_scheme_number             IN VARCHAR2
                               ,p_employee_supplement       IN VARCHAR2
                               ,p_employer_supplement       IN VARCHAR2
                               ,p_employer_reference_number IN VARCHAR2
                               ,p_scheme_prefix             IN VARCHAR2
                               ,p_element_type_id           OUT NOCOPY NUMBER
                               ,p_return_status             OUT NOCOPY VARCHAR2);




--
PROCEDURE create_pension_objects(p_validate                 boolean default false
                                ,p_element_name             IN VARCHAR2
                               ,p_reporting_name            IN VARCHAR2
                               ,p_element_description       IN VARCHAR2
                               ,p_business_group_id         IN NUMBER
                               ,p_effective_start_date      IN DATE
                               ,p_standard_link_flag        IN VARCHAR2
                               ,p_post_termination_rule     IN VARCHAR2
                               ,p_third_party_pay_only      IN VARCHAR2
                               ,p_contribution_type         IN VARCHAR2
                               ,p_pension_scheme_name       IN VARCHAR2
                               ,p_pension_provider          IN VARCHAR2
                               ,p_pension_type              IN VARCHAR2
                               ,p_pension_category          IN VARCHAR2
                               ,p_pension_year_start_date   IN VARCHAR2
                               ,p_employee_deduction_method IN VARCHAR2
                               ,p_employer_deduction_method IN VARCHAR2
                               ,p_scheme_number             IN VARCHAR2
                               ,p_employee_supplement       IN VARCHAR2
                               ,p_employer_supplement       IN VARCHAR2
                               ,p_employer_reference_number IN VARCHAR2
                               ,p_scheme_prefix             IN VARCHAR2
                               ,p_element_type_id           OUT NOCOPY NUMBER);

-------------------------------------------------------------------------------
-- delete_element_extra_info
---------------------------------------------------------------------------------
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following API:
--
--  pay_element_extra_info_api.delete_element_extra_info
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- ----------------------------------------------------------------------------

PROCEDURE delete_pension_objects_swi
  (p_validate                      IN     NUMBER  DEFAULT hr_api.g_false_num
  ,p_element_type_id               IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_object_version_number         IN     NUMBER
  ,p_return_status                 OUT    NOCOPY VARCHAR2
  );

--
PROCEDURE delete_pension_objects(p_validate             boolean default false
                                ,p_element_type_id           NUMBER
                                ,p_effective_date            DATE
                                ,p_object_version_number     NUMBER
                                );

END per_hu_pension_objects;

/
