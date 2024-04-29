--------------------------------------------------------
--  DDL for Package PAY_DK_ABSENCE_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_ABSENCE_USER" AUTHID CURRENT_USER AS
/*$Header: pydkabsence.pkh 120.1.12000000.2 2007/05/08 06:59:26 saurai noship $*/
Function Element_populate (p_assignment_id         in number,
                p_person_id in number,
                p_absence_attendance_id in number,
                p_element_type_id 	    in number,
                p_absence_category 	    in varchar2,
                p_original_entry_id     OUT nocopy NUMBER,
                p_input_value_name1 	OUT NOCOPY VARCHAR2,
		p_input_value1	    	OUT NOCOPY VARCHAR2,
                p_input_value_name2 	OUT NOCOPY VARCHAR2,
		p_input_value2	    	OUT NOCOPY VARCHAR2,
                p_input_value_name3 	OUT NOCOPY VARCHAR2,
		p_input_value3	    	OUT NOCOPY VARCHAR2,
                p_input_value_name4 	OUT NOCOPY VARCHAR2,
		p_input_value4	    	OUT NOCOPY VARCHAR2,
                p_input_value_name5 	OUT NOCOPY VARCHAR2,
		p_input_value5	    	OUT NOCOPY VARCHAR2,
                p_input_value_name6 	OUT NOCOPY VARCHAR2,
		p_input_value6	    	OUT NOCOPY VARCHAR2,
                p_input_value_name7 	OUT NOCOPY VARCHAR2,
		p_input_value7	    	OUT NOCOPY VARCHAR2,
                p_input_value_name8 	OUT NOCOPY VARCHAR2,
		p_input_value8	    	OUT NOCOPY VARCHAR2,
                p_input_value_name9 	OUT NOCOPY VARCHAR2,
		p_input_value9	    	OUT NOCOPY VARCHAR2,
                p_input_value_name10 	OUT NOCOPY VARCHAR2,
		p_input_value10	    	OUT NOCOPY VARCHAR2,
                p_input_value_name11 	OUT NOCOPY VARCHAR2,
		p_input_value11	    	OUT NOCOPY VARCHAR2,
                p_input_value_name12 	OUT NOCOPY VARCHAR2,
		p_input_value12	    	OUT NOCOPY VARCHAR2,
                p_input_value_name13 	OUT NOCOPY VARCHAR2,
		p_input_value13	    	OUT NOCOPY VARCHAR2,
                p_input_value_name14 	OUT NOCOPY VARCHAR2,
		p_input_value14	    	OUT NOCOPY VARCHAR2,
                p_input_value_name15 	OUT NOCOPY VARCHAR2,
		p_input_value15	    	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


	FUNCTION get_override_details
		 (p_assignment_id               IN         NUMBER
		 ,p_effective_date              IN         DATE
		 ,p_abs_start_date              IN         DATE
		 ,p_abs_end_date                IN         DATE
		 ,p_pre_birth_duration          IN OUT NOCOPY NUMBER
		 ,p_post_birth_duration         IN OUT NOCOPY NUMBER
		 ,p_maternity_allowance_used    OUT NOCOPY NUMBER
		 ,p_shared_allowance_used       OUT NOCOPY NUMBER
		 ,p_holiday_override            OUT NOCOPY NUMBER
		 ,p_part_time_hours             IN OUT NOCOPY NUMBER
		 ,p_part_time_hrs_freq          IN OUT NOCOPY VARCHAR2
		 ) RETURN NUMBER;

       FUNCTION get_absence_details
        	 (p_assignment_id               IN         NUMBER
 		 ,p_date_earned                IN         DATE
 		 ,p_abs_attendance_id           IN         NUMBER
 		 ,p_expected_dob                OUT NOCOPY DATE
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_pre_birth_duration          OUT NOCOPY NUMBER
 		 ,p_post_birth_duration         OUT NOCOPY NUMBER
 		 ,p_frequency                   OUT NOCOPY VARCHAR2
		 ,p_normal_hours                OUT NOCOPY NUMBER
		 ,p_maternity_weeks_transfer    OUT NOCOPY NUMBER
                 ,p_holiday_accrual             OUT NOCOPY VARCHAR2
		) Return varchar2;

       FUNCTION get_assg_term_date
       		(p_business_group_id IN NUMBER
       		,p_assignment_id     IN NUMBER)
       RETURN DATE;

	/*Function to get paternity absence details*/
	FUNCTION get_pat_abs_details
       	 (
	 p_abs_attendance_id           IN NUMBER,
	 p_override_weeks              OUT NOCOPY NUMBER,
 	 p_holiday_accrual	        OUT NOCOPY VARCHAR2
	 ) Return NUMBER;

	 FUNCTION get_paternity_override
	 (p_assignment_id               IN         NUMBER
	 ,p_effective_date              IN         DATE
	 ,p_abs_start_date              IN         DATE
	 ,p_abs_end_date                IN         DATE
	 ,p_duration_override           IN OUT NOCOPY NUMBER
	 ,p_holiday_override            OUT NOCOPY NUMBER
	 ) RETURN NUMBER;

	FUNCTION get_adopt_abs_details
        	 (p_assignment_id               IN         NUMBER
 		 ,p_date_earned                IN         DATE
 		 ,p_abs_attendance_id           IN         NUMBER
 		 ,p_expected_dob                OUT NOCOPY DATE
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_pre_adopt_duration          OUT NOCOPY NUMBER
 		 ,p_post_adopt_duration         OUT NOCOPY NUMBER
		 ,p_adopt_weeks_transfer        OUT NOCOPY NUMBER
		 ,p_weeks_from_mother           OUT NOCOPY NUMBER
		 ,p_sex                         OUT NOCOPY VARCHAR2
		 ,p_holiday_accrual	        OUT NOCOPY VARCHAR2
		) Return NUMBER ;

	FUNCTION get_parental_details
        	 (p_abs_attendance_id           IN         NUMBER
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_duration_override           OUT NOCOPY NUMBER
		 ,p_parental_type               OUT NOCOPY VARCHAR2
		 ,p_holiday_accrual	        OUT NOCOPY VARCHAR2
 		 ) Return varchar2;

	 FUNCTION get_parental_override
	 (p_assignment_id               IN         NUMBER
	 ,p_effective_date              IN         DATE
	 ,p_abs_start_date              IN         DATE
	 ,p_abs_end_date                IN         DATE
	 ,p_shared_duration          IN OUT NOCOPY NUMBER
	 ,p_shared_mat_allowance_used   OUT NOCOPY NUMBER
	 ,p_shared_adopt_allowance_used OUT NOCOPY NUMBER
	 ,p_holiday_override            OUT NOCOPY NUMBER
	 ) RETURN NUMBER;

	  FUNCTION get_adopt_override_details
	 (p_assignment_id               IN         NUMBER
	 ,p_effective_date              IN         DATE
	 ,p_abs_start_date              IN         DATE
	 ,p_abs_end_date                IN         DATE
	 ,p_pre_adopt_duration          IN OUT NOCOPY NUMBER
	 ,p_post_adopt_duration         IN OUT NOCOPY NUMBER
	 ,p_adoption_allowance_used    OUT NOCOPY NUMBER
	 ,p_shared_allowance_used       OUT NOCOPY NUMBER
	 ,p_holiday_override            OUT NOCOPY NUMBER
	 ) RETURN NUMBER;

	 /* Added functions for Holiday Accrual impact */

	FUNCTION conv_day_to_num( p_day VARCHAR2) RETURN NUMBER;

	FUNCTION get_wrk_days_hol_accr
	(p_wrk_pattern                 IN         VARCHAR2
	,p_hrs_in_day                  IN         NUMBER
	,p_abs_start_date              IN         DATE
	,p_abs_end_date                IN         DATE
	,p_abs_start_time              IN         VARCHAR2
	,p_abs_end_time                IN         VARCHAR2
	) RETURN NUMBER;

/* Function to get Part Time Maternity Details */
	FUNCTION get_ptm_abs_details
        	 (p_abs_attendance_id           IN         NUMBER
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_part_time_hours             OUT NOCOPY NUMBER
		 ,p_part_time_hrs_freq          OUT NOCOPY VARCHAR2
		 ,p_holiday_accrual	        OUT NOCOPY VARCHAR2
 		 ) Return varchar2;
       Function get_part_time_worked_hrs
		  (p_assignment_id               IN         NUMBER
		  ,p_date_earned                 IN         DATE
		  ,p_abs_start_date              IN         DATE
		  ,p_abs_end_date                IN         DATE
		  ,p_start_time                  IN         VARCHAR2
		  ,p_end_time                    IN         VARCHAR2
		  ,p_worked_hours                OUT NOCOPY NUMBER
		  ,p_weekly_worked_days          OUT NOCOPY NUMBER
		  ) return Varchar2;

END PAY_DK_ABSENCE_USER;

 

/
