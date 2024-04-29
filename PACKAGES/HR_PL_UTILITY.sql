--------------------------------------------------------
--  DDL for Package HR_PL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_UTILITY" AUTHID CURRENT_USER AS
/* $Header: peplutil.pkh 120.4.12010000.2 2009/12/18 10:53:26 bkeshary ship $ */
FUNCTION per_pl_full_name(
                p_first_name        IN VARCHAR2
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
               ,p_per_information30 IN VARCHAR2
               ) RETURN VARCHAR2;
--
FUNCTION per_pl_order_name(
                p_first_name        IN VARCHAR2
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
               ,p_per_information30 IN VARCHAR2
               ) RETURN VARCHAR2;

--

FUNCTION per_pl_chk_valid_date (p_date IN VARCHAR2) RETURN VARCHAR2;

--

PROCEDURE per_pl_nip_validate(p_nip_number IN varchar2,
                              p_person_id  IN number,
                              p_business_group_id in number,
                              p_legal_employer IN varchar2,
                              p_nationality    IN varchar2 ,
			      p_citizenship    IN varchar2
                              );

--

PROCEDURE per_pl_chk_gender(nat_id varchar2,gender IN OUT NOCOPY varchar2);

Procedure per_pl_validate(pesel varchar2);

FUNCTION validate_account_no(p_check_digit varchar2,
                            p_bank_id   VARCHAR2,
                            p_account_number VARCHAR2
                            ) RETURN NUMBER ;

FUNCTION validate_account_entered
(p_acc_no        			IN VARCHAR2,
 p_is_iban_acc   			IN varchar2,
 p_bank_chk_dig     	IN varchar2 DEFAULT NULL,
 p_bank_id            IN Varchar2 DEFAULT NULL) RETURN NUMBER;

FUNCTION validate_iban_acc
(p_account_no  IN VARCHAR2)RETURN NUMBER;

FUNCTION validate_bank_id(p_bank_id varchar2) RETURN NUMBER;

PROCEDURE per_pl_calc_periods(p_start_date IN DATE,
					  p_end_date IN DATE,
					  p_days IN OUT NOCOPY NUMBER,
			          p_months IN OUT NOCOPY NUMBER,
   	  		          p_years IN OUT NOCOPY NUMBER);

FUNCTION GET_LENGTH_OF_SERVICE(P_PERSON_ID       IN NUMBER,
                               P_TYPE_OF_SERVICE IN VARCHAR2, -- This is the code of the Category
			           l_years           OUT NOCOPY NUMBER,
			           l_months          OUT NOCOPY NUMBER,
			           l_days            OUT NOCOPY NUMBER,
			           l_message         OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION CHECK_CONTRIBUTION_TYPE(P_ENTRY_VALUE IN VARCHAR2) return NUMBER ;

FUNCTION GET_VEHICLE_MILEAGE(p_date_earned 				IN DATE,
					 p_vehicle_allocation_id 	IN NUMBER,
					 p_monthly_mileage_limit 	OUT NOCOPY NUMBER,
					 p_engine_capacity_in_cc 	OUT NOCOPY NUMBER,
					 p_vehicle_type				OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION GET_TOTAL_PERIOD_OF_SERVICE
                      (p_assignment_id  in number,
                       p_date           in date,
                       p_years          OUT NOCOPY NUMBER,
                       p_months         OUT NOCOPY NUMBER,
                       p_days           OUT NOCOPY NUMBER) return number;
PROCEDURE PER_PL_CHECK_NI_UNIQUE
         ( p_national_identifier     VARCHAR2,
           p_person_id               NUMBER,
           p_business_group_id       NUMBER,
           p_legal_employer          VARCHAR2);

END hr_pl_utility;

/
