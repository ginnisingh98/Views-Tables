--------------------------------------------------------
--  DDL for Package HR_FI_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FI_UTILITY" AUTHID CURRENT_USER AS
 -- $Header: hrfiutil.pkh 120.1.12010000.4 2009/11/20 07:10:49 dchindar ship $
 --
 -- Formats the full name for the Finland legislation.

 --
 FUNCTION per_fi_full_name
 (p_first_name        IN VARCHAR2
 ,p_middle_names      IN VARCHAR2
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
 -- Formats the order name for the Finland legislation.
 --
 FUNCTION per_fi_order_name
 (p_first_name       IN VARCHAR2
 ,p_middle_names     IN VARCHAR2
 ,p_last_name        IN VARCHAR2
 ,p_known_as         IN VARCHAR2
 ,p_title            IN VARCHAR2
 ,p_suffix           IN VARCHAR2
 ,p_pre_name_adjunct IN VARCHAR2
 ,p_per_information1 IN VARCHAR2
 ,p_per_information2 IN VARCHAR2
 ,p_per_information3 IN VARCHAR2
 ,p_per_information4 IN VARCHAR2
 ,p_per_information5 IN VARCHAR2
 ,p_per_information6 IN VARCHAR2
 ,p_per_information7 IN VARCHAR2
 ,p_per_information8 IN VARCHAR2
 ,p_per_information9 IN VARCHAR2
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
 --
 -- Validates the bank account number.
 --
 -- The format is as follows BC-ACCX where
 --
 -- BC = 6 Digits representing the Branch Code
 -- X = 1 Digit representing the Validation Code
 -- Acc = Between 2 to 7 Digits

FUNCTION validate_account_number
 (p_account_number IN VARCHAR2 ) RETURN NUMBER;

FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2) RETURN NUMBER;


 -- Checks whether the input is a valid date.
 --
 FUNCTION chk_valid_date
 (p_date    IN VARCHAR2
 ,p_century IN VARCHAR2 ) RETURN VARCHAR2;

 FUNCTION get_employment_information
 ( p_assignment_id        IN NUMBER
 , p_emp_information_code IN VARCHAR2 ) RETURN VARCHAR2;

 FUNCTION get_retirement_information
 ( p_person_id        IN NUMBER
 , p_date	      IN DATE
 , p_retire_information_code IN VARCHAR2 ) RETURN VARCHAR2;

 FUNCTION get_vehicle_information
 (p_assignment_id		IN	NUMBER
 ,p_business_group_id		IN	NUMBER
 ,p_effective_date		IN	DATE
 ,p_vehicle_allot_id		IN	VARCHAR2
 ,p_model_year			OUT NOCOPY NUMBER
 ,p_price			OUT NOCOPY NUMBER
 ,p_engine_capacity_in_cc	OUT NOCOPY NUMBER
 ,p_vehicle_type		OUT NOCOPY VARCHAR2
 ) RETURN NUMBER ;

 FUNCTION get_message
 (p_product		IN VARCHAR2
 ,p_message_name	IN VARCHAR2
 ,p_token1		IN VARCHAR2 DEFAULT NULL
 ,p_token2		IN VARCHAR2 DEFAULT NULL
 ,p_token3		IN VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2;

  FUNCTION get_dependent_number
  (p_assignment_id		IN      NUMBER
  ,p_business_group_id		IN      NUMBER
  ,p_process_date		IN      DATE
   ) RETURN NUMBER;

FUNCTION get_court_order_details
 (p_assignment_id		IN          NUMBER
 ,p_effective_date		IN	   DATE
 ,p_dependent_number		OUT NOCOPY  NUMBER
 ,p_third_party			OUT NOCOPY  NUMBER
 ,p_court_order_amount		OUT NOCOPY  NUMBER
 ,p_periodic_installment	OUT NOCOPY  NUMBER
 ,p_number_of_installments	OUT NOCOPY  NUMBER
 ,p_suspension_flag		OUT NOCOPY  VARCHAR2
 ) RETURN NUMBER;

 FUNCTION get_union_details
 (p_assignment_id		IN         NUMBER
 ,p_effective_date		IN	   DATE
 ,p_fixed_union_fees		OUT NOCOPY NUMBER
 ,p_percentage_union_fees       OUT NOCOPY NUMBER
 ,p_payment_calculation_mode    OUT NOCOPY VARCHAR2
 ) RETURN NUMBER;

 FUNCTION get_IANA_charset RETURN VARCHAR2;

 -- Function to Check If Contract Reasons are Update in Assignment EIT
--  Bug - 8425533

 FUNCTION check_Contract_Reasons
 (p_assignment_id		IN         NUMBER
  ,p_contract_type               IN         VARCHAR2
 ) RETURN NUMBER;

END HR_FI_UTILITY;

/
