--------------------------------------------------------
--  DDL for Package Body PER_HU_PENSION_OBJECTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_PENSION_OBJECTS" AS
/* $Header: pehupqpp.pkb 120.0.12010000.2 2009/05/11 12:25:41 rbabla ship $ */
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


-------------------------------------------------------------------------------
-- create_pension_element
-------------------------------------------------------------------------------
-- Pension Category -- goes into element extra information
-- Start Date -- defines the start date for all payroll objects
-- Pension Year Start Date -- goes into element extra information
-- Pension Scheme Name -- goes into element extra information
-- Pension Provider (id) -- goes into element extra information
-- Pension Type (id) -- goes into element extra information
-- Employee deduction method (lookup code) -- goes into element extra information
-- Fund reference number -- goes into element extra information
-- Employer reference number -- goes into element extra information
-- Employee supplement(lookup code) -- goes into element extra information
-- Employer supplement(lookup code) -- goes into element extra information
-- Employer deduction method(lookup code) -- goes into element extra information
-- Prefix -- element type base name
-- reporting name -- element type reporting name
-- description -- element type description
-- third party payment -- third party payment flag
-- termination rule -- termination rule for the element type
-- standard link -- standard link flag for element type.
--
--
-------------------------------------------------------------------------------
-- create_pension_element
-------------------------------------------------------------------------------
--
PROCEDURE create_pension_element(p_supp_element              VARCHAR2
                                ,p_ee_element                VARCHAR2
                                ,p_validate                  BOOLEAN
                                ,p_element_name              VARCHAR2
                                ,p_reporting_name            VARCHAR2
                                ,p_element_description       VARCHAR2
                                ,p_business_group_id         NUMBER
                                ,p_effective_start_date      DATE
                                ,p_standard_link_flag        VARCHAR2
                                ,p_post_termination_rule     VARCHAR2
                                ,p_third_party_pay_only      VARCHAR2
                                ,p_contribution_type         VARCHAR2
                                ,p_pension_scheme_name       VARCHAR2
                                ,p_pension_provider          VARCHAR2
                                ,p_pension_type              VARCHAR2
                                ,p_pension_category          VARCHAR2
                                ,p_pension_year_start_date   VARCHAR2
                                ,p_employee_deduction_method VARCHAR2
                                ,p_employer_deduction_method VARCHAR2
                                ,p_scheme_number             VARCHAR2
                                ,p_employee_supplement       VARCHAR2
                                ,p_employer_supplement       VARCHAR2
                                ,p_employer_reference_number VARCHAR2
                                ,p_scheme_prefix             VARCHAR2
                                ,p_element_type_id           OUT NOCOPY NUMBER)  IS

--
  l_input_value_id	    pay_input_values_f.input_value_id%TYPE;
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;

  g_package     varchar2(30) :='per_hu_pension_objects';
  --
  -- Variables for IN/OUT parameters
  --
  l_element_type_extra_info_id number;
  --l_object_version_number      number;
  --
  l_element_type_id             NUMBER;
  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
  l_object_version_number       NUMBER;
  l_comment_id			NUMBER;
  l_processing_priority_warning BOOLEAN;

  l_default_val_warning         BOOLEAN;
  l_min_max_warning             BOOLEAN;
  l_pay_basis_warning           BOOLEAN;
  l_formula_warning             BOOLEAN;
  l_assignment_id_warning       BOOLEAN;
  l_percent                     NUMBER := 0;
  l_rate                        NUMBER := 0;
  l_formula_message             VARCHAR2(200);
  l_classification_id           pay_element_classifications.classification_id%TYPE;

  CURSOR cur_get_classification_id IS
  SELECT classification_id
  FROM   pay_element_classifications
  WHERE  classification_name      = 'Information'
  AND    legislation_code         = 'HU';

  CURSOR cur_get_pt_details IS
  SELECT decode(p_ee_element,'Y',nvl(ee_contribution_percent,0),nvl(er_contribution_percent,0))
        ,decode(p_ee_element,'Y',nvl(ee_contribution_fixed_rate,0),nvl(er_contribution_fixed_rate,0))
    FROM pqp_pension_types_f
  WHERE  pension_type_id = p_pension_type
    AND  p_effective_start_date BETWEEN effective_start_date
    AND  effective_end_date;

BEGIN
  --
  --
  OPEN cur_get_classification_id;
      FETCH cur_get_classification_id INTO l_classification_id;
  CLOSE cur_get_classification_id;

  OPEN cur_get_pt_details;
  FETCH cur_get_pt_details INTO l_percent,l_rate;
  CLOSE cur_get_pt_details;

  --
  -- Create Element for HU Pension

     pay_element_types_api.create_element_type
        (p_validate                        => p_validate
        ,p_effective_date                  => p_effective_start_date
        ,p_classification_id               => l_classification_id
        ,p_element_name                    => p_element_name
        ,p_input_currency_code             => 'EUR'
        ,p_output_currency_code            => 'EUR'
        ,p_multiple_entries_allowed_fla    => 'N'
        ,p_processing_type                 => 'R'
        ,p_business_group_id               => p_business_group_id
        ,p_reporting_name                  => p_reporting_name
        ,p_description                     => p_element_description
        ,p_post_termination_rule           => p_post_termination_rule
        ,p_standard_link_flag              => p_standard_link_flag
        ,p_third_party_pay_only_flag       => p_third_party_pay_only
        ,p_element_type_id                 => l_element_type_id
        ,p_effective_start_date            => l_effective_start_date
        ,p_effective_end_date              => l_effective_end_date
        ,p_object_version_number           => l_object_version_number
        ,p_comment_id			   => l_comment_id
        ,p_processing_priority_warning     => l_processing_priority_warning);
     --
     pay_input_value_api.create_input_value
       (p_validate                => p_validate
       ,p_effective_date          => p_effective_start_date
       ,p_element_type_id         => l_element_type_id
       ,p_name                    => 'Override Start Date'
       ,p_uom                     => 'D'
       ,p_input_value_id	      => l_input_value_id
       ,p_object_version_number   => l_object_version_number
       ,p_effective_start_date    => l_effective_start_date
       ,p_effective_end_date      => l_effective_end_date
       ,p_default_val_warning     => l_default_val_warning
       ,p_min_max_warning         => l_min_max_warning
       ,p_pay_basis_warning       => l_pay_basis_warning
       ,p_formula_warning         => l_formula_warning
       ,p_assignment_id_warning   => l_assignment_id_warning
       ,p_formula_message         => l_formula_message
      );
     --
    pay_input_value_api.create_input_value
      ( p_validate                => p_validate
       ,p_effective_date          => p_effective_start_date
       ,p_element_type_id         => l_element_type_id
       ,p_name                    => 'Reason for Joining'
       ,p_uom                     => 'C'
       ,p_input_value_id	  => l_input_value_id
       ,p_lookup_type             => 'HU_JOINING_REASON'
       ,p_warning_or_error        => 'E'  --Added for Bug 8504813
       ,p_object_version_number   => l_object_version_number
       ,p_effective_start_date    => l_effective_start_date
       ,p_effective_end_date      => l_effective_end_date
       ,p_default_val_warning     => l_default_val_warning
       ,p_min_max_warning         => l_min_max_warning
       ,p_pay_basis_warning       => l_pay_basis_warning
       ,p_formula_warning         => l_formula_warning
       ,p_assignment_id_warning   => l_assignment_id_warning
       ,p_formula_message         => l_formula_message
      );
     --
    pay_input_value_api.create_input_value
      ( p_validate                => p_validate
       ,p_effective_date          => p_effective_start_date
       ,p_element_type_id         => l_element_type_id
       ,p_name                    => 'Opt Out Date'
       ,p_uom                     => 'D'
       ,p_input_value_id	      => l_input_value_id
       ,p_object_version_number   => l_object_version_number
       ,p_effective_start_date    => l_effective_start_date
       ,p_effective_end_date      => l_effective_end_date
       ,p_default_val_warning     => l_default_val_warning
       ,p_min_max_warning         => l_min_max_warning
       ,p_pay_basis_warning       => l_pay_basis_warning
       ,p_formula_warning         => l_formula_warning
       ,p_assignment_id_warning   => l_assignment_id_warning
       ,p_formula_message         => l_formula_message
      );
     --
   IF  p_contribution_type = 'PE' THEN
       pay_input_value_api.create_input_value
         ( p_validate                => p_validate
          ,p_effective_date          => p_effective_start_date
          ,p_element_type_id         => l_element_type_id
          ,p_name                    => 'Contribution Percent'
          ,p_uom                     => 'N'
          ,p_input_value_id	     => l_input_value_id
          ,p_default_value           => fnd_number.number_to_canonical(l_percent)
          ,p_object_version_number   => l_object_version_number
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_default_val_warning     => l_default_val_warning
          ,p_min_max_warning         => l_min_max_warning
          ,p_pay_basis_warning       => l_pay_basis_warning
          ,p_formula_warning         => l_formula_warning
          ,p_assignment_id_warning   => l_assignment_id_warning
          ,p_formula_message         => l_formula_message
         );
     ELSIF p_contribution_type = 'FR' THEN
         pay_input_value_api.create_input_value
          ( p_validate                => p_validate
           ,p_effective_date          => p_effective_start_date
           ,p_element_type_id         => l_element_type_id
           ,p_name                    => 'Contribution Rate'
           ,p_uom                     => 'N'
           ,p_input_value_id	      => l_input_value_id
           ,p_default_value           => fnd_number.number_to_canonical(l_rate)
           ,p_object_version_number   => l_object_version_number
           ,p_effective_start_date    => l_effective_start_date
           ,p_effective_end_date      => l_effective_end_date
           ,p_default_val_warning     => l_default_val_warning
           ,p_min_max_warning         => l_min_max_warning
           ,p_pay_basis_warning       => l_pay_basis_warning
           ,p_formula_warning         => l_formula_warning
           ,p_assignment_id_warning   => l_assignment_id_warning
           ,p_formula_message         => l_formula_message
          );
     ELSIF p_contribution_type = 'PEFR' THEN
       pay_input_value_api.create_input_value
         ( p_validate                => p_validate
          ,p_effective_date          => p_effective_start_date
          ,p_element_type_id         => l_element_type_id
          ,p_name                    => 'Contribution Percent'
          ,p_uom                     => 'N'
          ,p_input_value_id	     => l_input_value_id
          ,p_default_value           => fnd_number.number_to_canonical(l_percent)
          ,p_object_version_number   => l_object_version_number
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_default_val_warning     => l_default_val_warning
          ,p_min_max_warning         => l_min_max_warning
          ,p_pay_basis_warning       => l_pay_basis_warning
          ,p_formula_warning         => l_formula_warning
          ,p_assignment_id_warning   => l_assignment_id_warning
          ,p_formula_message         => l_formula_message
         );
      pay_input_value_api.create_input_value
          ( p_validate                => p_validate
           ,p_effective_date          => p_effective_start_date
           ,p_element_type_id         => l_element_type_id
           ,p_name                    => 'Contribution Rate'
           ,p_uom                     => 'N'
           ,p_input_value_id	      => l_input_value_id
           ,p_default_value           => fnd_number.number_to_canonical(l_rate)
           ,p_object_version_number   => l_object_version_number
           ,p_effective_start_date    => l_effective_start_date
           ,p_effective_end_date      => l_effective_end_date
           ,p_default_val_warning     => l_default_val_warning
           ,p_min_max_warning         => l_min_max_warning
           ,p_pay_basis_warning       => l_pay_basis_warning
           ,p_formula_warning         => l_formula_warning
           ,p_assignment_id_warning   => l_assignment_id_warning
           ,p_formula_message         => l_formula_message
          );
     END IF;
     --
     pay_input_value_api.create_input_value
      ( p_validate                => p_validate
       ,p_effective_date          => p_effective_start_date
       ,p_element_type_id         => l_element_type_id
       ,p_name                    => 'Personal Membership Code'
       ,p_uom                     => 'C'
       ,p_input_value_id	      => l_input_value_id
       ,p_object_version_number   => l_object_version_number
       ,p_effective_start_date    => l_effective_start_date
       ,p_effective_end_date      => l_effective_end_date
       ,p_default_val_warning     => l_default_val_warning
       ,p_min_max_warning         => l_min_max_warning
       ,p_pay_basis_warning       => l_pay_basis_warning
       ,p_formula_warning         => l_formula_warning
       ,p_assignment_id_warning   => l_assignment_id_warning
       ,p_formula_message         => l_formula_message
      );

     --only if the element being created is not a supplementary element
     -- then create element extra info

    IF p_supp_element = 'N' THEN

     pay_element_extra_info_api.create_element_extra_info
                  (p_validate                   => p_validate
                  ,p_element_type_id            => l_element_type_id
                  ,p_information_type           => 'HU_PENSION_SCHEME_INFO'
                  ,p_eei_information_category   => 'HU_PENSION_SCHEME_INFO'
                  ,p_eei_information1       => p_pension_scheme_name
                  ,p_eei_information2       => p_pension_provider
                  ,p_eei_information3       => p_pension_type
                  ,p_eei_information4       => p_pension_category
                  ,p_eei_information5       => p_pension_year_start_date
                  ,p_eei_information6       => p_employee_deduction_method
                  ,p_eei_information7       => p_employer_deduction_method
                  ,p_eei_information8       => p_scheme_number
                  ,p_eei_information9       => p_employee_supplement
                  ,p_eei_information10      => p_employer_supplement
                  ,p_eei_information11      => p_employer_reference_number
                  ,p_eei_information12      => p_scheme_prefix
                  ,p_eei_information13      => p_ee_element
                  ,p_element_type_extra_info_id => l_element_type_extra_info_id
                  ,p_object_version_number      => l_object_version_number
                  );
   END IF;

END create_pension_element;

--
-------------------------------------------------------------------------------
-- create_pension_objects
-------------------------------------------------------------------------------
--
PROCEDURE create_pension_objects(p_validate                  BOOLEAN DEFAULT FALSE
                                ,p_element_name              VARCHAR2
                                ,p_reporting_name            VARCHAR2
                                ,p_element_description       VARCHAR2
                                ,p_business_group_id         NUMBER
                                ,p_effective_start_date      DATE
                                ,p_standard_link_flag        VARCHAR2
                                ,p_post_termination_rule     VARCHAR2
                                ,p_third_party_pay_only      VARCHAR2
                                ,p_contribution_type         VARCHAR2
                                ,p_pension_scheme_name       VARCHAR2
                                ,p_pension_provider          VARCHAR2
                                ,p_pension_type              VARCHAR2
                                ,p_pension_category          VARCHAR2
                                ,p_pension_year_start_date   VARCHAR2
                                ,p_employee_deduction_method VARCHAR2
                                ,p_employer_deduction_method VARCHAR2
                                ,p_scheme_number             VARCHAR2
                                ,p_employee_supplement       VARCHAR2
                                ,p_employer_supplement       VARCHAR2
                                ,p_employer_reference_number VARCHAR2
                                ,p_scheme_prefix             VARCHAR2
                                ,p_element_type_id           OUT NOCOPY NUMBER)  IS

l_ee_supplement NUMBER;
l_er_supplement NUMBER;

BEGIN

--first call the create_pension_element to create the primary element
create_pension_element(p_supp_element      =>   'N'
               ,p_ee_element                => 'Y'
               ,p_validate                  => p_validate
               ,p_element_name              => p_scheme_prefix || ' Employee Pension Information'
               ,p_reporting_name            => p_reporting_name
               ,p_element_description       => p_element_description
               ,p_business_group_id         => p_business_group_id
               ,p_effective_start_date      => p_effective_start_date
               ,p_standard_link_flag        => p_standard_link_flag
               ,p_post_termination_rule     => p_post_termination_rule
               ,p_third_party_pay_only      => p_third_party_pay_only
               ,p_contribution_type         => p_contribution_type
               ,p_pension_scheme_name       => p_pension_scheme_name
               ,p_pension_provider          => p_pension_provider
               ,p_pension_type              => p_pension_type
               ,p_pension_category          => p_pension_category
               ,p_pension_year_start_date   => p_pension_year_start_date
               ,p_employee_deduction_method => p_employee_deduction_method
               ,p_employer_deduction_method => p_employer_deduction_method
               ,p_scheme_number             => p_scheme_number
               ,p_employee_supplement       => p_employee_supplement
               ,p_employer_supplement       => p_employer_supplement
               ,p_employer_reference_number => p_employer_reference_number
               ,p_scheme_prefix             => p_scheme_prefix
               ,p_element_type_id           => p_element_type_id);

--if an ER component exists, then create an element for the ER component

IF p_employer_deduction_method IS NOT NULL THEN

create_pension_element(p_supp_element      =>   'N'
               ,p_ee_element                => 'N'
               ,p_validate                  => p_validate
               ,p_element_name              => p_scheme_prefix || ' Employer Pension Information'
               ,p_reporting_name            => p_reporting_name
               ,p_element_description       => p_element_description
               ,p_business_group_id         => p_business_group_id
               ,p_effective_start_date      => p_effective_start_date
               ,p_standard_link_flag        => p_standard_link_flag
               ,p_post_termination_rule     => p_post_termination_rule
               ,p_third_party_pay_only      => p_third_party_pay_only
               ,p_contribution_type         => p_employer_deduction_method
               ,p_pension_scheme_name       => p_pension_scheme_name
               ,p_pension_provider          => p_pension_provider
               ,p_pension_type              => p_pension_type
               ,p_pension_category          => p_pension_category
               ,p_pension_year_start_date   => p_pension_year_start_date
               ,p_employee_deduction_method => p_employee_deduction_method
               ,p_employer_deduction_method => p_employer_deduction_method
               ,p_scheme_number             => p_scheme_number
               ,p_employee_supplement       => p_employee_supplement
               ,p_employer_supplement       => p_employer_supplement
               ,p_employer_reference_number => p_employer_reference_number
               ,p_scheme_prefix             => p_scheme_prefix
               ,p_element_type_id           => l_ee_supplement);

END IF;

--if EE/ER supplements exist then also create those elements

IF p_employee_supplement IS NOT NULL THEN

create_pension_element(p_supp_element      =>   'Y'
               ,p_ee_element                => 'Y'
               ,p_validate                  => p_validate
               ,p_element_name              => p_scheme_prefix || ' Employee Supplement'
               ,p_reporting_name            => p_reporting_name
               ,p_element_description       => p_element_description
               ,p_business_group_id         => p_business_group_id
               ,p_effective_start_date      => p_effective_start_date
               ,p_standard_link_flag        => p_standard_link_flag
               ,p_post_termination_rule     => p_post_termination_rule
               ,p_third_party_pay_only      => p_third_party_pay_only
               ,p_contribution_type         => p_employee_supplement
               ,p_pension_scheme_name       => p_pension_scheme_name
               ,p_pension_provider          => p_pension_provider
               ,p_pension_type              => p_pension_type
               ,p_pension_category          => p_pension_category
               ,p_pension_year_start_date   => p_pension_year_start_date
               ,p_employee_deduction_method => p_employee_deduction_method
               ,p_employer_deduction_method => p_employer_deduction_method
               ,p_scheme_number             => p_scheme_number
               ,p_employee_supplement       => p_employee_supplement
               ,p_employer_supplement       => p_employer_supplement
               ,p_employer_reference_number => p_employer_reference_number
               ,p_scheme_prefix             => p_scheme_prefix
               ,p_element_type_id           => l_ee_supplement);

END IF;

IF p_employer_supplement IS NOT NULL THEN

create_pension_element(p_supp_element      =>   'Y'
               ,p_ee_element                => 'N'
               ,p_validate                  => p_validate
               ,p_element_name              => p_scheme_prefix || ' Employer Supplement'
               ,p_reporting_name            => p_reporting_name
               ,p_element_description       => p_element_description
               ,p_business_group_id         => p_business_group_id
               ,p_effective_start_date      => p_effective_start_date
               ,p_standard_link_flag        => p_standard_link_flag
               ,p_post_termination_rule     => p_post_termination_rule
               ,p_third_party_pay_only      => p_third_party_pay_only
               ,p_contribution_type         => p_employer_supplement
               ,p_pension_scheme_name       => p_pension_scheme_name
               ,p_pension_provider          => p_pension_provider
               ,p_pension_type              => p_pension_type
               ,p_pension_category          => p_pension_category
               ,p_pension_year_start_date   => p_pension_year_start_date
               ,p_employee_deduction_method => p_employer_deduction_method
               ,p_employer_deduction_method => p_employer_deduction_method
               ,p_scheme_number             => p_scheme_number
               ,p_employee_supplement       => p_employee_supplement
               ,p_employer_supplement       => p_employer_supplement
               ,p_employer_reference_number => p_employer_reference_number
               ,p_scheme_prefix             => p_scheme_prefix
               ,p_element_type_id           => l_er_supplement);

END IF;

END create_pension_objects;


--------------------------------------------------------------------------------
-- create_pension_objects_swi
--------------------------------------------------------------------------------

PROCEDURE create_pension_objects_swi(
               p_validate                  IN NUMBER DEFAULT hr_api.g_false_num
              ,p_element_name              IN VARCHAR2
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
              ,p_return_status             OUT NOCOPY VARCHAR2)
 IS
 -- Variables for API Boolean parameters
  l_validate                      BOOLEAN;
  --
  g_package     VARCHAR2(30) :='per_hu_pension_objects';
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    VARCHAR2(72) := g_package ||'create_pension_objects_swi';
  --
BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_pension_objects_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
--  irc_inp_ins.set_base_key_value
--  (p_notification_preference_id => p_notification_preference_id
--  );
  --
  -- Call API
  --
per_hu_pension_objects.create_pension_objects(
                p_validate                  => l_validate
                ,p_element_name              => p_element_name
               ,p_reporting_name            => p_reporting_name
               ,p_element_description       => p_element_description
               ,p_business_group_id         => p_business_group_id
               ,p_effective_start_date      => p_effective_start_date
               ,p_standard_link_flag        => p_standard_link_flag
               ,p_post_termination_rule     => p_post_termination_rule
               ,p_third_party_pay_only      => p_third_party_pay_only
               ,p_contribution_type         => p_contribution_type
               ,p_pension_scheme_name       => p_pension_scheme_name
               ,p_pension_provider          => p_pension_provider
               ,p_pension_type              => p_pension_type
               ,p_pension_category          => p_pension_category
               ,p_pension_year_start_date   => fnd_date.date_to_canonical(p_pension_year_start_date)
               ,p_employee_deduction_method => p_employee_deduction_method
               ,p_employer_deduction_method => p_employer_deduction_method
               ,p_scheme_number             => p_scheme_number
               ,p_employee_supplement       => p_employee_supplement
               ,p_employer_supplement       => p_employer_supplement
               ,p_employer_reference_number => p_employer_reference_number
               ,p_scheme_prefix             => p_scheme_prefix
               ,p_element_type_id           => p_element_type_id);
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    --  at least one error message exists in the list.
    --
    ROLLBACK TO create_pension_objects_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_element_type_id              := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,30);
  WHEN OTHERS THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise
    -- the error.
    --
    ROLLBACK TO create_pension_objects_swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_element_type_id              := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
--

END create_pension_objects_swi;

--------------------------------------------------------------------------------
-- delete_pension_objects_swi
--------------------------------------------------------------------------------

PROCEDURE delete_pension_objects_swi
  (p_validate                      NUMBER  DEFAULT hr_api.g_false_num
  ,p_element_type_id               IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_object_version_number         IN     NUMBER
  ,p_return_status                 OUT    NOCOPY VARCHAR2      ) IS
--
-- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  g_package     varchar2(30) :='per_hu_pension_objects';
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_pension_objects_swi';
  --
BEGIN
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pension_objects_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  per_hu_pension_objects.delete_pension_objects(
                         p_validate              => l_validate
                        ,p_element_type_id       => p_element_type_id
                        ,p_effective_date        => p_effective_date
                        ,p_object_version_number => p_object_version_number);

  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    --  at least one error message exists in the list.
    --
    rollback to delete_pension_objects_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise
    -- the error.
    --
    rollback to delete_pension_objects_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);

END delete_pension_objects_swi;
--
-------------------------------------------------------------------------------
-- delete_pension_objects
-------------------------------------------------------------------------------

PROCEDURE delete_pension_objects(p_validate                BOOLEAN DEFAULT FALSE
                                ,p_element_type_id         NUMBER
                                ,p_effective_date          DATE
                                ,p_object_version_number   NUMBER
                                ) IS
--
l_element_type_id   pay_element_types_f.element_type_id%TYPE;
l_business_group_id pay_element_types_f.business_group_id%TYPE;
l_object_version_number NUMBER;
--
CURSOR csr_del_element_value IS
    SELECT business_group_id FROM pay_element_types_f
    WHERE  element_type_id=p_element_type_id
    AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

-- For Input Values
CURSOR csr_del_input_value(p_input_name VARCHAR2) IS
    SELECT input_value_id,object_version_number FROM pay_input_values_f
    WHERE   name = p_input_name
    AND     element_type_id = p_element_type_id--l_element_type_id
    AND     business_group_id = l_business_group_id
    AND     p_effective_date BETWEEN effective_start_date AND effective_end_date;

-- For Extra information
CURSOR csr_ele_extra_info IS
    SELECT element_type_extra_info_id,object_version_number
    FROM   pay_element_type_extra_info
    WHERE  eei_information_category = 'HU_PENSION_SCHEME_INFO'
    AND    element_type_id = p_element_type_id;--l_element_type_id;


TYPE v_input_values IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

l_input_values              v_input_values;
l_ele_ovn                   pay_element_types_f.object_version_number%TYPE;
l_effective_start_date      pay_input_values_f.effective_start_date%TYPE;
l_effective_end_date        pay_input_values_f.effective_end_date%TYPE;
l_balance_feeds_warning     boolean;
l_input_value_id            pay_input_values_f.input_value_id%TYPE;
l_inp_ovn                   pay_input_values_f.object_version_number%TYPE;
l_element_extra_info_id     pay_element_type_extra_info.element_type_extra_info_id%TYPE;
l_extra_info_ovn            pay_element_type_extra_info.object_version_number%TYPE;
l_processing_rules_warning  boolean;

BEGIN

l_input_values(1) := 'Override Start Date';
l_input_values(2) := 'Reason for Joining';
l_input_values(3) := 'Opt Out Date';
l_input_values(4) := 'Personal Membership Code';
l_input_values(5) := 'Contribution Percent';
l_input_values(6) := 'Contribution Amount';

--
-- Convert constant values to their corresponding boolean value
--

OPEN csr_del_element_value;
FETCH csr_del_element_value into l_business_group_id;
CLOSE csr_del_element_value;

-- For Input Values
FOR i IN 1..6
LOOP
OPEN csr_del_input_value(l_input_values(i));
FETCH csr_del_input_value INTO l_input_value_id,l_inp_ovn;
IF csr_del_input_value%FOUND THEN
    pay_input_value_api.delete_input_value
      (  p_validate                        => p_validate
        ,p_effective_date                  => p_effective_date
        ,p_datetrack_delete_mode           => 'ZAP'
        ,p_input_value_id                  => l_input_value_id
        ,p_object_version_number           => l_inp_ovn -- in/out
        ,p_effective_start_date            => l_effective_start_date -- out
        ,p_effective_end_date              => l_effective_end_date    -- out
        ,p_balance_feeds_warning           => l_balance_feeds_warning -- out
      );
END IF;
CLOSE csr_del_input_value;
END LOOP;

-- For Extra Information

OPEN csr_ele_extra_info;
FETCH csr_ele_extra_info into l_element_extra_info_id,l_extra_info_ovn;
CLOSE csr_ele_extra_info;

pay_element_extra_info_api.delete_element_extra_info
  (p_validate                      => p_validate
  ,p_element_type_extra_info_id    => l_element_extra_info_id
  ,p_object_version_number         => l_extra_info_ovn
  ) ;
--
l_object_version_number := p_object_version_number;
-- For Element Types

pay_element_types_api.delete_element_type
  (p_validate                        => p_validate
  ,p_effective_date                  => p_effective_date
  ,p_datetrack_delete_mode           => 'ZAP'
  ,p_element_type_id                 => p_element_type_id
  ,p_object_version_number           => l_object_version_number
  ,p_effective_start_date            => l_effective_start_date
  ,p_effective_end_date              => l_effective_start_date
  ,p_balance_feeds_warning           => l_balance_feeds_warning
  ,p_processing_rules_warning        => l_processing_rules_warning
  ) ;

END delete_pension_objects;
--
END per_hu_pension_objects;

/
