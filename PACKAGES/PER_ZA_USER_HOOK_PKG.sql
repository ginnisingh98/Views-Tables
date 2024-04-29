--------------------------------------------------------
--  DDL for Package PER_ZA_USER_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_USER_HOOK_PKG" AUTHID CURRENT_USER AS
/* $Header: pezauhkp.pkh 120.0.12010000.5 2010/03/24 05:27:05 rbabla ship $ */

-------------------------------------------------------------------------------
-- validate_applicant
-------------------------------------------------------------------------------
-- Description:
--    Create applicant, before process user hook for South Africa
-- Called from:
--    hr_applicant_api before process user hooks
-- Person DDF segments used :
--    SEGMENT            NAME
--    -------            ----
--    PER_INFORMATION4   Race
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
PROCEDURE validate_applicant
   ( p_business_group_id
        in per_all_people_f.business_group_id%type        default null
   , p_date_received
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type           default null
   , p_per_information_category
        in per_all_people_f.per_information_category%type default null
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type         default null
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   );
-------------------------------------------------------------------------------
-- validate_employee
-------------------------------------------------------------------------------
-- Description:
--    Create employee, before process user hook for South Africa.
-- Called from:
--    hr_employee_api before process user hook
-- Person DDF segments used :
--    SEGMENT            NAME
--    -------            ----
--    PER_INFORMATION4   Race
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
PROCEDURE validate_employee
   ( p_business_group_id
        in per_all_people_f.business_group_id%type        default null
   , p_hire_date
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type           default null
   , p_per_information_category
        in per_all_people_f.per_information_category%type default null
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type         default null
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   );
-------------------------------------------------------------------------------
-- validate_cwk
-------------------------------------------------------------------------------
-- Description:
--    Create contingent worker, before process user hook for South Africa.
-- Called from:
--    hr_contingent_worker_api before process user hook
-- Person DDF segments used :
--    SEGMENT            NAME
--    -------            ----
--    PER_INFORMATION4   Race
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
PROCEDURE validate_cwk
   ( p_business_group_id
        in per_all_people_f.business_group_id%type        default null
   , p_start_date
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type           default null
   , p_per_information_category
        in per_all_people_f.per_information_category%type default null
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type         default null
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   );
-------------------------------------------------------------------------------
-- validate_person
-------------------------------------------------------------------------------
-- Description:
--    Validates person's email_id for South Africa.
-- Called from:
--    1) PERZAOBJ ( Person
-- Person DDF segments used :
--    SEGMENT            NAME
--    -------            ----
--    PER_INFORMATION4   Race
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
PROCEDURE validate_person
   ( p_person_id
        in per_all_people_f.person_id%type
   , p_effective_date
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type
   , p_per_information_category
        in per_all_people_f.per_information_category%type
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   );
-------------------------------------------------------------------------------
-- validate_email_id
-------------------------------------------------------------------------------
-- Description:
--    Validates person's email_id for South Africa.
-- Called from:
--    1) PERZAOBJ ( ZA specific code for Person Form)
--    2) Person create/update APIs Before Hook process
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_email_id (p_email_id varchar2);
-------------------------------------------------------------------------------
-- validate_phone_no
-------------------------------------------------------------------------------
-- Description:
--    Validates phone numbers for South Africa.
-- Called from:
--    PER_PHONES before create and before update APIs
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_phone_no (  p_phone_type  in     varchar2,
                                   p_phone_number  in   varchar2);
-------------------------------------------------------------------------------
-- validate_asg_extra_info
-------------------------------------------------------------------------------
-- Description:
--    Validates Assignment Extra Information for South Africa.
-- Called from:
--    CREATE_ASSIGNMENT_EXTRA_INFO and UPDATE_ASSIGNMENT_EXTRA_INFO APIs
-- Assignment EIT segments used :
--    SEGMENT            NAME
--    -------            ----
--    AEI_ATTRIBUTE2     Employee Trade Name
--    AEI_INFORMATION4   Nature of Person
--    AEI_ATTRIBUTE13    Payment Type
--    AEI_INFORMATION14  SARS Reporting Account Number
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_asg_extra_info (P_AEI_INFORMATION_CATEGORY in VARCHAR2
                                    , P_AEI_INFORMATION2 in VARCHAR2
                                    , P_AEI_INFORMATION4 in VARCHAR2
                                    , P_AEI_INFORMATION13 in VARCHAR2
                                    , P_AEI_INFORMATION14 in VARCHAR2);
-------------------------------------------------------------------------------
-- validate_charcter_set
-------------------------------------------------------------------------------
-- Description:
--    Validates Character Sets for South Africa.
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    function validate_charcter_set (p_input_value in varchar2
                                   , p_mode in varchar2 ) return boolean ;
-------------------------------------------------------------------------------
-- validate_person_address
-------------------------------------------------------------------------------
-- Description:
--    Validates Personal address for Address Style 'South Africa'.
-- Called from:
--    CREATE_PERSON_ADDRESS and UPDATE_PERS_ADDR_WITH_STYLE APIs
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_person_address (P_STYLE           in varchar2
                               ,P_ADDRESS_TYPE    in varchar2
                               ,P_PRIMARY_FLAG    in varchar2
                               ,P_ADDRESS_LINE1   in varchar2
                               ,P_ADDRESS_LINE2   in varchar2
                               ,P_ADDRESS_LINE3   in varchar2
                               ,P_TELEPHONE_NUMBER_1 in varchar2
                               ,P_REGION_1        in varchar2
                               ,P_REGION_2        in varchar2
							   ,P_TOWN_OR_CITY    in varchar2
							   ,P_POSTAL_CODE     in varchar2);
-------------------------------------------------------------------------------
-- validate_location_extra_info
-------------------------------------------------------------------------------
-- Description:
--    Validates Location EIT address for Address Style 'South Africa - SARS'.
-- Called from:
--    CREATE_LOCATION_EXTRA_INFO and UPDATE_LOCATION_EXTRA_INFO  APIs
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_location_extra_info (
                               		P_LEI_INFORMATION_CATEGORY	in	varchar2,
                            		P_LEI_INFORMATION1		in	varchar2,
                            		P_LEI_INFORMATION2		in	varchar2,
                            		P_LEI_INFORMATION3		in	varchar2,
                            		P_LEI_INFORMATION4		in	varchar2,
                            		P_LEI_INFORMATION5		in	varchar2,
                            		P_LEI_INFORMATION6		in	varchar2,
                            		P_LEI_INFORMATION7		in	varchar2);
-------------------------------------------------------------------------------
-- validate_org_info
-------------------------------------------------------------------------------
-- Description:
--    Validate Organization Information
-- Called from:
--    CREATE_ORG_INFORMATION and UPDATE_ORG_INFORMATION
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_org_info (p_org_info_type_code IN  VARCHAR2
                                ,p_org_information1   IN  VARCHAR2
                                ,p_org_information2   IN  VARCHAR2
                                ,p_org_information3   IN  VARCHAR2
                                ,p_org_information4   IN  VARCHAR2
                                ,p_org_information5   IN  VARCHAR2
                                ,p_org_information6   IN  VARCHAR2
                                ,p_org_information7   IN  VARCHAR2
                                ,p_org_information8   IN  VARCHAR2
                                ,p_org_information9   IN  VARCHAR2
                                ,p_org_information10  IN  VARCHAR2
                                ,p_org_information11  IN  VARCHAR2
                                ,p_org_information12  IN  VARCHAR2
                                ,p_org_information13  IN  VARCHAR2);

----------------------------------------------------------------------------
-- validate_update_per_payment
-- Description:
--    Validates Personal Payment DDF
-- Called from:
--    UPDATE_PERSONAL_PAY_METHOD

----------------------------------------------------------------------------
    procedure validate_update_per_payment  (P_EFFECTIVE_DATE              IN  DATE
                                           ,P_EFFECTIVE_START_DATE        IN  DATE
                                           ,P_EFFECTIVE_END_DATE          IN  DATE
                                           ,P_PERSONAL_PAYMENT_METHOD_ID  IN  NUMBER
                                           ,P_PPM_INFORMATION1            IN  VARCHAR2);



----------------------------------------------------------------------------
-- validate_create_per_payment
-- Description:
--    Validates Personal Payment DDF
-- Called from:
--    CREATE_PERSONAL_PAY_METHOD

----------------------------------------------------------------------------
    procedure validate_create_per_payment   (P_EFFECTIVE_START_DATE        IN  DATE
                                            ,P_EFFECTIVE_END_DATE          IN  DATE
                                            ,P_ASSIGNMENT_ID               IN  NUMBER
                                            ,P_PERSONAL_PAYMENT_METHOD_ID  IN  NUMBER
                                            ,P_PPM_INFORMATION1            IN  VARCHAR2 DEFAULT NULL);



END per_za_user_hook_pkg;

/
