--------------------------------------------------------
--  DDL for Package Body HR_NL_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_ASSIGNMENT_API" AS
/* $Header: peasgnli.pkb 120.2 2006/01/18 00:09:45 summohan noship $ */

--
--------------------------------------------------------------------------------
-- create_nl_secondary_emp_asg
--------------------------------------------------------------------------------
--
--
-- Description:
--   Procedure creates secondary employment assignment for an employee.
--
-- Prerequisites:
--   The person (p_person_id) and the organization (p_organization_id)
--   must exist at the effective start date of the assignment (p_effective_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date                Yes date     The effective start date of
--                                                this assignment
--   p_person_id                     Yes number   The person for whom this
--                                                assigment applies
--   p_organization_id               Yes number   Organization
--   p_grade_id                          number   Grade
--   p_position_id                       number   Position
--   p_job_id                            number   Job
--   p_assignment_status_type_id         number   Assigmnent status
--   p_payroll_id                        number   Payroll
--   p_location_id                       number   Location
--   p_supervisor_id                     number   Supervisor
--   p_special_ceiling_step_id           number   Special ceiling step
--   p_pay_basis_id                      number   Salary basis
--   p_assignment_number                 varchar2 Assignment number
--   p_change_reason                     varchar2 Change reason
--   p_comments                          varchar2 Comments
--   p_date_probation_end                date     End date of probation period
--   p_default_code_comb_id              number   Foreign key to
--                                                GL_CODE_COMBINATIONS
--   p_employment_category               varchar2 Employment category
--   p_frequency                         varchar2 Frequency for quoting working hours (eg per week)
--   p_internal_address_line             varchar2 Internal address line
--   p_manager_flag                      varchar2 Indicates whether employee
--                                                is a manager
--   p_regular_working_hrs               number   Normal working hours
--   p_perf_review_period                number   Performance review period
--   p_perf_review_period_frequency      varchar2 Units for quoting performance
--                                                review period (eg months)
--   p_probation_period                  number   Length of probation period
--   p_probation_unit                    varchar2 Units for quoting probation period (eg months)
--   p_sal_review_period                 number   Salary review period
--   p_sal_review_period_frequency       varchar2 Units for quoting salary
--                                                review period (eg months)
--   p_set_of_books_id                   number   Set of books (GL)
--   p_source_type                       varchar2 Recruitment activity source
--   p_time_normal_finish                varchar2 Normal work finish time
--   p_time_normal_start                 varchar2 Normal work start time
--   p_bargaining_unit_code              varchar2 Code for bargaining unit
--   p_labour_union_member_flag          varchar2 Indicates whether employee
--                                                is a labour union member
--   p_hourly_salaried_code              varchar2 Hourly or salaried pay code
--   p_ass_attribute_category            varchar2 Descriptive flexfield
--                                                attribute category
--   p_ass_attribute1                    varchar2 Descriptive flexfield
--   p_ass_attribute2                    varchar2 Descriptive flexfield
--   p_ass_attribute3                    varchar2 Descriptive flexfield
--   p_ass_attribute4                    varchar2 Descriptive flexfield
--   p_ass_attribute5                    varchar2 Descriptive flexfield
--   p_ass_attribute6                    varchar2 Descriptive flexfield
--   p_ass_attribute7                    varchar2 Descriptive flexfield
--   p_ass_attribute8                    varchar2 Descriptive flexfield
--   p_ass_attribute9                    varchar2 Descriptive flexfield
--   p_ass_attribute10                   varchar2 Descriptive flexfield
--   p_ass_attribute11                   varchar2 Descriptive flexfield
--   p_ass_attribute12                   varchar2 Descriptive flexfield
--   p_ass_attribute13                   varchar2 Descriptive flexfield
--   p_ass_attribute14                   varchar2 Descriptive flexfield
--   p_ass_attribute15                   varchar2 Descriptive flexfield
--   p_ass_attribute16                   varchar2 Descriptive flexfield
--   p_ass_attribute17                   varchar2 Descriptive flexfield
--   p_ass_attribute18                   varchar2 Descriptive flexfield
--   p_ass_attribute19                   varchar2 Descriptive flexfield
--   p_ass_attribute20                   varchar2 Descriptive flexfield
--   p_ass_attribute21                   varchar2 Descriptive flexfield
--   p_ass_attribute22                   varchar2 Descriptive flexfield
--   p_ass_attribute23                   varchar2 Descriptive flexfield
--   p_ass_attribute24                   varchar2 Descriptive flexfield
--   p_ass_attribute25                   varchar2 Descriptive flexfield
--   p_ass_attribute26                   varchar2 Descriptive flexfield
--   p_ass_attribute27                   varchar2 Descriptive flexfield
--   p_ass_attribute28                   varchar2 Descriptive flexfield
--   p_ass_attribute29                   varchar2 Descriptive flexfield
--   p_ass_attribute30                   varchar2 Descriptive flexfield
--   p_title				 varchar2 Title
--   p_employment_type                   varchar2 Employment Type
--   p_employment_subtype                varchar2 Employment Sub Type
--   p_tax_reductions_apply              varchar2 Tax Reductions Apply
--   p_paid_parental_leave_apply         varchar2 Paid Parental Leave
--   p_work_pattern                      varchar2 Work Pattern
--   p_labour_tax_apply                  varchar2 Labour Tax Reduction
--   p_income_code                       varchar2 Income Code
--   p_addl_snr_tax_apply                varchar2 Additional Sr Tax Reduction
--   p_special_indicators                varchar2 Special Indicators
--Indicates whether an employee's assignment is eligible for certain allowance or not.
--The value being the corresponding Iindicator code(from lookup NL_SPECIAL_INDICATORS)
--The codes for all Special Indicators are concatenated together and stored in this segment.
--If the user has selected Special Indicators 01, 28 and 41,
--then this segment would have the value '012841' stored in it.
--A maximum of 13 indicators can be specified

--   p_tax_code                          varchar2 Tax Code
--   p_last_year_salary                  varchar2 Last Years Salary
--   p_low_wages_apply                   varchar2 Low Wages
--   p_education_apply                   varchar2 Education
--   p_child_day_care_apply              varchar2 Child Day Care
--   p_anonymous_employee                varchar2 Anonymous Employee
--   p_long_term_unemployed              varchar2 Long Term Unemployed
--   p_foreigner_with_spl_knowledge      varchar2 Foreigner with Sp Knowledge
--   p_beneficial_rule_apply             varchar2 Use Beneficial Rule
--   p_individual_percentage             number   Individual Percentage
--   p_commencing_from                   date     Commencing From
--   p_date_approved                     date     Date Approved
--   p_date_ending                       date     Date Ending
--   p_foreigner_tax_expiry              date     Foreigner Tax Expiry Date
--   p_job_level                         varchar2 Job Level
--   p_max_days_method                   varchar2 Maximum Days Method
--   p_override_real_si_days             number   Override Real SI Days
--   p_indiv_working_hrs                 number   Individual Working Hours
--   p_part_time_percentage              number   Part time percentage
--   p_si_special_indicators             varchar2 SI Special Indicators
--   p_deviating_working_hours           varchar2 Reasons for deviating working hours
--   p_incidental_worker                 varchar2 Incidental Worker Flag
--   p_scl_concat_segments               varchar2 Concatenated scl segments
--   p_pgp_segment1                      varchar2 People group segment
--   p_pgp_segment2                      varchar2 People group segment
--   p_pgp_segment3                      varchar2 People group segment
--   p_pgp_segment4                      varchar2 People group segment
--   p_pgp_segment5                      varchar2 People group segment
--   p_pgp_segment6                      varchar2 People group segment
--   p_pgp_segment7                      varchar2 People group segment
--   p_pgp_segment8                      varchar2 People group segment
--   p_pgp_segment9                      varchar2 People group segment
--   p_pgp_segment10                     varchar2 People group segment
--   p_pgp_segment11                     varchar2 People group segment
--   p_pgp_segment12                     varchar2 People group segment
--   p_pgp_segment13                     varchar2 People group segment
--   p_pgp_segment14                     varchar2 People group segment
--   p_pgp_segment15                     varchar2 People group segment
--   p_pgp_segment16                     varchar2 People group segment
--   p_pgp_segment17                     varchar2 People group segment
--   p_pgp_segment18                     varchar2 People group segment
--   p_pgp_segment19                     varchar2 People group segment
--   p_pgp_segment20                     varchar2 People group segment
--   p_pgp_segment21                     varchar2 People group segment
--   p_pgp_segment22                     varchar2 People group segment
--   p_pgp_segment23                     varchar2 People group segment
--   p_pgp_segment24                     varchar2 People group segment
--   p_pgp_segment25                     varchar2 People group segment
--   p_pgp_segment26                     varchar2 People group segment
--   p_pgp_segment27                     varchar2 People group segment
--   p_pgp_segment28                     varchar2 People group segment
--   p_pgp_segment29                     varchar2 People group segment
--   p_pgp_segment30                     varchar2 People group segment
--   p_contract_id                       number   contract
--   p_establishment_id                  number   establishment
--   p_collective_agreement_id           number   collective_agreement
--   p_cagr_id_flex_num                  number   collective_Agreement
--                                                 grade structure
--   p_cag_segment1                      varchar2 Collective agreement grade
--   p_cag_segment2                      varchar2 Collective agreement grade
--   p_cag_segment3                      varchar2 Collective agreement grade
--   p_cag_segment4                      varchar2 Collective agreement grade
--   p_cag_segment5                      varchar2 Collective agreement grade
--   p_cag_segment6                      varchar2 Collective agreement grade
--   p_cag_segment7                      varchar2 Collective agreement grade
--   p_cag_segment8                      varchar2 Collective agreement grade
--   p_cag_segment9                      varchar2 Collective agreement grade
--   p_cag_segment10                     varchar2 Collective agreement grade
--   p_cag_segment11                     varchar2 Collective agreement grade
--   p_cag_segment12                     varchar2 Collective agreement grade
--   p_cag_segment13                     varchar2 Collective agreement grade
--   p_cag_segment14                     varchar2 Collective agreement grade
--   p_cag_segment15                     varchar2 Collective agreement grade
--   p_cag_segment16                     varchar2 Collective agreement grade
--   p_cag_segment17                     varchar2 Collective agreement grade
--   p_cag_segment18                     varchar2 Collective agreement grade
--   p_cag_segment19                     varchar2 Collective agreement grade
--   p_cag_segment20                     varchar2 Collective agreement grade
--   p_notice_period                     number   Notice Period
--   p_notice_period_uom                 varchar2 Notice Period Units
--   p_employee_category                 varchar2 Employee Category
--   p_work_at_home                      varchar2 Work At Home
--   p_job_post_source_name		 varchar2 Job Source
--
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_assignment_number            varchar2 If an assignment number is not
--                                           passed in, a value is generated.
--   p_assignment_id                number   Unique ID for the assignment
--                                           created by the API
--   p_soft_coding_keyflex_id       number   Soft coding combination ID
--   p_people_group_id              number   People Group combination ID
--   p_object_version_number        number   Version number of the new
--                                           assignment
--   p_effective_start_date         date     Effective start date of this
--                                           assignment
--   p_effective_end_date           date     Effective end date of this
--                                           assignment
--   p_assignment_sequence          number
--   p_comment_id                   number
--   p_concatenated_segments        varchar2 Soft Coding combination name
--   p_group_name                   varchar2 People Group name
--   p_other_manager_warning        boolean  Set to true if manager_flag is 'Y'
--                                           and a manager already exists in
--                                           the organization
--                                           (p_organization_id) at
--   p_hourly_salaried_warning      boolean  Set to true if combination values
--                                           entered for pay_basis and
--                                           hourly_salaried_code are invalid
--                                  date     p_effective_date
--
--  p_cagr_grade_def_id             number   Set to the ID value of the grade if
--                                           cag_segments and a cagr_id_flex_num
--                                           are available
--  p_cagr_concatenated_segments    varchar2 If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the concatenation
--                                           of all p_segment parameters with
--                                           set text. If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.

--  p_hourly_salaried_warning       boolean  Set to True if Invalid Combination
--					     for pay_basis and hourly_salaried_code
--  p_gsp_post_process_warning      varchar2 Set to a warning message name
--                                           from pqh_gsp_post_process.


-- Post Failure:
--   The API does not create the assignment and raises an error.
--
--
--
--
PROCEDURE create_nl_secondary_emp_asg
    (p_validate                     IN     BOOLEAN   DEFAULT   false
    ,p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    ,p_organization_id              IN     NUMBER
    ,p_grade_id                     IN     NUMBER    DEFAULT null
    ,p_position_id                  IN     NUMBER    DEFAULT null
    ,p_job_id                       IN     NUMBER    DEFAULT null
    ,p_assignment_status_type_id    IN     NUMBER    DEFAULT null
    ,p_payroll_id                   IN     NUMBER    DEFAULT null
    ,p_location_id                  IN     NUMBER    DEFAULT null
    ,p_supervisor_id                IN     NUMBER    DEFAULT null
    ,p_special_ceiling_step_id      IN     NUMBER    DEFAULT null
    ,p_pay_basis_id                 IN     NUMBER    DEFAULT null
    ,p_assignment_number            IN OUT NOCOPY VARCHAR2
    ,p_change_reason                IN     VARCHAR2  DEFAULT null
    ,p_comments                     IN     VARCHAR2  DEFAULT null
    ,p_date_probation_end           IN     DATE      DEFAULT null
    ,p_default_code_comb_id         IN     NUMBER    DEFAULT null
    ,p_employment_category          IN     VARCHAR2  DEFAULT null
    ,p_frequency                    IN     VARCHAR2  DEFAULT null
    ,p_internal_address_line        IN     VARCHAR2  DEFAULT null
    ,p_manager_flag                 IN     VARCHAR2  DEFAULT null
    ,p_regular_working_hrs          IN     NUMBER    DEFAULT null
    ,p_perf_review_period           IN     NUMBER    DEFAULT null
    ,p_perf_review_period_frequency IN     VARCHAR2  DEFAULT null
    ,p_probation_period             IN     NUMBER    DEFAULT null
    ,p_probation_unit               IN     VARCHAR2  DEFAULT null
    ,p_sal_review_period            IN     NUMBER    DEFAULT null
    ,p_sal_review_period_frequency  IN     VARCHAR2  DEFAULT null
    ,p_set_of_books_id              IN     NUMBER    DEFAULT null
    ,p_source_type                  IN     VARCHAR2  DEFAULT null
    ,p_time_normal_finish           IN     VARCHAR2  DEFAULT null
    ,p_time_normal_start            IN     VARCHAR2  DEFAULT null
    ,p_bargaining_unit_code         IN     VARCHAR2  DEFAULT null
    ,p_labour_union_member_flag     IN     VARCHAR2  DEFAULT null
    ,p_hourly_salaried_code         IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute_category       IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute1               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute2               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute3               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute4               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute5               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute6               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute7               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute8               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute9               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute10              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute11              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute12              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute13              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute14              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute15              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute16              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute17              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute18              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute19              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute20              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute21              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute22              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute23              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute24              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute25              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute26              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute27              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute28              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute29              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute30              IN     VARCHAR2  DEFAULT null
    ,p_title                        IN     VARCHAR2  DEFAULT null
    ,p_employment_type              IN     VARCHAR2  DEFAULT null  --Employment Type
    ,p_employment_subtype           IN     VARCHAR2  DEFAULT null  --Employment Sub Type
    ,p_tax_reductions_apply         IN     VARCHAR2  DEFAULT null  --Tax Reductions Apply
    ,p_paid_parental_leave_apply    IN     VARCHAR2  DEFAULT null  -- Paid Parental Leave
    ,p_work_pattern                 IN     VARCHAR2  DEFAULT null  --Work Pattern
    ,p_labour_tax_apply             IN     VARCHAR2  DEFAULT null  --Labour Tax Reduction
    ,p_income_code                  IN     VARCHAR2  DEFAULT null  --Income Code
    ,p_addl_snr_tax_apply           IN     VARCHAR2  DEFAULT null  --Additional Sr Tax Reduction
    ,p_special_indicators           IN     VARCHAR2  DEFAULT null  --Special Indicators
    ,p_tax_code                     IN     VARCHAR2  DEFAULT null  --Tax Code
    ,p_last_year_salary             IN     VARCHAR2  DEFAULT null  --Last Years Salary
    ,p_low_wages_apply              IN     VARCHAR2  DEFAULT null  --Low Wages
    ,p_education_apply              IN     VARCHAR2  DEFAULT null  --Education
    ,p_child_day_care_apply         IN     VARCHAR2  DEFAULT null  --Child Day Care
    ,p_anonymous_employee           IN     VARCHAR2  DEFAULT null  --Anonymous Employee
    ,p_long_term_unemployed         IN     VARCHAR2  DEFAULT null  --Long Term Unemployed
    ,p_foreigner_with_spl_knowledge IN     VARCHAR2  DEFAULT null  --Foreigner with Sp Knowledge
    ,p_beneficial_rule_apply        IN     VARCHAR2  DEFAULT null  --Use Beneficial Rule
    ,p_individual_percentage        IN     NUMBER    DEFAULT null  --Individual Percentage
    ,p_commencing_from              IN     DATE      DEFAULT null  --Commencing From
    ,p_date_approved                IN     DATE      DEFAULT null  --Date Approved
    ,p_date_ending                  IN     DATE      DEFAULT null  --Date Ending
    ,p_foreigner_tax_expiry         IN     DATE      DEFAULT null  --Foreigner Tax Expiry Date
    ,p_job_level                    IN     VARCHAR2  DEFAULT null  --Job Level
    ,p_max_days_method              IN     VARCHAR2  DEFAULT null  --Maximum Days Method
    ,p_override_real_si_days        IN     NUMBER    DEFAULT null  --Override Real SI Days
    ,p_indiv_working_hrs            IN     NUMBER    DEFAULT null  --Individual Working Hours
    ,p_part_time_percentage         IN     NUMBER    DEFAULT null  --Part time percentage
    ,p_si_special_indicators        IN     VARCHAR2  DEFAULT null  --SI Special Indicators
    ,p_deviating_working_hours      IN     VARCHAR2  DEFAULT null  --Deviating Working Hours
    ,p_incidental_worker            IN     VARCHAR2  DEFAULT null  --Incidental Worker
    ,p_scl_concat_segments          IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment1                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment2                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment3                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment4                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment5                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment6                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment7                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment8                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment9                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment10                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment11                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment12                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment13                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment14                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment15                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment16                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment17                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment18                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment19                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment20                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment21                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment22                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment23                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment24                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment25                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment26                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment27                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment28                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment29                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment30                IN     VARCHAR2  DEFAULT null
    ,p_pgp_concat_segments          IN     VARCHAR2  DEFAULT null
    ,p_contract_id                  IN     NUMBER    DEFAULT null
    ,p_establishment_id             IN     NUMBER    DEFAULT null
    ,p_collective_agreement_id      IN     NUMBER    DEFAULT null
    ,p_cagr_id_flex_num             IN     NUMBER    DEFAULT null
    ,p_cag_segment1                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment2                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment3                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment4                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment5                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment6                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment7                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment8                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment9                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment10                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment11                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment12                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment13                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment14                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment15                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment16                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment17                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment18                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment19                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment20                IN     VARCHAR2  DEFAULT null
    ,p_notice_period                IN     NUMBER   DEFAULT null
    ,p_notice_period_uom            IN     VARCHAR2  DEFAULT null
    ,p_employee_category            IN     VARCHAR2   DEFAULT null
    ,p_work_at_home                 IN     VARCHAR2   DEFAULT null
    ,p_job_post_source_name         IN     VARCHAR2   DEFAULT null
    ,p_grade_ladder_pgm_id          in     number
    ,p_supervisor_assignment_id     in     number
    ,p_group_name                   OUT    NOCOPY VARCHAR2
    ,p_concatenated_segments        OUT    NOCOPY VARCHAR2
    ,p_cagr_grade_def_id            IN     OUT NOCOPY NUMBER
    ,p_cagr_concatenated_segments   OUT    NOCOPY VARCHAR2
    ,p_assignment_id                OUT    NOCOPY NUMBER
    ,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
    ,p_people_group_id              IN OUT NOCOPY NUMBER
    ,p_object_version_number        OUT   NOCOPY NUMBER
    ,p_effective_start_date         OUT   NOCOPY DATE
    ,p_effective_end_date           OUT   NOCOPY DATE
    ,p_assignment_sequence          OUT   NOCOPY NUMBER
    ,p_comment_id                   OUT   NOCOPY NUMBER
    ,p_other_manager_warning        OUT   NOCOPY BOOLEAN
    ,p_hourly_salaried_warning      OUT   NOCOPY BOOLEAN
    ,p_gsp_post_process_warning        out nocopy varchar2) IS

    --
    -- Declare Local Variables
    --
    l_assignment_number per_assignments_f.assignment_number%TYPE;
    l_legislation_code  per_business_groups.legislation_code%TYPE;

    --
    l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
    l_soft_coding_keyflex_id per_assignments_f.soft_coding_keyflex_id%TYPE;

    --
    l_commencing_from varchar2(100);
    l_date_approved   varchar2(100);
    l_date_ending     varchar2(100);
    l_foreigner_tax_expiry varchar2(100);
    --

    p_override_real_si_days1 varchar2(100);
    p_indiv_working_hrs1   varchar2(100);
    p_part_time_percentage1 varchar2(100);
    p_individual_percentage1 varchar2(100);

    l_effective_date DATE;

    --

    -- Cursor Definitions
    --
    CURSOR csr_check_legislation IS
    SELECT NULL
    FROM   per_assignments_f        paf
          ,per_business_groups      pbg
    WHERE  paf.person_id            = p_person_id
    AND    pbg.business_group_id    = paf.business_group_id
    AND    pbg.legislation_code     = 'NL'
    AND    l_effective_date         BETWEEN paf.effective_start_date
                                    AND     paf.effective_end_date;
    --
    --
BEGIN
    --
    l_effective_date := trunc(p_effective_date);
    --

    --
    -- Ensure that the employee is within a NL business group
    --
    OPEN csr_check_legislation;
        FETCH csr_check_legislation INTO l_legislation_code;
        IF  csr_check_legislation%NOTFOUND THEN
            CLOSE csr_check_legislation;
            hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
            hr_utility.set_message_token('LEG_CODE', 'NL');
            hr_utility.raise_error;
        END IF;
    CLOSE csr_check_legislation;
    --



    IF p_commencing_from IS NULL THEN
        l_commencing_from  := NULL;
    ELSE
	l_commencing_from  := FND_DATE.DATE_TO_CANONICAL(p_commencing_from);
    END IF;

    IF p_date_approved IS NULL THEN
        l_date_approved  := NULL;
    ELSE
	l_date_approved  := FND_DATE.DATE_TO_CANONICAL(p_date_approved);
    END IF;

    IF p_date_ending IS NULL THEN
        l_date_ending  := NULL;
    ELSE
	l_date_ending  := FND_DATE.DATE_TO_CANONICAL(p_date_ending);
    END IF;

    IF p_foreigner_tax_expiry IS NULL THEN
        l_foreigner_tax_expiry  := NULL;
    ELSE
	l_foreigner_tax_expiry  := FND_DATE.DATE_TO_CANONICAL(p_foreigner_tax_expiry);
    END IF;

    IF p_override_real_si_days IS NULL THEN
	p_override_real_si_days1  := NULL;
    ELSIF (p_override_real_si_days <> hr_api.g_number) THEN
	p_override_real_si_days1  := FND_NUMBER.NUMBER_TO_CANONICAL(p_override_real_si_days);
    ELSE
        p_override_real_si_days1  := hr_api.g_varchar2 ;
    END IF;

    IF p_indiv_working_hrs IS NULL THEN
	p_indiv_working_hrs1  := NULL;
    ELSIF (p_indiv_working_hrs <> hr_api.g_number) THEN
	p_indiv_working_hrs1  := FND_NUMBER.NUMBER_TO_CANONICAL(p_indiv_working_hrs);
    ELSE
        p_indiv_working_hrs1  := hr_api.g_varchar2 ;
    END IF;

    IF p_part_time_percentage IS NULL THEN
	p_part_time_percentage1  := NULL;
    ELSIF (p_part_time_percentage <> hr_api.g_number) THEN
	p_part_time_percentage1 := FND_NUMBER.NUMBER_TO_CANONICAL(p_part_time_percentage);
    ELSE
        p_part_time_percentage1 := hr_api.g_varchar2 ;
    END IF;

    IF (p_individual_percentage <> hr_api.g_number) THEN
	p_individual_percentage1 := FND_NUMBER.NUMBER_TO_CANONICAL(p_individual_percentage);
    ELSIF p_individual_percentage IS NULL THEN
	p_individual_percentage1  := NULL;
    ELSE
        p_individual_percentage1 := hr_api.g_varchar2 ;
    END IF;

    --
    -- Call create_secondary_emp_asg
    --
    hr_assignment_api.create_secondary_emp_asg
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_person_id                    => p_person_id
        ,p_organization_id              => p_organization_id
        ,p_grade_id                     => p_grade_id
        ,p_position_id                  => p_position_id
        ,p_job_id                       => p_job_id
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_payroll_id                   => p_payroll_id
        ,p_location_id                  => p_location_id
        ,p_supervisor_id                => p_supervisor_id
        ,p_special_ceiling_step_id      => p_special_ceiling_step_id
        ,p_pay_basis_id                 => p_pay_basis_id
        ,p_assignment_number            => p_assignment_number
        ,p_change_reason                => p_change_reason
        ,p_comments                     => p_comments
        ,p_date_probation_end           => p_date_probation_end
        ,p_default_code_comb_id         => p_default_code_comb_id
        ,p_employment_category          => p_employment_category
        ,p_frequency                    => p_frequency
        ,p_internal_address_line        => p_internal_address_line
        ,p_manager_flag                 => p_manager_flag
        ,p_normal_hours                 => p_regular_working_hrs
        ,p_perf_review_period           => p_perf_review_period
        ,p_perf_review_period_frequency => p_perf_review_period_frequency
        ,p_probation_period             => p_probation_period
        ,p_probation_unit               => p_probation_unit
        ,p_sal_review_period            => p_sal_review_period
        ,p_sal_review_period_frequency  => p_sal_review_period_frequency
        ,p_set_of_books_id              => p_set_of_books_id
        ,p_source_type                  => p_source_type
        ,p_time_normal_finish           => p_time_normal_finish
        ,p_time_normal_start            => p_time_normal_start
        ,p_bargaining_unit_code         => p_bargaining_unit_code
        ,p_labour_union_member_flag     => p_labour_union_member_flag
        ,p_hourly_salaried_code         => p_hourly_salaried_code
        ,p_ass_attribute_category       => p_ass_attribute_category
        ,p_ass_attribute1               => p_ass_attribute1
        ,p_ass_attribute2               => p_ass_attribute2
        ,p_ass_attribute3               => p_ass_attribute3
        ,p_ass_attribute4               => p_ass_attribute4
        ,p_ass_attribute5               => p_ass_attribute5
        ,p_ass_attribute6               => p_ass_attribute6
        ,p_ass_attribute7               => p_ass_attribute7
        ,p_ass_attribute8               => p_ass_attribute8
        ,p_ass_attribute9               => p_ass_attribute9
        ,p_ass_attribute10              => p_ass_attribute10
        ,p_ass_attribute11              => p_ass_attribute11
        ,p_ass_attribute12              => p_ass_attribute12
        ,p_ass_attribute13              => p_ass_attribute13
        ,p_ass_attribute14              => p_ass_attribute14
        ,p_ass_attribute15              => p_ass_attribute15
        ,p_ass_attribute16              => p_ass_attribute16
        ,p_ass_attribute17              => p_ass_attribute17
        ,p_ass_attribute18              => p_ass_attribute18
        ,p_ass_attribute19              => p_ass_attribute19
        ,p_ass_attribute20              => p_ass_attribute20
        ,p_ass_attribute21              => p_ass_attribute21
        ,p_ass_attribute22              => p_ass_attribute22
        ,p_ass_attribute23              => p_ass_attribute23
        ,p_ass_attribute24              => p_ass_attribute24
        ,p_ass_attribute25              => p_ass_attribute25
        ,p_ass_attribute26              => p_ass_attribute26
        ,p_ass_attribute27              => p_ass_attribute27
        ,p_ass_attribute28              => p_ass_attribute28
        ,p_ass_attribute29              => p_ass_attribute29
        ,p_ass_attribute30              => p_ass_attribute30
        ,p_title                        => p_title
        ,p_scl_segment1                 => p_incidental_worker
        ,p_scl_segment2                 => p_employment_type
        ,p_scl_segment3                 => p_employment_subtype
        ,p_scl_segment4                 => p_tax_reductions_apply
        ,p_scl_segment5                 => p_paid_parental_leave_apply
        ,p_scl_segment6                 => p_work_pattern
        ,p_scl_segment7                 => p_labour_tax_apply
        ,p_scl_segment8                 => p_income_code
        ,p_scl_segment9                 => p_addl_snr_tax_apply
        ,p_scl_segment10                => p_special_indicators
        ,p_scl_segment11                => p_tax_code
        ,p_scl_segment12                => p_last_year_salary
        ,p_scl_segment13                => p_deviating_working_hours
        ,p_scl_segment14                => p_low_wages_apply
        ,p_scl_segment15                => p_education_apply
        ,p_scl_segment16                => p_anonymous_employee
        ,p_scl_segment17                => p_long_term_unemployed
        ,p_scl_segment18                => p_foreigner_with_spl_knowledge
        ,p_scl_segment19                => p_beneficial_rule_apply
        ,p_scl_segment20                => p_individual_percentage1
        ,p_scl_segment21                => l_commencing_from
        ,p_scl_segment22                => l_date_approved
        ,p_scl_segment23                => l_date_ending
        ,p_scl_segment24                => l_foreigner_tax_expiry
        ,p_scl_segment25                => p_job_level
        ,p_scl_segment26                => p_max_days_method
        ,p_scl_segment27                => p_override_real_si_days1
        ,p_scl_segment28                => p_indiv_working_hrs1
        ,p_scl_segment29                => p_part_time_percentage1
        ,p_scl_segment30                => p_si_special_indicators
        ,p_scl_concat_segments          => p_scl_concat_segments
        ,p_pgp_segment1                 => p_pgp_segment1
	,p_pgp_segment2                 => p_pgp_segment2
	,p_pgp_segment3                 => p_pgp_segment3
	,p_pgp_segment4                 => p_pgp_segment4
	,p_pgp_segment5                 => p_pgp_segment5
	,p_pgp_segment6                 => p_pgp_segment6
	,p_pgp_segment7                 => p_pgp_segment7
	,p_pgp_segment8                 => p_pgp_segment8
	,p_pgp_segment9                 => p_pgp_segment9
	,p_pgp_segment10                => p_pgp_segment10
	,p_pgp_segment11                => p_pgp_segment11
	,p_pgp_segment12                => p_pgp_segment12
	,p_pgp_segment13                => p_pgp_segment13
	,p_pgp_segment14                => p_pgp_segment14
	,p_pgp_segment15                => p_pgp_segment15
	,p_pgp_segment16                => p_pgp_segment16
	,p_pgp_segment17                => p_pgp_segment17
	,p_pgp_segment18                => p_pgp_segment18
	,p_pgp_segment19                => p_pgp_segment19
        ,p_pgp_segment20                => p_pgp_segment20
        ,p_pgp_segment21                => p_pgp_segment21
	,p_pgp_segment22                => p_pgp_segment22
	,p_pgp_segment23                => p_pgp_segment23
	,p_pgp_segment24                => p_pgp_segment24
	,p_pgp_segment25                => p_pgp_segment25
	,p_pgp_segment26                => p_pgp_segment26
	,p_pgp_segment27                => p_pgp_segment27
	,p_pgp_segment28                => p_pgp_segment28
	,p_pgp_segment29                => p_pgp_segment29
	,p_pgp_segment30                => p_pgp_segment30
        ,p_pgp_concat_segments          => p_pgp_concat_segments
        ,p_contract_id                  => p_contract_id
        ,p_establishment_id             => p_establishment_id
        ,p_collective_agreement_id      => p_collective_agreement_id
        ,p_cagr_id_flex_num             => p_cagr_id_flex_num
        ,p_cag_segment1                 => p_cag_segment1
        ,p_cag_segment2                 => p_cag_segment2
        ,p_cag_segment3                 => p_cag_segment3
        ,p_cag_segment4                 => p_cag_segment4
        ,p_cag_segment5                 => p_cag_segment5
        ,p_cag_segment6                 => p_cag_segment6
        ,p_cag_segment7                 => p_cag_segment7
        ,p_cag_segment8                 => p_cag_segment8
        ,p_cag_segment9                 => p_cag_segment9
        ,p_cag_segment10                => p_cag_segment10
        ,p_cag_segment11                => p_cag_segment11
        ,p_cag_segment12                => p_cag_segment12
        ,p_cag_segment13                => p_cag_segment13
        ,p_cag_segment14                => p_cag_segment14
        ,p_cag_segment15                => p_cag_segment15
        ,p_cag_segment16                => p_cag_segment16
        ,p_cag_segment17                => p_cag_segment17
        ,p_cag_segment18                => p_cag_segment18
        ,p_cag_segment19                => p_cag_segment19
        ,p_cag_segment20                => p_cag_segment20
        ,p_notice_period                => p_notice_period
        ,p_notice_period_uom            => p_notice_period_uom
        ,p_employee_category            => p_employee_category
        ,p_work_at_home                 => p_work_at_home
        ,p_job_post_source_name         => p_job_post_source_name
        ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
        ,p_supervisor_assignment_id     => p_supervisor_assignment_id
        ,p_group_name                   => p_group_name
        ,p_concatenated_segments        => p_concatenated_segments
        ,p_cagr_grade_def_id            => p_cagr_grade_def_id
        ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
        ,p_assignment_id                => p_assignment_id
        ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
        ,p_people_group_id              => p_people_group_id
        ,p_object_version_number        => p_object_version_number
        ,p_effective_start_date         => p_effective_start_date
        ,p_effective_end_date           => p_effective_end_date
        ,p_assignment_sequence          => p_assignment_sequence
        ,p_comment_id                   => p_comment_id
        ,p_other_manager_warning        => p_other_manager_warning
        ,p_hourly_salaried_warning      => p_hourly_salaried_warning
        ,p_gsp_post_process_warning     => p_gsp_post_process_warning);

  --
END create_nl_secondary_emp_asg;
--
--------------------------------------------------------------------------------
--  update_nl_emp_asg
--------------------------------------------------------------------------------
--
-- Description:
--   procedure to update employee assignment.
--
-- Prerequisites:
--   The assignment (p_assignment_id) must exist as of the effective date
--   of the update (p_effective_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date                Yes date     The effective start date of
--                                                this assignment
--   p_person_id                     Yes number   The person for whom this
--                                                assigment applies
--   p_assignment_id		     Yes number	  The id of the assignment to be updated
--   p_organization_id               Yes number   Organization
--   p_grade_id                          number   Grade
--   p_position_id                       number   Position
--   p_job_id                            number   Job
--   p_assignment_status_type_id         number   Assigmnent status
--   p_location_id                       number   Location
--   p_supervisor_id                     number   Supervisor
--   p_special_ceiling_step_id           number   Special ceiling step
--   p_pay_basis_id                      number   Salary basis
--   p_assignment_number                 varchar2 Assignment number
--   p_change_reason                     varchar2 Change reason
--   p_comments                          varchar2 Comments
--   p_date_probation_end                date     End date of probation period
--   p_default_code_comb_id              number   Foreign key to
--                                                GL_CODE_COMBINATIONS
--   p_employment_category               varchar2 Employment category
--   p_frequency                         varchar2 Frequency for quoting working hours (eg per week)
--   p_internal_address_line             varchar2 Internal address line
--   p_manager_flag                      varchar2 Indicates whether employee
--                                                is a manager
--   p_regular_working_hours             number   Normal working hours
--   p_perf_review_period                number   Performance review period
--   p_perf_review_period_frequency      varchar2 Units for quoting performance
--                                                review period (eg months)
--   p_probation_period                  number   Length of probation period
--   p_probation_unit                    varchar2 Units for quoting probation period (eg months)
--   p_sal_review_period                 number   Salary review period
--   p_sal_review_period_frequency       varchar2 Units for quoting salary
--                                                review period (eg months)
--   p_set_of_books_id                   number   Set of books (GL)
--   p_source_type                       varchar2 Recruitment activity source
--   p_time_normal_finish                varchar2 Normal work finish time
--   p_time_normal_start                 varchar2 Normal work start time
--   p_bargaining_unit_code              varchar2 Code for bargaining unit
--   p_labour_union_member_flag          varchar2 Indicates whether employee
--                                                is a labour union member
--   p_hourly_salaried_code              varchar2 Hourly or salaried pay code
--   p_ass_attribute_category            varchar2 Descriptive flexfield
--                                                attribute category
--   p_ass_attribute1                    varchar2 Descriptive flexfield
--   p_ass_attribute2                    varchar2 Descriptive flexfield
--   p_ass_attribute3                    varchar2 Descriptive flexfield
--   p_ass_attribute4                    varchar2 Descriptive flexfield
--   p_ass_attribute5                    varchar2 Descriptive flexfield
--   p_ass_attribute6                    varchar2 Descriptive flexfield
--   p_ass_attribute7                    varchar2 Descriptive flexfield
--   p_ass_attribute8                    varchar2 Descriptive flexfield
--   p_ass_attribute9                    varchar2 Descriptive flexfield
--   p_ass_attribute10                   varchar2 Descriptive flexfield
--   p_ass_attribute11                   varchar2 Descriptive flexfield
--   p_ass_attribute12                   varchar2 Descriptive flexfield
--   p_ass_attribute13                   varchar2 Descriptive flexfield
--   p_ass_attribute14                   varchar2 Descriptive flexfield
--   p_ass_attribute15                   varchar2 Descriptive flexfield
--   p_ass_attribute16                   varchar2 Descriptive flexfield
--   p_ass_attribute17                   varchar2 Descriptive flexfield
--   p_ass_attribute18                   varchar2 Descriptive flexfield
--   p_ass_attribute19                   varchar2 Descriptive flexfield
--   p_ass_attribute20                   varchar2 Descriptive flexfield
--   p_ass_attribute21                   varchar2 Descriptive flexfield
--   p_ass_attribute22                   varchar2 Descriptive flexfield
--   p_ass_attribute23                   varchar2 Descriptive flexfield
--   p_ass_attribute24                   varchar2 Descriptive flexfield
--   p_ass_attribute25                   varchar2 Descriptive flexfield
--   p_ass_attribute26                   varchar2 Descriptive flexfield
--   p_ass_attribute27                   varchar2 Descriptive flexfield
--   p_ass_attribute28                   varchar2 Descriptive flexfield
--   p_ass_attribute29                   varchar2 Descriptive flexfield
--   p_ass_attribute30                   varchar2 Descriptive flexfield
--   p_title				 varchar2 Title -must be NULL
--   p_employment_type                   varchar2 Employment Type
--   p_employment_subtype                varchar2 Employment Sub Type
--   p_tax_reductions_apply              varchar2 Tax Reductions Apply
--   p_paid_parental_leave_apply         varchar2 Paid Parental Leave
--   p_work_pattern                      varchar2 Work Pattern
--   p_labour_tax_apply                  varchar2 Labour Tax Reduction
--   p_income_code                       varchar2 Income Code
--   p_addl_snr_tax_apply                varchar2 Additional Sr Tax Reduction
--   p_special_indicators                varchar2 Special Indicators
--Indicates whether an employee's assignment is eligible for certain allowance or not.
--The value being the corresponding Iindicator code(from lookup NL_SPECIAL_INDICATORS)
--The codes for all Special Indicators are concatenated together and stored in this segment.
--If the user has selected Special Indicators 01, 28 and 41,
--then this segment would have the value '012841' stored in it.
--A maximum of 13 indicators can be specified
--   p_tax_code                          varchar2 Tax Code
--   p_last_year_salary                  varchar2 Last Years Salary
--   p_low_wages_apply                   varchar2 Low Wages
--   p_education_apply                   varchar2 Education
--   p_child_day_care_apply              varchar2 Child Day Care
--   p_anonymous_employee                varchar2 Anonymous Employee
--   p_long_term_unemployed              varchar2 Long Term Unemployed
--   p_foreigner_with_spl_knowledge      varchar2 Foreigner with Sp Knowledge
--   p_beneficial_rule_apply             varchar2 Use Beneficial Rule
--   p_individual_percentage             number   Individual Percentage
--   p_commencing_from                   date     Commencing From
--   p_date_approved                     date     Date Approved
--   p_date_ending                       date     Date Ending
--   p_foreigner_tax_expiry              date     Foreigner Tax Expiry
--   p_job_level                         varchar2 Job Level
--   p_max_days_method                   varchar2 Maximum Days Method
--   p_override_real_si_days             number   Override Real SI Days
--   p_indiv_working_hrs                 number   Individual Working Hours
--   p_part_time_percentage              number   Part time percentage
--   p_si_special_indicators             varchar2 SI Special Indicators
--   p_deviating_working_hours           varchar2 Reasons for deviating Working hours
--   p_incidental_worker                 varchar2 Incidental Worker Flag
--   p_scl_concat_segments               varchar2 Concatenated scl segments
--   p_pgp_segment1                      varchar2 People group segment
--   p_pgp_segment2                      varchar2 People group segment
--   p_pgp_segment3                      varchar2 People group segment
--   p_pgp_segment4                      varchar2 People group segment
--   p_pgp_segment5                      varchar2 People group segment
--   p_pgp_segment6                      varchar2 People group segment
--   p_pgp_segment7                      varchar2 People group segment
--   p_pgp_segment8                      varchar2 People group segment
--   p_pgp_segment9                      varchar2 People group segment
--   p_pgp_segment10                     varchar2 People group segment
--   p_pgp_segment11                     varchar2 People group segment
--   p_pgp_segment12                     varchar2 People group segment
--   p_pgp_segment13                     varchar2 People group segment
--   p_pgp_segment14                     varchar2 People group segment
--   p_pgp_segment15                     varchar2 People group segment
--   p_pgp_segment16                     varchar2 People group segment
--   p_pgp_segment17                     varchar2 People group segment
--   p_pgp_segment18                     varchar2 People group segment
--   p_pgp_segment19                     varchar2 People group segment
--   p_pgp_segment20                     varchar2 People group segment
--   p_pgp_segment21                     varchar2 People group segment
--   p_pgp_segment22                     varchar2 People group segment
--   p_pgp_segment23                     varchar2 People group segment
--   p_pgp_segment24                     varchar2 People group segment
--   p_pgp_segment25                     varchar2 People group segment
--   p_pgp_segment26                     varchar2 People group segment
--   p_pgp_segment27                     varchar2 People group segment
--   p_pgp_segment28                     varchar2 People group segment
--   p_pgp_segment29                     varchar2 People group segment
--   p_pgp_segment30                     varchar2 People group segment
--   p_contract_id                       number   contract
--   p_establishment_id                  number   establishment
--   p_collective_agreement_id           number   collective_agreement
--   p_cagr_id_flex_num                  number   collective_Agreement
--                                                 grade structure
--   p_cag_segment1                      varchar2 Collective agreement grade
--   p_cag_segment2                      varchar2 Collective agreement grade
--   p_cag_segment3                      varchar2 Collective agreement grade
--   p_cag_segment4                      varchar2 Collective agreement grade
--   p_cag_segment5                      varchar2 Collective agreement grade
--   p_cag_segment6                      varchar2 Collective agreement grade
--   p_cag_segment7                      varchar2 Collective agreement grade
--   p_cag_segment8                      varchar2 Collective agreement grade
--   p_cag_segment9                      varchar2 Collective agreement grade
--   p_cag_segment10                     varchar2 Collective agreement grade
--   p_cag_segment11                     varchar2 Collective agreement grade
--   p_cag_segment12                     varchar2 Collective agreement grade
--   p_cag_segment13                     varchar2 Collective agreement grade
--   p_cag_segment14                     varchar2 Collective agreement grade
--   p_cag_segment15                     varchar2 Collective agreement grade
--   p_cag_segment16                     varchar2 Collective agreement grade
--   p_cag_segment17                     varchar2 Collective agreement grade
--   p_cag_segment18                     varchar2 Collective agreement grade
--   p_cag_segment19                     varchar2 Collective agreement grade
--   p_cag_segment20                     varchar2 Collective agreement grade
--   p_notice_period                     number   Notice Period
--   p_notice_period_uom                 varchar2 Notice Period Units
--   p_employee_category                 varchar2 Employee Category
--   p_work_at_home                      varchar2 Work At Home
--   p_job_post_source_name		 varchar2 Job Source
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   New version number of the
--                                           assignment
--   p_soft_coding_keyflex_id       number   If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the id
--                                           of the corresponding soft coding
--                                           keyflex row.  If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.
--   p_comment_id                   number   If p_validate is false and any
--                                           comment text exists, set to the id
--                                           of the corresponding person
--                                           comment row.  If p_validate is
--                                           true, or no comment text exists
--                                           this will be null.
--   p_effective_start_date         date     The effective start date for the
--                                           assignment changes
--   p_effective_end_date           date     The effective end date for the
--                                           assignment changes
--   p_concatenated_segments        varchar2 If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the concatenation
--                                           of all p_segment parameters with
--                                           set text. If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.
--
--  p_gsp_post_process_warning      varchar2 Set to a warning message name
--                                           from pqh_gsp_post_process.

-- Post Failure:
--   The API does not update the assignment and raises an error.
--
--

PROCEDURE update_nl_emp_asg
    (p_validate                     IN     BOOLEAN     default false
    ,p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    ,p_datetrack_update_mode        IN     VARCHAR2
    ,p_assignment_id                IN     NUMBER
    ,p_object_version_number        IN OUT NOCOPY NUMBER
    ,p_supervisor_id                IN     NUMBER       default hr_api.g_number
    ,p_assignment_number            IN     VARCHAR2     default hr_api.g_varchar2
    ,p_change_reason                IN     VARCHAR2     default hr_api.g_varchar2
    ,p_assignment_status_type_id    IN     NUMBER       default hr_api.g_number
    ,p_comments                     IN     VARCHAR2     default hr_api.g_varchar2
    ,p_date_probation_end           IN     DATE         default hr_api.g_date
    ,p_default_code_comb_id         IN     NUMBER       default hr_api.g_number
    ,p_frequency                    IN     VARCHAR2     default hr_api.g_varchar2
    ,p_internal_address_line        IN     VARCHAR2     default hr_api.g_varchar2
    ,p_manager_flag                 IN     VARCHAR2     default hr_api.g_varchar2
    ,p_regular_working_hrs          IN     NUMBER       default hr_api.g_number
    ,p_perf_review_period           IN     NUMBER       default hr_api.g_number
    ,p_perf_review_period_frequency IN     VARCHAR2     default hr_api.g_varchar2
    ,p_probation_period             IN     NUMBER       default hr_api.g_number
    ,p_probation_unit               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_sal_review_period            IN     NUMBER       default hr_api.g_number
    ,p_sal_review_period_frequency  IN     VARCHAR2     default hr_api.g_varchar2
    ,p_set_of_books_id              IN     NUMBER       default hr_api.g_number
    ,p_source_type                  IN     VARCHAR2     default hr_api.g_varchar2
    ,p_time_normal_finish           IN     VARCHAR2     default hr_api.g_varchar2
    ,p_time_normal_start            IN     VARCHAR2     default hr_api.g_varchar2
    ,p_bargaining_unit_code         IN     VARCHAR2     default hr_api.g_varchar2
    ,p_labour_union_member_flag     IN     VARCHAR2     default hr_api.g_varchar2
    ,p_hourly_salaried_code         IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute_category       IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute1               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute2               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute3               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute4               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute5               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute6               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute7               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute8               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute9               IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute10              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute11              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute12              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute13              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute14              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute15              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute16              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute17              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute18              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute19              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute20              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute21              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute22              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute23              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute24              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute25              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute26              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute27              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute28              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute29              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_ass_attribute30              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_title                        IN     VARCHAR2     default hr_api.g_varchar2
    ,p_employment_type              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_employment_subtype           IN     VARCHAR2     default hr_api.g_varchar2
    ,p_tax_reductions_apply         IN     VARCHAR2     default hr_api.g_varchar2
    ,p_paid_parental_leave_apply    IN     VARCHAR2     default hr_api.g_varchar2
    ,p_work_pattern                 IN     VARCHAR2     default hr_api.g_varchar2
    ,p_labour_tax_apply             IN     VARCHAR2     default hr_api.g_varchar2
    ,p_income_code                  IN     VARCHAR2     default hr_api.g_varchar2
    ,p_addl_snr_tax_apply           IN     VARCHAR2     default hr_api.g_varchar2
    ,p_special_indicators           IN     VARCHAR2     default hr_api.g_varchar2
    ,p_tax_code                     IN     VARCHAR2     default hr_api.g_varchar2
    ,p_last_year_salary             IN     VARCHAR2     default hr_api.g_varchar2
    ,p_low_wages_apply              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_education_apply              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_child_day_care_apply         IN     VARCHAR2     default hr_api.g_varchar2
    ,p_anonymous_employee           IN     VARCHAR2     default hr_api.g_varchar2
    ,p_long_term_unemployed         IN     VARCHAR2     default hr_api.g_varchar2
    ,p_foreigner_with_spl_knowledge IN     VARCHAR2     default hr_api.g_varchar2
    ,p_beneficial_rule_apply        IN     VARCHAR2     default hr_api.g_varchar2
    ,p_individual_percentage        IN     NUMBER       default hr_api.g_number
    ,p_commencing_from              IN     DATE         default hr_api.g_date
    ,p_date_approved                IN     DATE         default hr_api.g_date
    ,p_date_ending                  IN     DATE         default hr_api.g_date
    ,p_foreigner_tax_expiry         IN     DATE         default hr_api.g_date
    ,p_job_level                    IN     VARCHAR2     default hr_api.g_varchar2
    ,p_max_days_method              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_override_real_si_days        IN     NUMBER       default hr_api.g_number
    ,p_indiv_working_hrs            IN     NUMBER       default hr_api.g_number
    ,p_part_time_percentage         IN     NUMBER       default hr_api.g_number
    ,p_si_special_indicators	    IN     VARCHAR2     default hr_api.g_varchar2
    ,p_deviating_working_hours      IN     VARCHAR2     default hr_api.g_varchar2
    ,p_incidental_worker     	    IN     VARCHAR2     default hr_api.g_varchar2
    ,p_concat_segments              IN     VARCHAR2     default hr_api.g_varchar2
    ,p_contract_id                  IN     NUMBER       DEFAULT   hr_api.g_number
    ,p_establishment_id             IN     NUMBER       DEFAULT   hr_api.g_number
    ,p_collective_agreement_id      IN     NUMBER       DEFAULT   hr_api.g_number
    ,p_cagr_id_flex_num             IN     NUMBER       DEFAULT   hr_api.g_number
    ,p_cag_segment1                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment2                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment3                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment4                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment5                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment6                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment7                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment8                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment9                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment10                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment11                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment12                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment13                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment14                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment15                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment16                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment17                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment18                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment19                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cag_segment20                IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_notice_period                IN     NUMBER       DEFAULT   hr_api.g_number
    ,p_notice_period_uom            IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_employee_category            IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_work_at_home                 IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_job_post_source_name         IN     VARCHAR2     DEFAULT   hr_api.g_varchar2
    ,p_cagr_grade_def_id            IN OUT NOCOPY NUMBER
    ,p_cagr_concatenated_segments      OUT NOCOPY VARCHAR2
    ,p_concatenated_segments           OUT NOCOPY VARCHAR2
    ,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
    ,p_comment_id                      OUT NOCOPY NUMBER
    ,p_effective_start_date            OUT NOCOPY DATE
    ,p_effective_end_date              OUT NOCOPY DATE
    ,p_no_managers_warning             OUT NOCOPY BOOLEAN
    ,p_other_manager_warning           OUT NOCOPY BOOLEAN
    ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
    ,p_gsp_post_process_warning        out nocopy varchar2) IS
    --
    -- Declare cursors and local variables
    --
    l_soft_coding_keyflex_id     per_assignments_f.soft_coding_keyflex_id%TYPE;
    l_concatenated_segments      varchar2(2000);
    l_legislation_code           per_business_groups.legislation_code%TYPE;
    l_effective_date             DATE;
    --

    p_override_real_si_days1 varchar2(100);
    p_indiv_working_hrs1   varchar2(100);
    p_part_time_percentage1 varchar2(100);
    p_individual_percentage1 varchar2(100);

    CURSOR csr_check_legislation
        (c_assignment_id  per_assignments_f.assignment_id%TYPE
        ,c_effective_date DATE) IS
    SELECT bgp.legislation_code
    FROM   per_assignments_f asg
        ,per_business_groups bgp
    WHERE  asg.business_group_id = bgp.business_group_id
    AND    asg.assignment_id     = c_assignment_id
    AND    c_effective_date      BETWEEN effective_start_date
                               AND     effective_end_date;
    --
    --
    l_commencing_from varchar2(100);
    l_date_approved   varchar2(100);
    l_date_ending     varchar2(100);
    l_foreigner_tax_expiry varchar2(100);
    --

BEGIN
    --
    -- Truncate date variables
    --
    l_effective_date := trunc(p_effective_date);
    --
    --
    -- Check that the assignment exists.
    --
    OPEN csr_check_legislation(p_assignment_id, l_effective_date);
      FETCH csr_check_legislation INTO l_legislation_code;
      IF  csr_check_legislation%NOTFOUND THEN
          CLOSE csr_check_legislation;
          hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
          hr_utility.raise_error;
      END IF;
    CLOSE csr_check_legislation;
    --
    -- Check that the legislation of the specified business group is 'NL'.
    --
    IF  l_legislation_code <> 'NL' then
        hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
        hr_utility.set_message_token('LEG_CODE','NL');
        hr_utility.raise_error;
    END IF;
    --

    IF p_commencing_from IS NULL THEN
        l_commencing_from  := NULL;
    ELSIF (p_commencing_from <> hr_api.g_date) THEN
	l_commencing_from  := FND_DATE.DATE_TO_CANONICAL(p_commencing_from);
    ELSE
        l_commencing_from  := hr_api.g_varchar2 ;
    END IF;

    IF p_date_approved IS NULL THEN
        l_date_approved  := NULL;
    ELSIF (p_date_approved <> hr_api.g_date) THEN
	l_date_approved  := FND_DATE.DATE_TO_CANONICAL(p_date_approved);
    ELSE
        l_date_approved  := hr_api.g_varchar2 ;
    END IF;

    IF p_date_ending IS NULL THEN
        l_date_ending  := NULL;
    ELSIF (p_date_ending <> hr_api.g_date) THEN
	l_date_ending  := FND_DATE.DATE_TO_CANONICAL(p_date_ending);
    ELSE
        l_date_ending  := hr_api.g_varchar2 ;
    END IF;

    IF p_foreigner_tax_expiry IS NULL THEN
        l_foreigner_tax_expiry  := NULL;
    ELSIF (p_foreigner_tax_expiry <> hr_api.g_date) THEN
	l_foreigner_tax_expiry  := FND_DATE.DATE_TO_CANONICAL(p_foreigner_tax_expiry);
    ELSE
        l_foreigner_tax_expiry  := hr_api.g_varchar2 ;
    END IF;


    IF p_override_real_si_days IS NULL THEN
        p_override_real_si_days1  := NULL;
    ELSIF (p_override_real_si_days <> hr_api.g_number) THEN
	p_override_real_si_days1  := FND_NUMBER.NUMBER_TO_CANONICAL(p_override_real_si_days);
    ELSE
        p_override_real_si_days1  := hr_api.g_varchar2 ;
    END IF;

    IF p_indiv_working_hrs IS NULL THEN
        p_indiv_working_hrs1  := NULL;
    ELSIF (p_indiv_working_hrs <> hr_api.g_number) THEN
	p_indiv_working_hrs1  := FND_NUMBER.NUMBER_TO_CANONICAL(p_indiv_working_hrs);
    ELSE
        p_indiv_working_hrs1  := hr_api.g_varchar2 ;
    END IF;

    IF p_part_time_percentage IS NULL THEN
        p_part_time_percentage1  := NULL;
    ELSIF (p_part_time_percentage <> hr_api.g_number) THEN
	p_part_time_percentage1 := FND_NUMBER.NUMBER_TO_CANONICAL(p_part_time_percentage);
    ELSE
        p_part_time_percentage1 := hr_api.g_varchar2 ;
    END IF;

    IF p_individual_percentage IS NULL THEN
        p_individual_percentage1  := NULL;
    ELSIF (p_individual_percentage <> hr_api.g_number) THEN
	p_individual_percentage1 := FND_NUMBER.NUMBER_TO_CANONICAL(p_individual_percentage);
    ELSE
        p_individual_percentage1 := hr_api.g_varchar2 ;
    END IF;

    --
    -- Call update_emp_asg business process
    --
    hr_assignment_api.update_emp_asg
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => p_object_version_number
        ,p_supervisor_id                => p_supervisor_id
        ,p_assignment_number            => p_assignment_number
        ,p_change_reason                => p_change_reason
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_comments                     => p_comments
        ,p_date_probation_end           => p_date_probation_end
        ,p_default_code_comb_id         => p_default_code_comb_id
        ,p_frequency                    => p_frequency
        ,p_internal_address_line        => p_internal_address_line
        ,p_manager_flag                 => p_manager_flag
        ,p_normal_hours                 => p_regular_working_hrs
        ,p_perf_review_period           => p_perf_review_period
        ,p_perf_review_period_frequency => p_perf_review_period_frequency
        ,p_probation_period             => p_probation_period
        ,p_probation_unit               => p_probation_unit
        ,p_sal_review_period            => p_sal_review_period
        ,p_sal_review_period_frequency  => p_sal_review_period_frequency
        ,p_set_of_books_id              => p_set_of_books_id
        ,p_source_type                  => p_source_type
        ,p_time_normal_finish           => p_time_normal_finish
        ,p_time_normal_start            => p_time_normal_start
        ,p_bargaining_unit_code         => p_bargaining_unit_code
        ,p_labour_union_member_flag     => p_labour_union_member_flag
        ,p_hourly_salaried_code         => p_hourly_salaried_code
        ,p_ass_attribute_category       => p_ass_attribute_category
        ,p_ass_attribute1               => p_ass_attribute1
        ,p_ass_attribute2               => p_ass_attribute2
        ,p_ass_attribute3               => p_ass_attribute3
        ,p_ass_attribute4               => p_ass_attribute4
        ,p_ass_attribute5               => p_ass_attribute5
        ,p_ass_attribute6               => p_ass_attribute6
        ,p_ass_attribute7               => p_ass_attribute7
        ,p_ass_attribute8               => p_ass_attribute8
        ,p_ass_attribute9               => p_ass_attribute9
        ,p_ass_attribute10              => p_ass_attribute10
        ,p_ass_attribute11              => p_ass_attribute11
        ,p_ass_attribute12              => p_ass_attribute12
        ,p_ass_attribute13              => p_ass_attribute13
        ,p_ass_attribute14              => p_ass_attribute14
        ,p_ass_attribute15              => p_ass_attribute15
        ,p_ass_attribute16              => p_ass_attribute16
        ,p_ass_attribute17              => p_ass_attribute17
        ,p_ass_attribute18              => p_ass_attribute18
        ,p_ass_attribute19              => p_ass_attribute19
        ,p_ass_attribute20              => p_ass_attribute20
        ,p_ass_attribute21              => p_ass_attribute21
        ,p_ass_attribute22              => p_ass_attribute22
        ,p_ass_attribute23              => p_ass_attribute23
        ,p_ass_attribute24              => p_ass_attribute24
        ,p_ass_attribute25              => p_ass_attribute25
        ,p_ass_attribute26              => p_ass_attribute26
        ,p_ass_attribute27              => p_ass_attribute27
        ,p_ass_attribute28              => p_ass_attribute28
        ,p_ass_attribute29              => p_ass_attribute29
        ,p_ass_attribute30              => p_ass_attribute30
        ,p_title                        => p_title
        ,p_segment1                     => p_incidental_worker
        ,p_segment2                 	=> p_employment_type
        ,p_segment3                 	=> p_employment_subtype
        ,p_segment4                 	=> p_tax_reductions_apply
        ,p_segment5                 	=> p_paid_parental_leave_apply
        ,p_segment6                 	=> p_work_pattern
        ,p_segment7                 	=> p_labour_tax_apply
        ,p_segment8                 	=> p_income_code
        ,p_segment9                 	=> p_addl_snr_tax_apply
        ,p_segment10                	=> p_special_indicators
        ,p_segment11                	=> p_tax_code
        ,p_segment12                	=> p_last_year_salary
        ,p_segment13               	=> p_deviating_working_hours
        ,p_segment14               	=> p_low_wages_apply
        ,p_segment15                	=> p_education_apply
        ,p_segment16                	=> p_anonymous_employee
        ,p_segment17               	=> p_long_term_unemployed
        ,p_segment18                	=> p_foreigner_with_spl_knowledge
        ,p_segment19                	=> p_beneficial_rule_apply
        ,p_segment20                	=> p_individual_percentage1
        ,p_segment21                	=> l_commencing_from
        ,p_segment22                	=> l_date_approved
        ,p_segment23                	=> l_date_ending
        ,p_segment24                	=> l_foreigner_tax_expiry
        ,p_segment25                	=> p_job_level
        ,p_segment26                	=> p_max_days_method
        ,p_segment27                	=> p_override_real_si_days1
        ,p_segment28                	=> p_indiv_working_hrs1
        ,p_segment29                	=> p_part_time_percentage1
        ,p_segment30                    => p_si_special_indicators
        ,p_concat_segments              => p_concat_segments
        ,p_contract_id                  => p_contract_id
        ,p_establishment_id             => p_establishment_id
        ,p_collective_agreement_id      => p_collective_agreement_id
        ,p_cagr_id_flex_num             => p_cagr_id_flex_num
        ,p_cag_segment1                 => p_cag_segment1
        ,p_cag_segment2                 => p_cag_segment2
        ,p_cag_segment3                 => p_cag_segment3
        ,p_cag_segment4                 => p_cag_segment4
        ,p_cag_segment5                 => p_cag_segment5
        ,p_cag_segment6                 => p_cag_segment6
        ,p_cag_segment7                 => p_cag_segment7
        ,p_cag_segment8                 => p_cag_segment8
        ,p_cag_segment9                 => p_cag_segment9
        ,p_cag_segment10                => p_cag_segment10
        ,p_cag_segment11                => p_cag_segment11
        ,p_cag_segment12                => p_cag_segment12
        ,p_cag_segment13                => p_cag_segment13
        ,p_cag_segment14                => p_cag_segment14
        ,p_cag_segment15                => p_cag_segment15
        ,p_cag_segment16                => p_cag_segment16
        ,p_cag_segment17                => p_cag_segment17
        ,p_cag_segment18                => p_cag_segment18
        ,p_cag_segment19                => p_cag_segment19
        ,p_cag_segment20                => p_cag_segment20
        ,p_notice_period                => p_notice_period
        ,p_notice_period_uom	      	=> p_notice_period_uom
        ,p_employee_category	        => p_employee_category
        ,p_work_at_home                 => p_work_at_home
        ,p_job_post_source_name         => p_job_post_source_name
        ,p_cagr_grade_def_id            => p_cagr_grade_def_id
        ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
        ,p_concatenated_segments        => p_concatenated_segments
        ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
        ,p_comment_id                   => p_comment_id
        ,p_effective_start_date         => p_effective_start_date
        ,p_effective_end_date           => p_effective_end_date
        ,p_no_managers_warning          => p_no_managers_warning
        ,p_other_manager_warning        => p_other_manager_warning
        ,p_hourly_salaried_warning      => p_hourly_salaried_warning
        ,p_gsp_post_process_warning    =>  p_gsp_post_process_warning);

  --
  END update_nl_emp_asg;
--
END hr_nl_assignment_api;

/
