--------------------------------------------------------
--  DDL for Package HR_CONTACT_RELATIONSHIPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_RELATIONSHIPS" AUTHID CURRENT_USER as
/* $Header: pecon02t.pkh 120.2 2006/02/13 06:12:59 asgugupt noship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
/*---------------------------------------------------------------------------
Description
-----------

Date        Author    Version Description
---------   --------- ------- -------------------------------------------
09-May-94   JRhodes   80.0    Created Initial Version
25-Jan-95   JRhodes   70.4    Added ATTRIBUTE21-30 for people
                              Added REGISTERED_DISABLED_FLAG
05-Jul-95   TMathers  70.5    Added validate_address and check_ppm.
13-Jul-95   TMathers  70.6    Added extra parmeters to check_ppm.
11-Sep-95   SSDesai   70.7    Added check_beneficiary and check_dependent.
18-Jul-97   RKamiyam  70.8    Added per_information1 to 30 and known_as cols
16-Feb-99   ASahay    110.3   Added function multiple_contacts
10-Feb-00   KSivagur  110.4   Added parameters p_pre_name_adjunct and p_suffix
14-NOV-02   MGettins  115.6   Added npw_number parameter to get_person_details.
15-NOV-02   MGettins  115.7   Added dbdrv lines.
04-DEC-02   PKakar    115.8   Added nocopy changes
24-JAN-02   DCasemor  115.9   Overloaded get_person_details.
13-FEB-05   asgugupt  115.10  Overloaded get_person_details for bug no 4957699.
---------------------------------------------------------------------------*/

/* OVERLOADED; includes p_npw_number. This has been overloaded because
   of other team's dependencies on this procedure.  Their code becomes
   invalid unless this is overloaded and due to time constraints it is
   not possible to coordinate the changing of all dependent code. */
PROCEDURE get_person_details
(p_person_id IN NUMBER
,p_session_date IN DATE
,p_first_name IN OUT NOCOPY varchar2
,p_middle_names IN OUT NOCOPY varchar2
,p_pre_name_adjunct IN OUT NOCOPY varchar2
,p_suffix IN OUT NOCOPY varchar2
,p_title IN OUT NOCOPY varchar2
,p_sex IN OUT NOCOPY varchar2
,p_date_of_birth IN OUT NOCOPY DATE
,p_age IN OUT NOCOPY number
,p_employee_number IN OUT NOCOPY varchar2
,p_applicant_number IN OUT NOCOPY varchar2
,p_title_desc IN OUT NOCOPY varchar2
,p_national_identifier IN OUT NOCOPY VARCHAR2
,p_person_type_id IN OUT NOCOPY number
,p_user_person_type IN OUT NOCOPY varchar2
,p_system_person_type IN OUT NOCOPY varchar2
,p_current_employee_flag IN OUT NOCOPY varchar2
,p_current_applicant_flag IN OUT NOCOPY varchar2
,p_current_emp_or_apl_flag IN OUT NOCOPY varchar2
,p_registered_disabled_flag IN OUT NOCOPY varchar2
,p_attribute_category IN OUT NOCOPY varchar2
,p_attribute1 IN OUT NOCOPY varchar2
,p_attribute2 IN OUT NOCOPY varchar2
,p_attribute3 IN OUT NOCOPY varchar2
,p_attribute4 IN OUT NOCOPY varchar2
,p_attribute5 IN OUT NOCOPY varchar2
,p_attribute6 IN OUT NOCOPY varchar2
,p_attribute7 IN OUT NOCOPY varchar2
,p_attribute8 IN OUT NOCOPY varchar2
,p_attribute9 IN OUT NOCOPY varchar2
,p_attribute10 IN OUT NOCOPY varchar2
,p_attribute11 IN OUT NOCOPY varchar2
,p_attribute12 IN OUT NOCOPY varchar2
,p_attribute13 IN OUT NOCOPY varchar2
,p_attribute14 IN OUT NOCOPY varchar2
,p_attribute15 IN OUT NOCOPY varchar2
,p_attribute16 IN OUT NOCOPY varchar2
,p_attribute17 IN OUT NOCOPY varchar2
,p_attribute18 IN OUT NOCOPY varchar2
,p_attribute19 IN OUT NOCOPY varchar2
,p_attribute20 IN OUT NOCOPY varchar2
,p_attribute21 IN OUT NOCOPY varchar2
,p_attribute22 IN OUT NOCOPY varchar2
,p_attribute23 IN OUT NOCOPY varchar2
,p_attribute24 IN OUT NOCOPY varchar2
,p_attribute25 IN OUT NOCOPY varchar2
,p_attribute26 IN OUT NOCOPY varchar2
,p_attribute27 IN OUT NOCOPY varchar2
,p_attribute28 IN OUT NOCOPY varchar2
,p_attribute29 IN OUT NOCOPY varchar2
,p_attribute30 IN OUT NOCOPY varchar2
,p_comment_id IN OUT NOCOPY number
,p_contact_only IN OUT NOCOPY varchar2
,p_per_information_category IN OUT NOCOPY varchar2
,p_per_information1 IN OUT NOCOPY varchar2
,p_per_information2 IN OUT NOCOPY varchar2
,p_per_information3 IN OUT NOCOPY varchar2
,p_per_information4 IN OUT NOCOPY varchar2
,p_per_information5 IN OUT NOCOPY varchar2
,p_per_information6 IN OUT NOCOPY varchar2
,p_per_information7 IN OUT NOCOPY varchar2
,p_per_information8 IN OUT NOCOPY varchar2
,p_per_information9 IN OUT NOCOPY varchar2
,p_per_information10 IN OUT NOCOPY varchar2
,p_per_information11 IN OUT NOCOPY varchar2
,p_per_information12 IN OUT NOCOPY varchar2
,p_per_information13 IN OUT NOCOPY varchar2
,p_per_information14 IN OUT NOCOPY varchar2
,p_per_information15 IN OUT NOCOPY varchar2
,p_per_information16 IN OUT NOCOPY varchar2
,p_per_information17 IN OUT NOCOPY varchar2
,p_per_information18 IN OUT NOCOPY varchar2
,p_per_information19 IN OUT NOCOPY varchar2
,p_per_information20 IN OUT NOCOPY varchar2
,p_per_information21 IN OUT NOCOPY varchar2
,p_per_information22 IN OUT NOCOPY varchar2
,p_per_information23 IN OUT NOCOPY varchar2
,p_per_information24 IN OUT NOCOPY varchar2
,p_per_information25 IN OUT NOCOPY varchar2
,p_per_information26 IN OUT NOCOPY varchar2
,p_per_information27 IN OUT NOCOPY varchar2
,p_per_information28 IN OUT NOCOPY varchar2
,p_per_information29 IN OUT NOCOPY varchar2
,p_per_information30 IN OUT NOCOPY varchar2
,p_known_as          IN OUT NOCOPY varchar2
,p_npw_number        IN OUT NOCOPY varchar2);

PROCEDURE get_person_details
(p_person_id IN NUMBER
,p_session_date IN DATE
,p_first_name IN OUT NOCOPY varchar2
,p_middle_names IN OUT NOCOPY varchar2
,p_pre_name_adjunct IN OUT NOCOPY varchar2
,p_suffix IN OUT NOCOPY varchar2
,p_title IN OUT NOCOPY varchar2
,p_sex IN OUT NOCOPY varchar2
,p_date_of_birth IN OUT NOCOPY DATE
,p_age IN OUT NOCOPY number
,p_employee_number IN OUT NOCOPY varchar2
,p_applicant_number IN OUT NOCOPY varchar2
,p_title_desc IN OUT NOCOPY varchar2
,p_national_identifier IN OUT NOCOPY VARCHAR2
,p_person_type_id IN OUT NOCOPY number
,p_user_person_type IN OUT NOCOPY varchar2
,p_system_person_type IN OUT NOCOPY varchar2
,p_current_employee_flag IN OUT NOCOPY varchar2
,p_current_applicant_flag IN OUT NOCOPY varchar2
,p_current_emp_or_apl_flag IN OUT NOCOPY varchar2
,p_registered_disabled_flag IN OUT NOCOPY varchar2
,p_attribute_category IN OUT NOCOPY varchar2
,p_attribute1 IN OUT NOCOPY varchar2
,p_attribute2 IN OUT NOCOPY varchar2
,p_attribute3 IN OUT NOCOPY varchar2
,p_attribute4 IN OUT NOCOPY varchar2
,p_attribute5 IN OUT NOCOPY varchar2
,p_attribute6 IN OUT NOCOPY varchar2
,p_attribute7 IN OUT NOCOPY varchar2
,p_attribute8 IN OUT NOCOPY varchar2
,p_attribute9 IN OUT NOCOPY varchar2
,p_attribute10 IN OUT NOCOPY varchar2
,p_attribute11 IN OUT NOCOPY varchar2
,p_attribute12 IN OUT NOCOPY varchar2
,p_attribute13 IN OUT NOCOPY varchar2
,p_attribute14 IN OUT NOCOPY varchar2
,p_attribute15 IN OUT NOCOPY varchar2
,p_attribute16 IN OUT NOCOPY varchar2
,p_attribute17 IN OUT NOCOPY varchar2
,p_attribute18 IN OUT NOCOPY varchar2
,p_attribute19 IN OUT NOCOPY varchar2
,p_attribute20 IN OUT NOCOPY varchar2
,p_attribute21 IN OUT NOCOPY varchar2
,p_attribute22 IN OUT NOCOPY varchar2
,p_attribute23 IN OUT NOCOPY varchar2
,p_attribute24 IN OUT NOCOPY varchar2
,p_attribute25 IN OUT NOCOPY varchar2
,p_attribute26 IN OUT NOCOPY varchar2
,p_attribute27 IN OUT NOCOPY varchar2
,p_attribute28 IN OUT NOCOPY varchar2
,p_attribute29 IN OUT NOCOPY varchar2
,p_attribute30 IN OUT NOCOPY varchar2
,p_comment_id IN OUT NOCOPY number
,p_contact_only IN OUT NOCOPY varchar2
,p_per_information_category IN OUT NOCOPY varchar2
,p_per_information1 IN OUT NOCOPY varchar2
,p_per_information2 IN OUT NOCOPY varchar2
,p_per_information3 IN OUT NOCOPY varchar2
,p_per_information4 IN OUT NOCOPY varchar2
,p_per_information5 IN OUT NOCOPY varchar2
,p_per_information6 IN OUT NOCOPY varchar2
,p_per_information7 IN OUT NOCOPY varchar2
,p_per_information8 IN OUT NOCOPY varchar2
,p_per_information9 IN OUT NOCOPY varchar2
,p_per_information10 IN OUT NOCOPY varchar2
,p_per_information11 IN OUT NOCOPY varchar2
,p_per_information12 IN OUT NOCOPY varchar2
,p_per_information13 IN OUT NOCOPY varchar2
,p_per_information14 IN OUT NOCOPY varchar2
,p_per_information15 IN OUT NOCOPY varchar2
,p_per_information16 IN OUT NOCOPY varchar2
,p_per_information17 IN OUT NOCOPY varchar2
,p_per_information18 IN OUT NOCOPY varchar2
,p_per_information19 IN OUT NOCOPY varchar2
,p_per_information20 IN OUT NOCOPY varchar2
,p_per_information21 IN OUT NOCOPY varchar2
,p_per_information22 IN OUT NOCOPY varchar2
,p_per_information23 IN OUT NOCOPY varchar2
,p_per_information24 IN OUT NOCOPY varchar2
,p_per_information25 IN OUT NOCOPY varchar2
,p_per_information26 IN OUT NOCOPY varchar2
,p_per_information27 IN OUT NOCOPY varchar2
,p_per_information28 IN OUT NOCOPY varchar2
,p_per_information29 IN OUT NOCOPY varchar2
,p_per_information30 IN OUT NOCOPY varchar2
,p_known_as          IN OUT NOCOPY varchar2);
-- fix for bug 4957699 starts here.
PROCEDURE get_person_details
(p_person_id IN NUMBER
,p_session_date IN DATE
,p_first_name IN OUT NOCOPY varchar2
,p_middle_names IN OUT NOCOPY varchar2
,p_pre_name_adjunct IN OUT NOCOPY varchar2
,p_suffix IN OUT NOCOPY varchar2
,p_title IN OUT NOCOPY varchar2
,p_sex IN OUT NOCOPY varchar2
,p_date_of_birth IN OUT NOCOPY DATE
,p_age IN OUT NOCOPY number
,p_employee_number IN OUT NOCOPY varchar2
,p_applicant_number IN OUT NOCOPY varchar2
,p_title_desc IN OUT NOCOPY varchar2
,p_national_identifier IN OUT NOCOPY VARCHAR2
,p_person_type_id IN OUT NOCOPY number
,p_user_person_type IN OUT NOCOPY varchar2
,p_system_person_type IN OUT NOCOPY varchar2
,p_current_employee_flag IN OUT NOCOPY varchar2
,p_current_applicant_flag IN OUT NOCOPY varchar2
,p_current_emp_or_apl_flag IN OUT NOCOPY varchar2
,p_registered_disabled_flag IN OUT NOCOPY varchar2
,p_attribute_category IN OUT NOCOPY varchar2
,p_attribute1 IN OUT NOCOPY varchar2
,p_attribute2 IN OUT NOCOPY varchar2
,p_attribute3 IN OUT NOCOPY varchar2
,p_attribute4 IN OUT NOCOPY varchar2
,p_attribute5 IN OUT NOCOPY varchar2
,p_attribute6 IN OUT NOCOPY varchar2
,p_attribute7 IN OUT NOCOPY varchar2
,p_attribute8 IN OUT NOCOPY varchar2
,p_attribute9 IN OUT NOCOPY varchar2
,p_attribute10 IN OUT NOCOPY varchar2
,p_attribute11 IN OUT NOCOPY varchar2
,p_attribute12 IN OUT NOCOPY varchar2
,p_attribute13 IN OUT NOCOPY varchar2
,p_attribute14 IN OUT NOCOPY varchar2
,p_attribute15 IN OUT NOCOPY varchar2
,p_attribute16 IN OUT NOCOPY varchar2
,p_attribute17 IN OUT NOCOPY varchar2
,p_attribute18 IN OUT NOCOPY varchar2
,p_attribute19 IN OUT NOCOPY varchar2
,p_attribute20 IN OUT NOCOPY varchar2
,p_attribute21 IN OUT NOCOPY varchar2
,p_attribute22 IN OUT NOCOPY varchar2
,p_attribute23 IN OUT NOCOPY varchar2
,p_attribute24 IN OUT NOCOPY varchar2
,p_attribute25 IN OUT NOCOPY varchar2
,p_attribute26 IN OUT NOCOPY varchar2
,p_attribute27 IN OUT NOCOPY varchar2
,p_attribute28 IN OUT NOCOPY varchar2
,p_attribute29 IN OUT NOCOPY varchar2
,p_attribute30 IN OUT NOCOPY varchar2
,p_comment_id IN OUT NOCOPY number
,p_contact_only IN OUT NOCOPY varchar2
,p_per_information_category IN OUT NOCOPY varchar2
,p_per_information1 IN OUT NOCOPY varchar2
,p_per_information2 IN OUT NOCOPY varchar2
,p_per_information3 IN OUT NOCOPY varchar2
,p_per_information4 IN OUT NOCOPY varchar2
,p_per_information5 IN OUT NOCOPY varchar2
,p_per_information6 IN OUT NOCOPY varchar2
,p_per_information7 IN OUT NOCOPY varchar2
,p_per_information8 IN OUT NOCOPY varchar2
,p_per_information9 IN OUT NOCOPY varchar2
,p_per_information10 IN OUT NOCOPY varchar2
,p_per_information11 IN OUT NOCOPY varchar2
,p_per_information12 IN OUT NOCOPY varchar2
,p_per_information13 IN OUT NOCOPY varchar2
,p_per_information14 IN OUT NOCOPY varchar2
,p_per_information15 IN OUT NOCOPY varchar2
,p_per_information16 IN OUT NOCOPY varchar2
,p_per_information17 IN OUT NOCOPY varchar2
,p_per_information18 IN OUT NOCOPY varchar2
,p_per_information19 IN OUT NOCOPY varchar2
,p_per_information20 IN OUT NOCOPY varchar2
,p_per_information21 IN OUT NOCOPY varchar2
,p_per_information22 IN OUT NOCOPY varchar2
,p_per_information23 IN OUT NOCOPY varchar2
,p_per_information24 IN OUT NOCOPY varchar2
,p_per_information25 IN OUT NOCOPY varchar2
,p_per_information26 IN OUT NOCOPY varchar2
,p_per_information27 IN OUT NOCOPY varchar2
,p_per_information28 IN OUT NOCOPY varchar2
,p_per_information29 IN OUT NOCOPY varchar2
,p_per_information30 IN OUT NOCOPY varchar2
,p_known_as          IN OUT NOCOPY varchar2
,p_npw_number        IN OUT NOCOPY varchar2
,p_date_of_death     IN OUT NOCOPY DATE);
 -- fix for bug 4957699 ends here.
FUNCTION contact_only(p_person_id number) return VARCHAR2;

FUNCTION multiple_contacts(p_person_id number) return VARCHAR2;

PROCEDURE get_default_ctype(p_business_group_id number
                           ,p_def_type_id IN OUT NOCOPY number
                           ,p_def_type IN OUT NOCOPY varchar2
                           ,p_def_sys_type IN OUT NOCOPY varchar2);

FUNCTION get_application(p_form_name VARCHAR2) return VARCHAR2;

FUNCTION validate_address(p_contact_id NUMBER) RETURN BOOLEAN;
--
PROCEDURE check_ppm(p_contact_id NUMBER
                    ,p_contact_relationship_id  NUMBER
                    ,p_mode VARCHAR2);
--
PROCEDURE check_beneficiary(p_person_id NUMBER, p_contact_id NUMBER);
--
PROCEDURE check_dependent(p_contact_relationship_id NUMBER);
--
END HR_CONTACT_RELATIONSHIPS;

 

/
