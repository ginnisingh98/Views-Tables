--------------------------------------------------------
--  DDL for Package Body HR_SG_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SG_ASSIGNMENT_API" as
/* $Header: hrsgwras.pkb 115.3 2002/12/03 06:05:17 apunekar ship $ */

g_package  varchar2(33) := 'hr_sg_assignment_api.';

PROCEDURE create_sg_secondary_emp_asg
 (p_validate                         in        boolean    default false
 ,p_effective_date                   in	       date
 ,p_person_id                        in	       number
 ,p_organization_id                  in	       number
 ,p_grade_id                         in        number     default null
 ,p_position_id                      in        number     default null
 ,p_job_id                           in        number     default null
 ,p_assignment_status_type_id        in        number     default null
 ,p_payroll_id                       in        number     default null
 ,p_location_id                      in        number     default null
 ,p_supervisor_id                    in        number     default null
 ,p_special_ceiling_step_id          in        number     default null
 ,p_pay_basis_id                     in        number     default null
 ,p_assignment_number                in out    nocopy varchar2
 ,p_change_reason                    in        varchar2   default null
 ,p_comments                         in        varchar2   default null
 ,p_date_probation_end               in        date       default null
 ,p_default_code_comb_id             in        number     default null
 ,p_employment_category              in        varchar2   default null
 ,p_frequency                        in        varchar2   default null
 ,p_internal_address_line            in        varchar2   default null
 ,p_manager_flag                     in        varchar2   default null
 ,p_normal_hours                     in        number     default null
 ,p_perf_review_period               in        number     default null
 ,p_perf_review_period_frequency     in        varchar2   default null
 ,p_probation_period                 in        number     default null
 ,p_probation_unit                   in        varchar2   default null
 ,p_sal_review_period                in        number     default null
 ,p_sal_review_period_frequency      in        varchar2   default null
 ,p_set_of_books_id                  in        number     default null
 ,p_source_type                      in        varchar2   default null
 ,p_time_normal_finish               in        varchar2   default null
 ,p_time_normal_start                in        varchar2   default null
 ,p_bargaining_unit_code             in        varchar2   default null
 ,p_labour_union_member_flag         in        varchar2   default null
 ,p_hourly_salaried_code             in        varchar2   default null
 ,p_ass_attribute_category           in        varchar2   default null
 ,p_ass_attribute1                   in        varchar2   default null
 ,p_ass_attribute2                   in        varchar2   default null
 ,p_ass_attribute3                   in        varchar2   default null
 ,p_ass_attribute4                   in        varchar2   default null
 ,p_ass_attribute5                   in        varchar2   default null
 ,p_ass_attribute6                   in        varchar2   default null
 ,p_ass_attribute7                   in        varchar2   default null
 ,p_ass_attribute8                   in        varchar2   default null
 ,p_ass_attribute9                   in        varchar2   default null
 ,p_ass_attribute10                  in        varchar2   default null
 ,p_ass_attribute11                  in        varchar2   default null
 ,p_ass_attribute12                  in        varchar2   default null
 ,p_ass_attribute13                  in        varchar2   default null
 ,p_ass_attribute14                  in        varchar2   default null
 ,p_ass_attribute15                  in        varchar2   default null
 ,p_ass_attribute16                  in        varchar2   default null
 ,p_ass_attribute17                  in        varchar2   default null
 ,p_ass_attribute18                  in        varchar2   default null
 ,p_ass_attribute19                  in        varchar2   default null
 ,p_ass_attribute20                  in        varchar2   default null
 ,p_ass_attribute21                  in        varchar2   default null
 ,p_ass_attribute22                  in        varchar2   default null
 ,p_ass_attribute23                  in        varchar2   default null
 ,p_ass_attribute24                  in        varchar2   default null
 ,p_ass_attribute25                  in        varchar2   default null
 ,p_ass_attribute26                  in        varchar2   default null
 ,p_ass_attribute27                  in        varchar2   default null
 ,p_ass_attribute28                  in        varchar2   default null
 ,p_ass_attribute29                  in        varchar2   default null
 ,p_ass_attribute30                  in        varchar2   default null
 ,p_title                            in        varchar2   default null
 ,p_legal_employer_id                in        varchar2   default null
 ,p_contract_id                      in        number     default null
 ,p_establishment_id                 in        number     default null
 ,p_collective_agreement_id          in        number     default null
 ,p_cagr_id_flex_num                 in        number     default null
 ,p_cag_segment1                     in        varchar2   default null
 ,p_cag_segment2                     in        varchar2   default null
 ,p_cag_segment3                     in        varchar2   default null
 ,p_cag_segment4                     in        varchar2   default null
 ,p_cag_segment5                     in        varchar2   default null
 ,p_cag_segment6                     in        varchar2   default null
 ,p_cag_segment7                     in        varchar2   default null
 ,p_cag_segment8                     in        varchar2   default null
 ,p_cag_segment9                     in        varchar2   default null
 ,p_cag_segment10                    in        varchar2   default null
 ,p_cag_segment11                    in        varchar2   default null
 ,p_cag_segment12                    in        varchar2   default null
 ,p_cag_segment13                    in        varchar2   default null
 ,p_cag_segment14                    in        varchar2   default null
 ,p_cag_segment15                    in        varchar2   default null
 ,p_cag_segment16                    in        varchar2   default null
 ,p_cag_segment17                    in        varchar2   default null
 ,p_cag_segment18                    in        varchar2   default null
 ,p_cag_segment19                    in        varchar2   default null
 ,p_cag_segment20                    in        varchar2   default null
 ,p_group_name                       out       nocopy varchar2
 ,p_concatenated_segments            out       nocopy varchar2
 ,p_cagr_grade_def_id                out       nocopy number
 ,p_cagr_concatenated_segments       out       nocopy varchar2
 ,p_assignment_id                    out       nocopy number
 ,p_soft_coding_keyflex_id           out       nocopy number
 ,p_people_group_id                  out       nocopy number
 ,p_object_version_number            out       nocopy number
 ,p_effective_start_date             out       nocopy date
 ,p_effective_end_date               out       nocopy date
 ,p_assignment_sequence              out       nocopy number
 ,p_comment_id                       out       nocopy number
 ,p_other_manager_warning            out       nocopy boolean)
 IS
--
  -- Declare cursors AND local variables
  --
  -- Declare variables
  --
  l_assignment_number  per_assignments_f.assignment_number%TYPE;
  l_effective_date     DATE;
  --
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               VARCHAR2(72) := g_package||'create_sg_secondary_emp_asg';
  --
  -- Declare cursors
  --
  CURSOR csr_legislation IS
    SELECT  NULL
    FROM    per_assignments_f paf,
            per_business_groups pbg
    WHERE   paf.person_id = p_person_id
    AND     l_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND     pbg.business_group_id = paf.business_group_id
    AND     pbg.legislation_code = 'SG';
  --
  --
 Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation IN addition to Table Handlers
  --
  -- Ensure that the employee IS within a sg business group
  --
  OPEN  csr_legislation;
  FETCH csr_legislation
  INTO l_legislation_code;
  IF csr_legislation%notfound THEN
    CLOSE csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'SG');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_legislation;
  --
  --
  -- Call create_secondary_emp_asg
  --

      hr_assignment_api.create_secondary_emp_asg
      (p_validate			 =>	p_validate
      ,p_effective_date		         =>	p_effective_date
      ,p_person_id			 =>	p_person_id
      ,p_organization_id		 =>	p_organization_id
      ,p_grade_id			 =>	p_grade_id
      ,p_position_id			 =>	p_position_id
      ,p_job_id			         =>	p_job_id
      ,p_assignment_status_type_id	 =>	p_assignment_status_type_id
      ,p_payroll_id			 =>	p_payroll_id
      ,p_location_id			 =>	p_location_id
      ,p_supervisor_id		         =>	p_supervisor_id
      ,p_special_ceiling_step_id         =>	p_special_ceiling_step_id
      ,p_pay_basis_id		         =>	p_pay_basis_id
      ,p_assignment_number		 =>	p_assignment_number
      ,p_change_reason		         =>	p_change_reason
      ,p_comments			 =>	p_comments
      ,p_date_probation_end		 =>	p_date_probation_end
      ,p_default_code_comb_id	         =>	p_default_code_comb_id
      ,p_employment_category		 =>	p_employment_category
      ,p_frequency			 =>	p_frequency
      ,p_internal_address_line		 =>	p_internal_address_line
      ,p_manager_flag		         =>	p_manager_flag
      ,p_normal_hours		         =>	p_normal_hours
      ,p_perf_review_period		 =>	p_perf_review_period
      ,p_perf_review_period_frequency    =>	p_perf_review_period_frequency
      ,p_probation_period		 =>	p_probation_period
      ,p_probation_unit		         =>	p_probation_unit
      ,p_sal_review_period		 =>	p_sal_review_period
      ,p_sal_review_period_frequency	 =>	p_sal_review_period_frequency
      ,p_set_of_books_id		 =>	p_set_of_books_id
      ,p_source_type			 =>	p_source_type
      ,p_time_normal_finish		 =>	p_time_normal_finish
      ,p_time_normal_start		 =>	p_time_normal_start
      ,p_bargaining_unit_code		 =>	p_bargaining_unit_code
      ,p_labour_union_member_flag	 =>	p_labour_union_member_flag
      ,p_hourly_salaried_code	         =>	p_hourly_salaried_code
      ,p_ass_attribute_category	         =>	p_ass_attribute_category
      ,p_ass_attribute1		         =>	p_ass_attribute1
      ,p_ass_attribute2		         =>	p_ass_attribute2
      ,p_ass_attribute3		         =>	p_ass_attribute3
      ,p_ass_attribute4		         =>	p_ass_attribute4
      ,p_ass_attribute5		         =>	p_ass_attribute5
      ,p_ass_attribute6		         =>	p_ass_attribute6
      ,p_ass_attribute7		         =>	p_ass_attribute7
      ,p_ass_attribute8		         =>	p_ass_attribute8
      ,p_ass_attribute9		         =>	p_ass_attribute9
      ,p_ass_attribute10		 =>	p_ass_attribute10
      ,p_ass_attribute11		 =>	p_ass_attribute11
      ,p_ass_attribute12		 =>	p_ass_attribute12
      ,p_ass_attribute13		 =>	p_ass_attribute13
      ,p_ass_attribute14		 =>	p_ass_attribute14
      ,p_ass_attribute15		 =>	p_ass_attribute15
      ,p_ass_attribute16		 =>	p_ass_attribute16
      ,p_ass_attribute17		 =>	p_ass_attribute17
      ,p_ass_attribute18		 =>	p_ass_attribute18
      ,p_ass_attribute19		 =>	p_ass_attribute19
      ,p_ass_attribute20		 =>	p_ass_attribute20
      ,p_ass_attribute21		 =>	p_ass_attribute21
      ,p_ass_attribute22		 =>	p_ass_attribute22
      ,p_ass_attribute23		 =>	p_ass_attribute23
      ,p_ass_attribute24		 =>	p_ass_attribute24
      ,p_ass_attribute25		 =>	p_ass_attribute25
      ,p_ass_attribute26		 =>	p_ass_attribute26
      ,p_ass_attribute27		 =>	p_ass_attribute27
      ,p_ass_attribute28		 =>	p_ass_attribute28
      ,p_ass_attribute29		 =>	p_ass_attribute29
      ,p_ass_attribute30		 =>	p_ass_attribute30
      ,p_title			         =>	p_title
      ,p_scl_segment1		         =>	p_legal_employer_id
      ,p_group_name			 =>	p_group_name
      ,p_concatenated_segments	         =>	p_concatenated_segments
      ,p_assignment_id		         =>	p_assignment_id
      ,p_soft_coding_keyflex_id	         =>	p_soft_coding_keyflex_id
      ,p_people_group_id		 =>	p_people_group_id
      ,p_object_version_number	         =>	p_object_version_number
      ,p_effective_start_date	         =>	p_effective_start_date
      ,p_effective_end_date		 =>	p_effective_end_date
      ,p_assignment_sequence		 =>	p_assignment_sequence
      ,p_comment_id			 =>	p_comment_id
      ,p_other_manager_warning		 =>	p_other_manager_warning);

      hr_utility.set_location(' Leaving:'||l_proc, 30);

 End create_sg_secondary_emp_asg;

  -- ----------------------------------------------------------------------------
  -- |--------------------------< update_au_emp_asg >---------------------------|
  -- ----------------------------------------------------------------------------
  --

 PROCEDURE update_sg_emp_asg
 (p_validate                            in 	boolean  default false
 ,p_effective_date               	in 	date
 ,p_datetrack_update_mode        	in 	varchar2
 ,p_assignment_id                	in 	number
 ,p_object_version_number        	in out 	nocopy number
 ,p_supervisor_id                	in  	number   default null
 ,p_assignment_number            	in  	varchar2 default null
 ,p_change_reason                	in  	varchar2 default null
 ,p_comments                     	in  	varchar2 default null
 ,p_date_probation_end           	in  	date     default null
 ,p_default_code_comb_id         	in  	number   default null
 ,p_frequency                    	in  	varchar2 default null
 ,p_internal_address_line        	in  	varchar2 default null
 ,p_manager_flag                 	in  	varchar2 default null
 ,p_normal_hours                 	in  	number   default null
 ,p_perf_review_period           	in  	number   default null
 ,p_perf_review_period_frequency 	in  	varchar2 default null
 ,p_probation_period             	in  	number   default null
 ,p_probation_unit               	in  	varchar2 default null
 ,p_sal_review_period            	in  	number   default null
 ,p_sal_review_period_frequency  	in  	varchar2 default null
 ,p_set_of_books_id              	in  	number   default null
 ,p_source_type                  	in  	varchar2 default null
 ,p_time_normal_finish           	in  	varchar2 default null
 ,p_time_normal_start            	in  	varchar2 default null
 ,p_bargaining_unit_code         	in  	varchar2 default null
 ,p_labour_union_member_flag     	in  	varchar2 default null
 ,p_hourly_salaried_code         	in  	varchar2 default null
 ,p_ass_attribute_category       	in  	varchar2 default null
 ,p_ass_attribute1               	in  	varchar2 default null
 ,p_ass_attribute2               	in  	varchar2 default null
 ,p_ass_attribute3               	in  	varchar2 default null
 ,p_ass_attribute4               	in  	varchar2 default null
 ,p_ass_attribute5               	in  	varchar2 default null
 ,p_ass_attribute6               	in  	varchar2 default null
 ,p_ass_attribute7               	in  	varchar2 default null
 ,p_ass_attribute8               	in  	varchar2 default null
 ,p_ass_attribute9               	in  	varchar2 default null
 ,p_ass_attribute10              	in  	varchar2 default null
 ,p_ass_attribute11              	in  	varchar2 default null
 ,p_ass_attribute12              	in  	varchar2 default null
 ,p_ass_attribute13              	in  	varchar2 default null
 ,p_ass_attribute14              	in  	varchar2 default null
 ,p_ass_attribute15              	in  	varchar2 default null
 ,p_ass_attribute16              	in  	varchar2 default null
 ,p_ass_attribute17              	in  	varchar2 default null
 ,p_ass_attribute18              	in  	varchar2 default null
 ,p_ass_attribute19              	in  	varchar2 default null
 ,p_ass_attribute20              	in  	varchar2 default null
 ,p_ass_attribute21              	in  	varchar2 default null
 ,p_ass_attribute22              	in  	varchar2 default null
 ,p_ass_attribute23              	in  	varchar2 default null
 ,p_ass_attribute24              	in  	varchar2 default null
 ,p_ass_attribute25              	in  	varchar2 default null
 ,p_ass_attribute26              	in  	varchar2 default null
 ,p_ass_attribute27              	in  	varchar2 default null
 ,p_ass_attribute28              	in  	varchar2 default null
 ,p_ass_attribute29              	in  	varchar2 default null
 ,p_ass_attribute30              	in  	varchar2 default null
 ,p_title                        	in  	varchar2 default null
 ,p_legal_employer_id                   in 	varchar2 default null
 ,p_cagr_grade_def_id            	out 	nocopy varchar2
 ,p_cagr_concatenated_segments   	out 	nocopy varchar2
 ,p_concatenated_segments        	out 	nocopy varchar2
 ,p_soft_coding_keyflex_id       	out 	nocopy number
 ,p_comment_id                   	out 	nocopy number
 ,p_effective_start_date         	out 	nocopy date
 ,p_effective_end_date           	out 	nocopy date
 ,p_no_managers_warning          	out 	nocopy boolean
 ,p_other_manager_warning		out	nocopy boolean)
 IS
   --
   -- Declare cursors AND local variables
   --
   l_proc                       VARCHAR2(72) := g_package||'update_sg_emp_asg';
   l_effective_date             DATE;
   l_legislation_code           per_business_groups.legislation_code%TYPE;
   --

 CURSOR check_legislation
       (c_assignment_id  per_assignments_f.assignment_id%TYPE,
        c_effective_date DATE
       )
       IS

       SELECT    bgp.legislation_code
       FROM      per_assignments_f asg,
                 per_business_groups bgp
       WHERE     asg.business_group_id = bgp.business_group_id
       AND       asg.assignment_id     = c_assignment_id
       AND       c_effective_date BETWEEN effective_start_date AND effective_end_date;

 Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Truncate DATE variables
    --
    l_effective_date := trunc(p_effective_date);
    --
    -- Validate IN addition to Table Handlers
    --
    -- Check that the assignment exists.
    --
    OPEN    check_legislation(p_assignment_id, l_effective_date);
    FETCH   check_legislation into l_legislation_code;
    IF check_legislation%notfound THEN
      CLOSE check_legislation;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    END IF;
    CLOSE check_legislation;
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the legislation of the specified business group IS 'SG'.
    --
    IF l_legislation_code <> 'SG' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','SG');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 30);
    --
    -- Call update_emp_asg business process
    --    --
       hr_assignment_api.update_emp_asg
       (p_validate                     =>	p_validate
       ,p_effective_date               =>       p_effective_date
       ,p_datetrack_update_mode        =>       p_datetrack_update_mode
       ,p_assignment_id                =>       p_assignment_id
       ,p_object_version_number        =>       p_object_version_number
       ,p_supervisor_id                =>	p_supervisor_id
       ,p_assignment_number            =>	p_assignment_number
       ,p_change_reason                =>	p_change_reason
       ,p_comments                     =>	p_comments
       ,p_date_probation_end           =>	p_date_probation_end
       ,p_default_code_comb_id         =>	p_default_code_comb_id
       ,p_frequency                    =>	p_frequency
       ,p_internal_address_line        =>	p_internal_address_line
       ,p_manager_flag                 =>	p_manager_flag
       ,p_normal_hours                 =>	p_normal_hours
       ,p_perf_review_period           =>	p_perf_review_period
       ,p_perf_review_period_frequency =>	p_perf_review_period_frequency
       ,p_probation_period             =>	p_probation_period
       ,p_probation_unit               =>	p_probation_unit
       ,p_sal_review_period            =>	p_sal_review_period
       ,p_sal_review_period_frequency  =>	p_sal_review_period_frequency
       ,p_set_of_books_id              =>	p_set_of_books_id
       ,p_source_type                  =>	p_source_type
       ,p_time_normal_finish           =>	p_time_normal_finish
       ,p_time_normal_start            =>	p_time_normal_start
       ,p_bargaining_unit_code         =>	p_bargaining_unit_code
       ,p_labour_union_member_flag     =>	p_labour_union_member_flag
       ,p_hourly_salaried_code         =>	p_hourly_salaried_code
       ,p_ass_attribute_category       =>	p_ass_attribute_category
       ,p_ass_attribute1               =>	p_ass_attribute1
       ,p_ass_attribute2               =>	p_ass_attribute2
       ,p_ass_attribute3               =>	p_ass_attribute3
       ,p_ass_attribute4               =>	p_ass_attribute4
       ,p_ass_attribute5               =>	p_ass_attribute5
       ,p_ass_attribute6               =>	p_ass_attribute6
       ,p_ass_attribute7               =>	p_ass_attribute7
       ,p_ass_attribute8               =>	p_ass_attribute8
       ,p_ass_attribute9               =>	p_ass_attribute9
       ,p_ass_attribute10              =>	p_ass_attribute10
       ,p_ass_attribute11              =>	p_ass_attribute11
       ,p_ass_attribute12              =>	p_ass_attribute12
       ,p_ass_attribute13              =>	p_ass_attribute13
       ,p_ass_attribute14              =>	p_ass_attribute14
       ,p_ass_attribute15              =>	p_ass_attribute15
       ,p_ass_attribute16              =>	p_ass_attribute16
       ,p_ass_attribute17              =>	p_ass_attribute17
       ,p_ass_attribute18              =>	p_ass_attribute18
       ,p_ass_attribute19              =>	p_ass_attribute19
       ,p_ass_attribute20              =>	p_ass_attribute20
       ,p_ass_attribute21              =>	p_ass_attribute21
       ,p_ass_attribute22              =>	p_ass_attribute22
       ,p_ass_attribute23              =>	p_ass_attribute23
       ,p_ass_attribute24              =>	p_ass_attribute24
       ,p_ass_attribute25              =>	p_ass_attribute25
       ,p_ass_attribute26              =>	p_ass_attribute26
       ,p_ass_attribute27              =>	p_ass_attribute27
       ,p_ass_attribute28              =>	p_ass_attribute28
       ,p_ass_attribute29              =>	p_ass_attribute29
       ,p_ass_attribute30              =>	p_ass_attribute30
       ,p_title                        =>	p_title
       ,p_segment1                     =>	p_legal_employer_id
       ,p_cagr_grade_def_id            => 	p_cagr_grade_def_id
       ,p_cagr_concatenated_segments   =>	p_cagr_concatenated_segments
       ,p_concatenated_segments        =>	p_concatenated_segments
       ,p_soft_coding_keyflex_id       =>	p_soft_coding_keyflex_id
       ,p_comment_id                   =>	p_comment_id
       ,p_effective_start_date         =>	p_effective_start_date
       ,p_effective_end_date           =>	p_effective_end_date
       ,p_no_managers_warning          =>	p_no_managers_warning
       ,p_other_manager_warning        =>      p_other_manager_warning);

    hr_utility.set_location(' Leaving:'||l_proc, 40);
--
End update_sg_emp_asg;

END hr_sg_assignment_api;

/
