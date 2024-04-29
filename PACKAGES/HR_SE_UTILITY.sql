--------------------------------------------------------
--  DDL for Package HR_SE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SE_UTILITY" AUTHID CURRENT_USER AS
 -- $Header: hrseutil.pkh 120.1.12010000.2 2009/11/27 10:31:48 dchindar ship $
 --
 -- Formats the full name for the Sweden legislation.
 --
 FUNCTION per_se_full_name
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
 -- Formats the order name for the Sweden legislation.
 --
 FUNCTION per_se_order_name
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

 -- Checks whether the input is a valid date.
 --
 FUNCTION chk_valid_date
 (p_date IN VARCHAR2) RETURN VARCHAR2;


 -- Validates the bank account number.
 --

  FUNCTION validate_account_number
 (p_account_number IN VARCHAR2,
  p_session_id IN NUMBER,
  p_bg_id IN NUMBER) RETURN NUMBER;

  FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2,
 p_session_id    IN NUMBER default NULL,
 p_bg_id         IN NUMBER default NULL) RETURN NUMBER;


FUNCTION get_court_order_details
 (p_assignment_id		IN          NUMBER
 ,p_effective_date		IN	   DATE
 ,p_reserved_amount		OUT NOCOPY  NUMBER
 ,p_disdraint_amount	OUT NOCOPY  NUMBER
 ,p_suspension_flag		OUT NOCOPY  VARCHAR2
 ) RETURN NUMBER;

FUNCTION GET_COMPANY_MILEAGE_LIMIT
(p_effective_date       IN DATE
,p_business_group_id    IN NUMBER
,p_tax_unit_id	        IN NUMBER
,p_car_type   	        IN VARCHAR2
) RETURN NUMBER;

--
 function get_message
			(p_product           in varchar2
			,p_message_name      in varchar2
			,p_token1            in varchar2 default null
                        ,p_token2            in varchar2 default null
                        ,p_token3            in varchar2 default null) return varchar2;

  FUNCTION get_IANA_charset RETURN VARCHAR2;

END hr_se_utility ;




/
