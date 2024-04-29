--------------------------------------------------------
--  DDL for Package HR_NO_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NO_UTILITY" AUTHID CURRENT_USER AS
/* $Header: hrnoutil.pkh 120.5.12010000.2 2009/11/27 10:34:09 dchindar ship $ */

 --
 --
 -- Formats the full name for the Norway legislation.
 --
 FUNCTION per_no_full_name
 (p_first_name        IN VARCHAR2
 ,p_middle_name       IN VARCHAR2
 ,p_last_name         IN VARCHAR2
 ,p_known_as          IN VARCHAR2
 ,p_title             IN VARCHAR2
 ,p_suffix            IN VARCHAR2
 ,p_pre_name_adjunct  IN VARCHAR2
 ,p_per_information1  IN VARCHAR2
 ,p_per_information2  IN VARCHAR2
 ,p_per_information3  IN VARCHAR2
 ,p_per_information4  IN VARCHAR2
 ,p_per_information5  IN VARCHAR2
 ,p_per_information6  IN VARCHAR2
 ,p_per_information7  IN VARCHAR2
 ,p_per_information8  IN VARCHAR2
 ,p_per_information9  IN VARCHAR2
 ,p_per_information10 IN VARCHAR2
 ,p_per_information11 IN VARCHAR2
 ,p_per_information12 IN VARCHAR2
 ,p_per_information13 IN VARCHAR2
 ,p_per_information14 IN VARCHAR2
 ,p_per_information15 IN VARCHAR2
 ,p_per_information16 IN VARCHAR2
 ,p_per_information17 IN VARCHAR2
 ,p_per_information18 IN VARCHAR2
 ,p_per_information19 IN VARCHAR2
 ,p_per_information20 IN VARCHAR2
 ,p_per_information21 IN VARCHAR2
 ,p_per_information22 IN VARCHAR2
 ,p_per_information23 IN VARCHAR2
 ,p_per_information24 IN VARCHAR2
 ,p_per_information25 IN VARCHAR2
 ,p_per_information26 IN VARCHAR2
 ,p_per_information27 IN VARCHAR2
 ,p_per_information28 IN VARCHAR2
 ,p_per_information29 IN VARCHAR2
 ,p_per_information30 in VARCHAR2) RETURN VARCHAR2;
 --
 --
 -- Formats the order name for the Norway legislation.
 --
 FUNCTION per_no_order_name
 (p_first_name        IN VARCHAR2
 ,p_middle_name       IN VARCHAR2
 ,p_last_name         IN VARCHAR2
 ,p_known_as          IN VARCHAR2
 ,p_title             IN VARCHAR2
 ,p_suffix            IN VARCHAR2
 ,p_pre_name_adjunct  IN VARCHAR2
 ,p_per_information1  IN VARCHAR2
 ,p_per_information2  IN VARCHAR2
 ,p_per_information3  IN VARCHAR2
 ,p_per_information4  IN VARCHAR2
 ,p_per_information5  IN VARCHAR2
 ,p_per_information6  IN VARCHAR2
 ,p_per_information7  IN VARCHAR2
 ,p_per_information8  IN VARCHAR2
 ,p_per_information9  IN VARCHAR2
 ,p_per_information10 IN VARCHAR2
 ,p_per_information11 IN VARCHAR2
 ,p_per_information12 IN VARCHAR2
 ,p_per_information13 IN VARCHAR2
 ,p_per_information14 IN VARCHAR2
 ,p_per_information15 IN VARCHAR2
 ,p_per_information16 IN VARCHAR2
 ,p_per_information17 IN VARCHAR2
 ,p_per_information18 IN VARCHAR2
 ,p_per_information19 IN VARCHAR2
 ,p_per_information20 IN VARCHAR2
 ,p_per_information21 IN VARCHAR2
 ,p_per_information22 IN VARCHAR2
 ,p_per_information23 IN VARCHAR2
 ,p_per_information24 IN VARCHAR2
 ,p_per_information25 IN VARCHAR2
 ,p_per_information26 IN VARCHAR2
 ,p_per_information27 IN VARCHAR2
 ,p_per_information28 IN VARCHAR2
 ,p_per_information29 IN VARCHAR2
 ,p_per_information30 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION validate_account_number
 (p_account_number IN VARCHAR2) RETURN NUMBER ;

 FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ) RETURN NUMBER;


  FUNCTION chk_valid_date
 (p_nat_id IN VARCHAR2) RETURN NUMBER ;



-- Function     : get_employment_information
-- Parameters : assignment_id  -  p_assignment_id,
--			employment information code - l_information_code.
-- Description : The function returns the employment information based on the assignment id
--			and the information code parameters. The information is first searced for at
--			the assignment level through the HR_Organization level , Local Unit level ,
--			Legal Employer Level to the Business group level.
--
-- The values for  p_emp_information_code can be
--		JOB_STATUS  for Job Status
--		COND_OF_EMP	for Condition of Employment
--		PART_FULL_TIME for Full/Part Time
--		SHIFT_WORK  for Shift Work
--		PAYROLL_PERIOD for Payroll Period
--		AGREED_WORKING_HOURS for Agreed working hours

 FUNCTION get_employment_information
 ( p_assignment_id IN NUMBER, p_emp_information_code IN VARCHAR2 ) RETURN VARCHAR2;


-- function for Norway BIK to get element entry effective start date

FUNCTION Get_EE_EFF_START_DATE
(p_EE_ID pay_element_entries_f.ELEMENT_ENTRY_ID%TYPE,
 p_date_earned DATE)
return DATE;

-- function for Norway BIK to get element entry effective end date

FUNCTION Get_EE_EFF_END_DATE
(p_EE_ID pay_element_entries_f.ELEMENT_ENTRY_ID%TYPE,
 p_date_earned DATE)
return DATE;

-- function for Norway BIK Company Cars to get vehile information

FUNCTION get_vehicle_info
( p_assignment_id per_all_assignments_f.assignment_id%TYPE,
  p_date_earned DATE,
  p_list_price OUT NOCOPY pqp_vehicle_repository_f.LIST_PRICE%TYPE,
  p_reg_number OUT NOCOPY pqp_vehicle_repository_f.REGISTRATION_NUMBER%TYPE,
  p_reg_date   OUT NOCOPY pqp_vehicle_repository_f.INITIAL_REGISTRATION%TYPE
)
return NUMBER;

-- function for Norway BIK Company Cars to get number of periods and months

FUNCTION get_num_of_periods_n_months
( p_payroll_id IN PAY_PAYROLLS_F.PAYROLL_ID%TYPE ,
  p_start_date IN DATE,
  p_end_date IN DATE,
  p_curr_pay_start_date IN DATE,
  p_curr_per_pay_date IN DATE,
  p_num_of_periods OUT NOCOPY VARCHAR2,
  p_num_of_months OUT NOCOPY VARCHAR2
)
RETURN NUMBER;


-- For BIK , to get number of pay periods with pay date
-- in the current payroll year for Preferential Loans

FUNCTION get_num_of_periods
( p_payroll_id IN PAY_PAYROLLS_F.PAYROLL_ID%TYPE ,
  p_curr_per_pay_date IN DATE
)
RETURN NUMBER;


/* For BIK , to get the regular payment date
   for the current payroll period */

FUNCTION get_regular_pay_date
( p_payroll_id IN PAY_PAYROLLS_F.PAYROLL_ID%TYPE ,
  p_Curr_Pay_Start_Date IN DATE
)
RETURN DATE;



/* Function to get the message text */

FUNCTION get_msg_text
( p_applid   IN NUMBER,
  p_msg_name IN VARCHAR2
)
RETURN varchar2;

------------------------------------------------------------------------
-- Function GET_TABLE_BANDS
------------------------------------------------------------------------
FUNCTION get_table_value
			(p_Date_Earned     IN DATE
			,p_table_name      IN VARCHAR2
			,p_column_name     IN VARCHAR2
			,p_return_type     IN VARCHAR2) RETURN NUMBER;
PROCEDURE CREATE_NO_DEI_INFO
(P_PERSON_ID	 IN NUMBER DEFAULT NULL,
P_ISSUED_DATE IN DATE  DEFAULT NULL,
P_DATE_FROM	 IN DATE,
P_DATE_TO IN DATE,
P_DOCUMENT_NUMBER IN VARCHAR2  DEFAULT NULL,
P_DOCUMENT_TYPE_ID	 IN NUMBER
);

PROCEDURE UPDATE_NO_DEI_INFO
(P_PERSON_ID	 IN NUMBER DEFAULT NULL,
P_ISSUED_DATE IN DATE  DEFAULT NULL,
P_DATE_FROM	 IN DATE,
P_DATE_TO IN DATE,
P_DOCUMENT_NUMBER IN VARCHAR2  DEFAULT NULL,
P_DOCUMENT_EXTRA_INFO_ID IN NUMBER,
P_DOCUMENT_TYPE_ID	 IN NUMBER
);


FUNCTION get_IANA_charset RETURN VARCHAR2;

--Function to display messages after payroll run.
FUNCTION get_message
(p_product IN VARCHAR2,
p_message_name IN VARCHAR2,
p_token1 IN VARCHAR2 DEFAULT NULL,
p_token2 IN VARCHAR2 DEFAULT NULL,
p_token3 IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


 ---------------------------------------------------------------------------
 -- Function : get_global_value
 -- Function returns the global value for the given date.
 ---------------------------------------------------------------------------

 FUNCTION get_global_value (l_global_name VARCHAR2 , l_date DATE ) RETURN VARCHAR2 ;


END hr_no_utility;

/
