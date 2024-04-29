--------------------------------------------------------
--  DDL for Package HR_ES_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ES_UTILITY" AUTHID CURRENT_USER AS
/* $Header: peesutil.pkh 120.0.12010000.2 2009/12/20 07:47:19 rpahune ship $ */
--
FUNCTION validate_identifier(p_identifier_type  VARCHAR2
                            ,p_identifier_value VARCHAR2) RETURN VARCHAR2;
--
FUNCTION check_DNI(p_identifier_value VARCHAR2) RETURN VARCHAR2;
--
FUNCTION check_NIF(p_identifier_value VARCHAR2) RETURN VARCHAR2;
--
FUNCTION check_NIE(p_identifier_value VARCHAR2) RETURN VARCHAR2;
--
FUNCTION per_es_full_name(
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
/*--
FUNCTION validate_account_no(p_bank_code        VARCHAR2
                            ,p_branch_code      VARCHAR2
                            ,p_account_number   VARCHAR2
                            ,p_validation_code  VARCHAR2) RETURN NUMBER;
*/


FUNCTION validate_non_IBAN_acc_no(p_bank_code        VARCHAR2
                            ,p_branch_code      VARCHAR2
                            ,p_account_number   VARCHAR2
                            ,p_validation_code  VARCHAR2) RETURN NUMBER;
--

FUNCTION validate_account_no (p_bank_code        VARCHAR2 default null
                            ,p_branch_code      VARCHAR2 default null
                            ,p_account_number   VARCHAR2 default null
                            ,p_validation_code  VARCHAR2 default null
                            ,p_acc_type         varchar2
                            ,p_iban_acc         varchar2 default null) return number;
--
FUNCTION validate_iban_acc(p_account_no VARCHAR2
                          )RETURN NUMBER;


--
PROCEDURE check_identifier_unique
( p_identifier_type         VARCHAR2,
  p_identifier_value        VARCHAR2,
  p_person_id               NUMBER,
  p_business_group_id       NUMBER);

FUNCTION validate_cac_lookup (p_province_code VARCHAR2) RETURN NUMBER;
--
PROCEDURE validate_cif(p_org_info   VARCHAR2);
--
PROCEDURE validate_cac(p_org_info   VARCHAR2);
--
PROCEDURE check_leaving_reason(p_leaving_reason         VARCHAR2
                              ,p_business_group_id      NUMBER);
--
FUNCTION check_SSI(p_identifier_value VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_disability_degree(p_person_id NUMBER
                              ,p_session_date DATE) RETURN NUMBER;

--
FUNCTION get_ssno(p_assignment_id number
                 ,p_element_type_id number
                 ,p_input_value_id number
                 ,p_effective_date date) RETURN VARCHAR2;

PROCEDURE unique_cac(p_org_info_id          NUMBER
                    ,p_context              VARCHAR2
                    ,p_org_info             VARCHAR2
                    ,p_business_group_id    NUMBER
                    ,p_effective_date       DATE);

PROCEDURE unique_cif(p_org_info_id          NUMBER
                    ,p_org_info             VARCHAR2
                    ,p_business_group_id    NUMBER
                    ,p_effective_date       DATE);

PROCEDURE validate_wc_sec_ref(p_context             VARCHAR2
                             ,p_org_information1    VARCHAR2
                             ,p_business_group_id   NUMBER
                             ,p_effective_date      DATE);

PROCEDURE unique_ss(p_org_info_id          NUMBER
                    ,p_context              VARCHAR2
                    ,p_org_info             VARCHAR2
                    ,p_business_group_id    NUMBER
                    ,p_effective_date       DATE);

FUNCTION chk_entry_in_lookup(p_lookup_type    IN  hr_lookups.lookup_type%TYPE
                            ,p_entry_val      IN  hr_lookups.meaning%TYPE
                            ,p_effective_date IN  hr_lookups.start_date_active%TYPE
                            ,p_message        OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_message(p_product           IN VARCHAR2
                    ,p_message_name      IN VARCHAR2
                    ,p_token1            IN VARCHAR2 DEFAULT NULL
                    ,p_token2            IN VARCHAR2 DEFAULT NULL
                    ,p_token3            IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
--
FUNCTION get_table_value_date(bus_group_id    IN NUMBER
                                               ,ptab_name       IN VARCHAR2
                                   ,pcol_name       IN VARCHAR2
                                           ,prow_value      IN VARCHAR2
                             ,peffective_date IN DATE)RETURN NUMBER;

--
FUNCTION get_table_value(bus_group_id    IN NUMBER
                        ,peffective_date IN DATE
                        ,ptab_name       IN VARCHAR2
                        ,pcol_name       IN VARCHAR2
                        ,prow_value      IN VARCHAR2)RETURN NUMBER;
--
FUNCTION get_table_value_char(bus_group_id    IN NUMBER
                             ,peffective_date IN DATE
                             ,ptab_name       IN VARCHAR2
                             ,pcol_name       IN VARCHAR2
                             ,prow_value      IN VARCHAR2)RETURN VARCHAR2;
--
FUNCTION decode_lookup_desc(p_lookup_type   VARCHAR2
                           ,p_lookup_code   VARCHAR2) RETURN VARCHAR2;
END hr_es_utility;

/
