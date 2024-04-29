--------------------------------------------------------
--  DDL for Package HR_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON" AUTHID CURRENT_USER AS
/* $Header: peperson.pkh 120.0.12010000.1 2008/07/28 05:14:51 appldev ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_person  (HEADER)

 Description : This package declares procedures required to INSERT,
   UPDATE or DELETE people on Oracle Human Resources. Note, this
   does not include extra validation provided by calling programs (such
   as screen QuickPicks and HRLink validation) OR that provided by use
   of constraints and triggers held against individual tables.
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    21-DEC-92 SZWILLIA             Date Created
                                        Requires new messages
 70.1    04-JAN-93 PBARRY               Following procedures added:
					product_installed
                                        person_existance_check
                                        pay_predel_validation
                                        ssp_predel_validation
                                        weak_predel_validation
                                        strong_predel_validation
                                        delete_a_person
                                        people_default_deletes
                                        applicant_default_deletes
 70.2    04-JAN-93 PBARRY		Ignore_all_relationships parameter
					removed from strong_predel_validation.
 70.3    11-FEB-93 PBARRY		P_SESSION_DATE parameter added to :
					weak_predel_validation
					strong_predel_validation
					delete_a_person
					check_contact
 70.4    04-MAR-93 SZWILLIA             Changed parameters to dates.
 70.5    11-MAR-93 NKHAn		Added 'exit' to the end
 70.6    19-APR-93 TMathers             Added chk_future_person_type,
                                              chk_prev_person_type,
                                              Validate_address.
                                        Changed derive_full_name
                                        to be a procedure rather than
                                        a function.Changed
                                        strong_pre_delete validation
                                        removed a line.
 70.7    09-JUN-93   TMATHERS           Fixed validate_dob to work for any
                                        person_type.
 70.11   13-JUN-93   TMATHERS           Fixed generate_number added p_person_id
                                        parameter. Fixed version comments also.
 70.14   07-Dec-93   TMATHERS           Split Validate National Identifier
 80.1                                   so that duplicate check is in another
                                        procedure, check_ni_unique. B280
 70.16   26-jul-94   TMathers           Overloaded chk_future wrt G1121.
 70.17   06-May-96   TMathers           Overloaded derive_full_name to cope
 70.18   07-May-96   TMathers           missing ????
 70.19   27-Jan-97   VTreiger           Added PRE_NAME_ADJUNCT,SUFFIX as
                                        parameters to derive_full_name
			        	 with suffix field.(352340).
 115.1   20-Apr-00   czdickin           Added PER_INFORMATIONXX as parameters
                                        to derive_full_name.
 115.2   23-JAN092   stlocke		Added dbdrv commands
 115.3   20-FEB-02   adhunter           Added npw parameters to generate_number and
                                        validate_unique_number
 115.4   03-NOV-02   eumenyio           added nocopy

 115.7   27-JAN-04   irgonzal           Enh 3299580: Overloaded generate_number.

 ================================================================= */
--
-- -----------------------  generate_number ------------------------
--
-- Procedure accepts the current emp and apl flags, national identifier
-- and business group and outputs the employee and applicant number
-- (Note if employee and applicant number are supplied and the method
--  is not automatic - the numbers will remain unchanged).
--
PROCEDURE generate_number
 (p_current_employee    VARCHAR2 default null,
  p_current_applicant   VARCHAR2 default null,
  p_current_npw         VARCHAR2 default null,
  p_national_identifier VARCHAR2 default null,
  p_business_group_id   NUMBER,
  p_person_id           NUMBER,
  p_employee_number  IN OUT NOCOPY VARCHAR2 ,
  p_applicant_number IN OUT NOCOPY VARCHAR2 ,
  p_npw_number       IN OUT NOCOPY VARCHAR2);
--
-- 3299580: Overloaded
--
PROCEDURE generate_number
 (p_current_employee    VARCHAR2 default null,
  p_current_applicant   VARCHAR2 default null,
  p_current_npw         VARCHAR2 default null,
  p_national_identifier VARCHAR2 default null,
  p_business_group_id   NUMBER,
  p_person_id           NUMBER,
  p_employee_number  IN OUT NOCOPY VARCHAR2 ,
  p_applicant_number IN OUT NOCOPY VARCHAR2 ,
  p_npw_number       IN OUT NOCOPY VARCHAR2
 ,p_effective_date      IN     date
 ,p_party_id            IN     number
 ,p_date_of_birth       IN     date
 ,p_start_date          IN     date default null
 );
--
--
-- -------------------------- derive_full_name  ---------------------------
-- Construct FULL_NAME based on all name fields and if this name and date of
-- birth combination already exists (upper or lower case) then write an error
-- but DO NOT FAIL the procedure. Full Name may still be required as forms
-- treats this as a warning not an error
--
PROCEDURE derive_full_name
(p_first_name    VARCHAR2,
 p_middle_names  VARCHAR2,
 p_last_name     VARCHAR2,
 p_known_as      VARCHAR2,
 p_title         VARCHAR2,
 p_suffix        VARCHAR2,
 p_pre_name_adjunct VARCHAR2,
 p_date_of_birth DATE,
 p_person_id         NUMBER,
 p_business_group_id NUMBER,
 p_full_name OUT NOCOPY VARCHAR2 ,
 p_duplicate_flag OUT NOCOPY VARCHAR2,
 p_per_information1 VARCHAR2 DEFAULT NULL,
 p_per_information2 VARCHAR2 DEFAULT NULL,
 p_per_information3 VARCHAR2 DEFAULT NULL,
 p_per_information4 VARCHAR2 DEFAULT NULL,
 p_per_information5 VARCHAR2 DEFAULT NULL,
 p_per_information6 VARCHAR2 DEFAULT NULL,
 p_per_information7 VARCHAR2 DEFAULT NULL,
 p_per_information8 VARCHAR2 DEFAULT NULL,
 p_per_information9 VARCHAR2 DEFAULT NULL,
 p_per_information10 VARCHAR2 DEFAULT NULL,
 p_per_information11 VARCHAR2 DEFAULT NULL,
 p_per_information12 VARCHAR2 DEFAULT NULL,
 p_per_information13 VARCHAR2 DEFAULT NULL,
 p_per_information14 VARCHAR2 DEFAULT NULL,
 p_per_information15 VARCHAR2 DEFAULT NULL,
 p_per_information16 VARCHAR2 DEFAULT NULL,
 p_per_information17 VARCHAR2 DEFAULT NULL,
 p_per_information18 VARCHAR2 DEFAULT NULL,
 p_per_information19 VARCHAR2 DEFAULT NULL,
 p_per_information20 VARCHAR2 DEFAULT NULL,
 p_per_information21 VARCHAR2 DEFAULT NULL,
 p_per_information22 VARCHAR2 DEFAULT NULL,
 p_per_information23 VARCHAR2 DEFAULT NULL,
 p_per_information24 VARCHAR2 DEFAULT NULL,
 p_per_information25 VARCHAR2 DEFAULT NULL,
 p_per_information26 VARCHAR2 DEFAULT NULL,
 p_per_information27 VARCHAR2 DEFAULT NULL,
 p_per_information28 VARCHAR2 DEFAULT NULL,
 p_per_information29 VARCHAR2 DEFAULT NULL,
 p_per_information30 VARCHAR2 DEFAULT NULL);
--
PROCEDURE derive_full_name
(p_first_name    VARCHAR2,
 p_middle_names  VARCHAR2,
 p_last_name     VARCHAR2,
 p_known_as      VARCHAR2,
 p_title         VARCHAR2,
 p_suffix        VARCHAR2,
 p_date_of_birth DATE,
 p_person_id         NUMBER,
 p_business_group_id NUMBER,
 p_full_name OUT NOCOPY VARCHAR2 ,
 p_duplicate_flag OUT NOCOPY VARCHAR2,
 p_per_information1 VARCHAR2 DEFAULT NULL,
 p_per_information2 VARCHAR2 DEFAULT NULL,
 p_per_information3 VARCHAR2 DEFAULT NULL,
 p_per_information4 VARCHAR2 DEFAULT NULL,
 p_per_information5 VARCHAR2 DEFAULT NULL,
 p_per_information6 VARCHAR2 DEFAULT NULL,
 p_per_information7 VARCHAR2 DEFAULT NULL,
 p_per_information8 VARCHAR2 DEFAULT NULL,
 p_per_information9 VARCHAR2 DEFAULT NULL,
 p_per_information10 VARCHAR2 DEFAULT NULL,
 p_per_information11 VARCHAR2 DEFAULT NULL,
 p_per_information12 VARCHAR2 DEFAULT NULL,
 p_per_information13 VARCHAR2 DEFAULT NULL,
 p_per_information14 VARCHAR2 DEFAULT NULL,
 p_per_information15 VARCHAR2 DEFAULT NULL,
 p_per_information16 VARCHAR2 DEFAULT NULL,
 p_per_information17 VARCHAR2 DEFAULT NULL,
 p_per_information18 VARCHAR2 DEFAULT NULL,
 p_per_information19 VARCHAR2 DEFAULT NULL,
 p_per_information20 VARCHAR2 DEFAULT NULL,
 p_per_information21 VARCHAR2 DEFAULT NULL,
 p_per_information22 VARCHAR2 DEFAULT NULL,
 p_per_information23 VARCHAR2 DEFAULT NULL,
 p_per_information24 VARCHAR2 DEFAULT NULL,
 p_per_information25 VARCHAR2 DEFAULT NULL,
 p_per_information26 VARCHAR2 DEFAULT NULL,
 p_per_information27 VARCHAR2 DEFAULT NULL,
 p_per_information28 VARCHAR2 DEFAULT NULL,
 p_per_information29 VARCHAR2 DEFAULT NULL,
 p_per_information30 VARCHAR2 DEFAULT NULL );
--
PROCEDURE derive_full_name
(p_first_name    VARCHAR2,
 p_middle_names  VARCHAR2,
 p_last_name     VARCHAR2,
 p_known_as      VARCHAR2,
 p_title         VARCHAR2,
 p_date_of_birth DATE,
 p_person_id         NUMBER,
 p_business_group_id NUMBER,
 p_full_name OUT NOCOPY VARCHAR2 ,
 p_duplicate_flag OUT NOCOPY VARCHAR2,
 p_per_information1 VARCHAR2 DEFAULT NULL,
 p_per_information2 VARCHAR2 DEFAULT NULL,
 p_per_information3 VARCHAR2 DEFAULT NULL,
 p_per_information4 VARCHAR2 DEFAULT NULL,
 p_per_information5 VARCHAR2 DEFAULT NULL,
 p_per_information6 VARCHAR2 DEFAULT NULL,
 p_per_information7 VARCHAR2 DEFAULT NULL,
 p_per_information8 VARCHAR2 DEFAULT NULL,
 p_per_information9 VARCHAR2 DEFAULT NULL,
 p_per_information10 VARCHAR2 DEFAULT NULL,
 p_per_information11 VARCHAR2 DEFAULT NULL,
 p_per_information12 VARCHAR2 DEFAULT NULL,
 p_per_information13 VARCHAR2 DEFAULT NULL,
 p_per_information14 VARCHAR2 DEFAULT NULL,
 p_per_information15 VARCHAR2 DEFAULT NULL,
 p_per_information16 VARCHAR2 DEFAULT NULL,
 p_per_information17 VARCHAR2 DEFAULT NULL,
 p_per_information18 VARCHAR2 DEFAULT NULL,
 p_per_information19 VARCHAR2 DEFAULT NULL,
 p_per_information20 VARCHAR2 DEFAULT NULL,
 p_per_information21 VARCHAR2 DEFAULT NULL,
 p_per_information22 VARCHAR2 DEFAULT NULL,
 p_per_information23 VARCHAR2 DEFAULT NULL,
 p_per_information24 VARCHAR2 DEFAULT NULL,
 p_per_information25 VARCHAR2 DEFAULT NULL,
 p_per_information26 VARCHAR2 DEFAULT NULL,
 p_per_information27 VARCHAR2 DEFAULT NULL,
 p_per_information28 VARCHAR2 DEFAULT NULL,
 p_per_information29 VARCHAR2 DEFAULT NULL,
 p_per_information30 VARCHAR2 DEFAULT NULL);

--  ------------------- check_ni_unique --------------------
procedure check_ni_unique
( p_national_identifier VARCHAR2,
  p_person_id           NUMBER,
  p_business_group_id   NUMBER);
--
--
-- ------------------- validate_national_identifier -----------------------
--
-- Pass in national identifier and validate both construct (dependent on
-- the legislation of the business group) and uniqueness within business
-- group
--
PROCEDURE validate_national_identifier
( p_national_identifier VARCHAR2,
  p_person_id           NUMBER,
  p_business_group_id   NUMBER);
--
--
-- ----------------------- validate_dob ------------------------------------
--
-- Date of Birth must be greater than start date for employees and applicants
--
PROCEDURE validate_dob
(p_date_of_birth      DATE,
 p_start_date         DATE);
--
--
-- ----------------------- validate_sex_and_title --------------------------
--
-- Validation which should be performed at commit time for any person
--
PROCEDURE validate_sex_and_title(p_current_employee VARCHAR2
                        ,p_sex              VARCHAR2
                        ,p_title            VARCHAR2);
--
-- ----------------------- validate_unique_number --------------------------
--
-- Validation which should be performed at commit time for any person
--
PROCEDURE validate_unique_number(p_person_id          NUMBER
                        ,p_business_group_id  NUMBER
                        ,p_employee_number    VARCHAR2
                        ,p_applicant_number   VARCHAR2
                        ,p_npw_number         VARCHAR2
                        ,p_current_employee   VARCHAR2
                        ,p_current_applicant  VARCHAR2
                        ,p_current_npw        VARCHAR2);
--
--
-- ----------------------- product_installed --------------------------
--
-- Has this product been installed? Return status and oracleid also.
--
  PROCEDURE product_installed (p_application_short_name IN varchar2,
                              p_status          OUT NOCOPY varchar2,
                              p_yes_no          OUT NOCOPY varchar2,
                              p_oracle_username OUT NOCOPY varchar2);
--
-- ----------------------- weak_predel_validation --------------------------
--
-- Weak pre-delete validation called primarily from Delete Person form.
--
  PROCEDURE weak_predel_validation (p_person_id 	IN number,
				    p_session_date	IN date);
--
-- ----------------------- strong_predel_validation --------------------------
--
-- Strong pre-delete validation called from the Enter Person and Applicant
-- Quick Entry forms.
--
  PROCEDURE strong_predel_validation (p_person_id IN number,
				      p_session_date IN date);
--
-- ----------------------- check_contact --------------------------
--
-- Whilst deleteing a contact relationship, is this contact 'used' for
-- anything else? If not then delete this person.
--
  PROCEDURE check_contact (p_person_id                  IN number,
                           p_contact_person_id          IN number,
                           p_contact_relationship_id    IN number,
			   p_session_date		IN date);
--
-- ----------------------- delete_a_person --------------------------
--
-- Delete a person completely from the HR database. Deletes from all tables
-- referencing this person. Used primarily by Delete Person form.
--
  PROCEDURE delete_a_person (p_person_id        IN number,
                             p_form_call        IN boolean,
			     p_session_date	IN date);
--
-- ----------------------- people_default_deletes --------------------------
--
-- Delete people who only have default information entered for them.
-- Used primarily by the Enter Person form.
--
  PROCEDURE people_default_deletes (p_person_id IN number,
                                    p_form_call IN boolean);
--
-- ----------------------- applicant_default_deletes --------------------------
--
-- Delete applicants who only have default information entered for them.
-- Used primarily by the Applicant Quick Entry form.
--
  PROCEDURE applicant_default_deletes (p_person_id      IN number,
                                       p_form_call      IN boolean);
--
------------------------- BEGIN: chk_future_person_type --------------------
FUNCTION chk_future_person_type
        (p_system_person_type IN VARCHAR2
        ,p_person_id IN INTEGER
        ,p_business_group_id IN INTEGER
        ,p_effective_start_date IN DATE) return BOOLEAN;
--
------------------------- BEGIN: chk_future_person_type --------------------
FUNCTION chk_future_person_type
        (p_system_person_type IN VARCHAR2
        ,p_person_id IN INTEGER
        ,p_business_group_id IN INTEGER
        ,p_check_all IN VARCHAR2 DEFAULT 'Y'
        ,p_effective_start_date IN DATE) return BOOLEAN;
--
------------------------- BEGIN: chk_prev_person_type --------------------
FUNCTION chk_prev_person_type
         (p_system_person_type IN VARCHAR2
         ,p_person_id IN INTEGER
         ,p_business_group_id IN INTEGER
         ,p_effective_start_date IN DATE) RETURN BOOLEAN;
--
------------------------- BEGIN: validate_address -------------------------
PROCEDURE validate_address(p_person_id INTEGER
                          ,p_business_group_id INTEGER
                          ,p_address_id INTEGER
                          ,p_date_from DATE
                          ,p_date_to DATE
                          ,p_end_of_time DATE
                          ,p_primary_flag VARCHAR2);
--
end hr_person;

/
