--------------------------------------------------------
--  DDL for Package Body HR_CONTACT_RELATIONSHIPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTACT_RELATIONSHIPS" as
/* $Header: pecon02t.pkb 120.2 2006/02/13 06:08:37 asgugupt noship $ */
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
09-Nov-94   RFine     70.3    Suppressed index on business_group_id
25-Jan-95   JRhodes   70.5    Added ATTRIBUTE21-30 for People
                              Added REGISTERED_DISABLED_FLAG
05-Jul-95   TMathers  70.6    Added validate_address and check_ppm.
13-Jul-95   TMathers  70.7    Added extra parameters to check_ppm.
                              do it could be used for both insert and update
13-Jul-95   TMathers  70.8    Added Message HR_7874_GARNISHMENT_IS_PAYEE
14-Jul-95   TMathers  70.9    Add check for mirror relationship.
11-Sep-95   SSDesai   70.10   Added check_beneficiary, check_dependent.
10-Oct-95   SSDesai   70.12   Added messages for check_beneficiary/dependent.
18-Jul-97   RKamiyam  70.13   Added per_information1 to 30 and known_as cols.
02-Mar-98   SKamatka  110.3   Bug #622399: Changed contact_only function.
			      Contact won't be deleted if it has relationship
			      with more than one person.
25-Nov-98   ASahay    110.4   Bug 768997 Modified if condition to check for
			      greater than 1 only
05-Feb-99   LSigrist  110.5   Updated cursors 'get_person', and 'c' with MLS
                              changes. Also, checked to ensure date formats
                              are release 11.5 compliant.
16-Feb-99   ASahay    115.3   Bug 820655 Added function multiple_contacts
                              to_check for multiple relationships
10-Apr-00  KSivagur   115.4   added parameters p_pre_name_adjunct and p_suffix
                              to the get_person_details procedure.
13-Mar-01  KSivagur   115.5   added parameter per_information_catergory.
21-Aug-01  adhunter   115.6   PTU changes to get person type from new function.
12-Oct-01  adhunter   115.7   1766066: Redid multiple contacts function.
14-Nov-02  MGettins   115.9   Added npw_number parameter to get_person_details.
15-NOV-02  MGettins   115.10  Added dbdrv lines.
04-DEC-02  PKakar     115.11  Added nocopy changes
25-JAN-03  DCasemor   115.12  Overloaded get_person_details so that
                              p_npw_number is not mandatory.
10-JUL-03  MGettins   115.13  Modified cursor in Contact_Only procedure as
                              part of fix for bug 3040059.
14-OCT-03  jpthomas   115.13  Modified the cursor to exclude the system person types
			      for the benefits.
21-JUN-04  adudekul   115.14  Bug 3648765. Fix to performance issues.
13-FEB-05  asgugupt   115.16  Overloaded get_person_details for bug no 4957699.
---------------------------------------------------------------------------*/


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
) is

  l_npw_number per_all_people_f.npw_number%TYPE;

BEGIN

  /* Call the overloaded procedure. */
  get_person_details
    (p_person_id                => p_person_id
    ,p_session_date             => p_session_date
    ,p_first_name               => p_first_name
    ,p_middle_names             => p_middle_names
    ,p_pre_name_adjunct         => p_pre_name_adjunct
    ,p_suffix                   => p_suffix
    ,p_title                    => p_title
    ,p_sex                      => p_sex
    ,p_date_of_birth            => p_date_of_birth
    ,p_age                      => p_age
    ,p_employee_number          => p_employee_number
    ,p_applicant_number         => p_applicant_number
    ,p_title_desc               => p_title_desc
    ,p_national_identifier      => p_national_identifier
    ,p_person_type_id           => p_person_type_id
    ,p_user_person_type         => p_user_person_type
    ,p_system_person_type       => p_system_person_type
    ,p_current_employee_flag    => p_current_employee_flag
    ,p_current_applicant_flag   => p_current_applicant_flag
    ,p_current_emp_or_apl_flag  => p_current_emp_or_apl_flag
    ,p_registered_disabled_flag => p_registered_disabled_flag
    ,p_attribute_category       => p_attribute_category
    ,p_attribute1               => p_attribute1
    ,p_attribute2               => p_attribute2
    ,p_attribute3               => p_attribute3
    ,p_attribute4               => p_attribute4
    ,p_attribute5               => p_attribute5
    ,p_attribute6               => p_attribute6
    ,p_attribute7               => p_attribute7
    ,p_attribute8               => p_attribute8
    ,p_attribute9               => p_attribute9
    ,p_attribute10              => p_attribute10
    ,p_attribute11              => p_attribute11
    ,p_attribute12              => p_attribute12
    ,p_attribute13              => p_attribute13
    ,p_attribute14              => p_attribute14
    ,p_attribute15              => p_attribute15
    ,p_attribute16              => p_attribute16
    ,p_attribute17              => p_attribute17
    ,p_attribute18              => p_attribute18
    ,p_attribute19              => p_attribute19
    ,p_attribute20              => p_attribute20
    ,p_attribute21              => p_attribute21
    ,p_attribute22              => p_attribute22
    ,p_attribute23              => p_attribute23
    ,p_attribute24              => p_attribute24
    ,p_attribute25              => p_attribute25
    ,p_attribute26              => p_attribute26
    ,p_attribute27              => p_attribute27
    ,p_attribute28              => p_attribute28
    ,p_attribute29              => p_attribute29
    ,p_attribute30              => p_attribute30
    ,p_comment_id               => p_comment_id
    ,p_contact_only             => p_contact_only
    ,p_per_information_category => p_per_information_category
    ,p_per_information1         => p_per_information1
    ,p_per_information2         => p_per_information2
    ,p_per_information3         => p_per_information3
    ,p_per_information4         => p_per_information4
    ,p_per_information5         => p_per_information5
    ,p_per_information6         => p_per_information6
    ,p_per_information7         => p_per_information7
    ,p_per_information8         => p_per_information8
    ,p_per_information9         => p_per_information9
    ,p_per_information10        => p_per_information10
    ,p_per_information11        => p_per_information11
    ,p_per_information12        => p_per_information12
    ,p_per_information13        => p_per_information13
    ,p_per_information14        => p_per_information14
    ,p_per_information15        => p_per_information15
    ,p_per_information16        => p_per_information16
    ,p_per_information17        => p_per_information17
    ,p_per_information18        => p_per_information18
    ,p_per_information19        => p_per_information19
    ,p_per_information20        => p_per_information20
    ,p_per_information21        => p_per_information21
    ,p_per_information22        => p_per_information22
    ,p_per_information23        => p_per_information23
    ,p_per_information24        => p_per_information24
    ,p_per_information25        => p_per_information25
    ,p_per_information26        => p_per_information26
    ,p_per_information27        => p_per_information27
    ,p_per_information28        => p_per_information28
    ,p_per_information29        => p_per_information29
    ,p_per_information30        => p_per_information30
    ,p_known_as                 => p_known_as
    ,p_npw_number               => l_npw_number);

END get_person_details;

/* Overloaded, includes p_npw_number */
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
,p_npw_number        IN OUT NOCOPY varchar2) is

 l_date_of_death		per_all_people_f.date_of_death%TYPE;

BEGIN
  /* Call the overloaded procedure. */
  get_person_details
    (p_person_id                => p_person_id
    ,p_session_date             => p_session_date
    ,p_first_name               => p_first_name
    ,p_middle_names             => p_middle_names
    ,p_pre_name_adjunct         => p_pre_name_adjunct
    ,p_suffix                   => p_suffix
    ,p_title                    => p_title
    ,p_sex                      => p_sex
    ,p_date_of_birth            => p_date_of_birth
    ,p_age                      => p_age
    ,p_employee_number          => p_employee_number
    ,p_applicant_number         => p_applicant_number
    ,p_title_desc               => p_title_desc
    ,p_national_identifier      => p_national_identifier
    ,p_person_type_id           => p_person_type_id
    ,p_user_person_type         => p_user_person_type
    ,p_system_person_type       => p_system_person_type
    ,p_current_employee_flag    => p_current_employee_flag
    ,p_current_applicant_flag   => p_current_applicant_flag
    ,p_current_emp_or_apl_flag  => p_current_emp_or_apl_flag
    ,p_registered_disabled_flag => p_registered_disabled_flag
    ,p_attribute_category       => p_attribute_category
    ,p_attribute1               => p_attribute1
    ,p_attribute2               => p_attribute2
    ,p_attribute3               => p_attribute3
    ,p_attribute4               => p_attribute4
    ,p_attribute5               => p_attribute5
    ,p_attribute6               => p_attribute6
    ,p_attribute7               => p_attribute7
    ,p_attribute8               => p_attribute8
    ,p_attribute9               => p_attribute9
    ,p_attribute10              => p_attribute10
    ,p_attribute11              => p_attribute11
    ,p_attribute12              => p_attribute12
    ,p_attribute13              => p_attribute13
    ,p_attribute14              => p_attribute14
    ,p_attribute15              => p_attribute15
    ,p_attribute16              => p_attribute16
    ,p_attribute17              => p_attribute17
    ,p_attribute18              => p_attribute18
    ,p_attribute19              => p_attribute19
    ,p_attribute20              => p_attribute20
    ,p_attribute21              => p_attribute21
    ,p_attribute22              => p_attribute22
    ,p_attribute23              => p_attribute23
    ,p_attribute24              => p_attribute24
    ,p_attribute25              => p_attribute25
    ,p_attribute26              => p_attribute26
    ,p_attribute27              => p_attribute27
    ,p_attribute28              => p_attribute28
    ,p_attribute29              => p_attribute29
    ,p_attribute30              => p_attribute30
    ,p_comment_id               => p_comment_id
    ,p_contact_only             => p_contact_only
    ,p_per_information_category => p_per_information_category
    ,p_per_information1         => p_per_information1
    ,p_per_information2         => p_per_information2
    ,p_per_information3         => p_per_information3
    ,p_per_information4         => p_per_information4
    ,p_per_information5         => p_per_information5
    ,p_per_information6         => p_per_information6
    ,p_per_information7         => p_per_information7
    ,p_per_information8         => p_per_information8
    ,p_per_information9         => p_per_information9
    ,p_per_information10        => p_per_information10
    ,p_per_information11        => p_per_information11
    ,p_per_information12        => p_per_information12
    ,p_per_information13        => p_per_information13
    ,p_per_information14        => p_per_information14
    ,p_per_information15        => p_per_information15
    ,p_per_information16        => p_per_information16
    ,p_per_information17        => p_per_information17
    ,p_per_information18        => p_per_information18
    ,p_per_information19        => p_per_information19
    ,p_per_information20        => p_per_information20
    ,p_per_information21        => p_per_information21
    ,p_per_information22        => p_per_information22
    ,p_per_information23        => p_per_information23
    ,p_per_information24        => p_per_information24
    ,p_per_information25        => p_per_information25
    ,p_per_information26        => p_per_information26
    ,p_per_information27        => p_per_information27
    ,p_per_information28        => p_per_information28
    ,p_per_information29        => p_per_information29
    ,p_per_information30        => p_per_information30
    ,p_known_as                 => p_known_as
    ,p_npw_number               => p_npw_number
    ,p_date_of_death            => l_date_of_death);

END get_person_details;

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
-- fix for bug 4957699 starts here.
,p_date_of_death    IN OUT NOCOPY DATE
) is
-- fix for bug 4957699 ends here.
cursor get_person is
select per.last_name
      ,per.first_name
      ,per.middle_names
      ,per.pre_name_adjunct
      ,per.suffix
      ,per.title
      ,per.sex
      ,per.date_of_birth
      ,trunc(months_between(p_session_date, per.date_of_birth)/12) age
      ,per.employee_number
      ,per.applicant_number
      ,per.full_name
      ,t.meaning title_desc
      ,per.national_identifier
      ,per.person_type_id
      ,pttl.user_person_type
      ,pt.system_person_type
      ,per.current_employee_flag
      ,per.current_applicant_flag
      ,per.current_emp_or_apl_flag
      ,per.registered_disabled_flag
      ,per.attribute_category
      ,per.attribute1
      ,per.attribute2
      ,per.attribute3
      ,per.attribute4
      ,per.attribute5
      ,per.attribute6
      ,per.attribute7
      ,per.attribute8
      ,per.attribute9
      ,per.attribute10
      ,per.attribute11
      ,per.attribute12
      ,per.attribute13
      ,per.attribute14
      ,per.attribute15
      ,per.attribute16
      ,per.attribute17
      ,per.attribute18
      ,per.attribute19
      ,per.attribute20
      ,per.attribute21
      ,per.attribute22
      ,per.attribute23
      ,per.attribute24
      ,per.attribute25
      ,per.attribute26
      ,per.attribute27
      ,per.attribute28
      ,per.attribute29
      ,per.attribute30
      ,per.comment_id
      ,per.per_information_category
      ,per.per_information1
      ,per.per_information2
      ,per.per_information3
      ,per.per_information4
      ,per.per_information5
      ,per.per_information6
      ,per.per_information7
      ,per.per_information8
      ,per.per_information9
      ,per.per_information10
      ,per.per_information11
      ,per.per_information12
      ,per.per_information13
      ,per.per_information14
      ,per.per_information15
      ,per.per_information16
      ,per.per_information17
      ,per.per_information18
      ,per.per_information19
      ,per.per_information20
      ,per.per_information21
      ,per.per_information22
      ,per.per_information23
      ,per.per_information24
      ,per.per_information25
      ,per.per_information26
      ,per.per_information27
      ,per.per_information28
      ,per.per_information29
      ,per.per_information30
      ,per.known_as
-- fix for bug 4957699 starts here.
      ,per.date_of_death
-- fix for bug 4957699 starts here.
      ,npw_number
from   hr_lookups t
      ,per_person_types_tl pttl
      ,per_person_types    pt
      ,per_all_people_f    per
where pt.person_type_id = pttl.person_type_id
and   t.lookup_type(+) = 'TITLE'
and   t.lookup_code(+) = per.title
and   per.person_type_id = pt.person_type_id
and   per.person_id = p_person_id
and   p_session_date between
          per.effective_start_date and per.effective_end_date
and   pttl.LANGUAGE = userenv('LANG');
--
person_row get_person%rowtype;
--
begin
   open get_person;
   fetch get_person into person_row;
   close get_person;
   --
   p_first_name := person_row.first_name;
   p_middle_names := person_row.middle_names;
   p_pre_name_adjunct := person_row.pre_name_adjunct;
   p_suffix := person_row.suffix;
   p_title := person_row.title;
   p_sex := person_row.sex;
   p_date_of_birth := person_row.date_of_birth;
   p_age := person_row.age;
   p_employee_number := person_row.employee_number;
   p_applicant_number := person_row.applicant_number;
   p_title_desc := person_row.title_desc;
   p_national_identifier := person_row.national_identifier;
   p_person_type_id := person_row.person_type_id;
   p_user_person_type :=    --person_row.user_person_type;
                          hr_person_type_usage_info.get_user_person_type
                             (p_session_date,p_person_id);
   p_system_person_type := person_row.system_person_type;
   p_current_employee_flag := person_row.current_employee_flag;
   p_current_applicant_flag := person_row.current_applicant_flag;
   p_current_emp_or_apl_flag := person_row.current_emp_or_apl_flag;
   p_registered_disabled_flag := person_row.registered_disabled_flag;
   p_attribute_category := person_row.attribute_category;
   p_attribute1 := person_row.attribute1;
   p_attribute2 := person_row.attribute2;
   p_attribute3 := person_row.attribute3;
   p_attribute4 := person_row.attribute4;
   p_attribute5 := person_row.attribute5;
   p_attribute6 := person_row.attribute6;
   p_attribute7 := person_row.attribute7;
   p_attribute8 := person_row.attribute8;
   p_attribute9 := person_row.attribute9;
   p_attribute10 := person_row.attribute10;
   p_attribute11 := person_row.attribute11;
   p_attribute12 := person_row.attribute12;
   p_attribute13 := person_row.attribute13;
   p_attribute14 := person_row.attribute14;
   p_attribute15 := person_row.attribute15;
   p_attribute16 := person_row.attribute16;
   p_attribute17 := person_row.attribute17;
   p_attribute18 := person_row.attribute18;
   p_attribute19 := person_row.attribute19;
   p_attribute20 := person_row.attribute20;
   p_attribute21 := person_row.attribute21;
   p_attribute22 := person_row.attribute22;
   p_attribute23 := person_row.attribute23;
   p_attribute24 := person_row.attribute24;
   p_attribute25 := person_row.attribute25;
   p_attribute26 := person_row.attribute26;
   p_attribute27 := person_row.attribute27;
   p_attribute28 := person_row.attribute28;
   p_attribute29 := person_row.attribute29;
   p_attribute30 := person_row.attribute30;
   p_comment_id := person_row.comment_id;
   p_per_information_category := person_row.per_information_category;
   p_per_information1 := person_row.per_information1;
   p_per_information2 := person_row.per_information2;
   p_per_information3 := person_row.per_information3;
   p_per_information4 := person_row.per_information4;
   p_per_information5 := person_row.per_information5;
   p_per_information6 := person_row.per_information6;
   p_per_information7 := person_row.per_information7;
   p_per_information8 := person_row.per_information8;
   p_per_information9 := person_row.per_information9;
   p_per_information10 := person_row.per_information10;
   p_per_information11 := person_row.per_information11;
   p_per_information12 := person_row.per_information12;
   p_per_information13 := person_row.per_information13;
   p_per_information14 := person_row.per_information14;
   p_per_information15 := person_row.per_information15;
   p_per_information16 := person_row.per_information16;
   p_per_information17 := person_row.per_information17;
   p_per_information18 := person_row.per_information18;
   p_per_information19 := person_row.per_information19;
   p_per_information20 := person_row.per_information20;
   p_per_information21 := person_row.per_information21;
   p_per_information22 := person_row.per_information22;
   p_per_information23 := person_row.per_information23;
   p_per_information24 := person_row.per_information24;
   p_per_information25 := person_row.per_information25;
   p_per_information26 := person_row.per_information26;
   p_per_information27 := person_row.per_information27;
   p_per_information28 := person_row.per_information28;
   p_per_information29 := person_row.per_information29;
   p_per_information30 := person_row.per_information30;
   p_known_as          := person_row.known_as;
   p_npw_number        := person_row.npw_number;
-- fix for bug 4957699 starts here.
   p_date_of_death     := person_row.date_of_death;
-- fix for bug 4957699 ends here.
--
   p_contact_only := contact_only(p_person_id);
end get_person_details;


FUNCTION multiple_contacts(p_person_id number) return VARCHAR2 is

-- Bug 820655
-- this function has been created  from contact_only to check
-- for for more than one relationships

-- Following cursor will return the number relationships
-- existing for a contact. ( Ref Bug # 622399 )

CURSOR csr_count_relationships IS
select count(*)
from    per_contact_relationships
where   contact_person_id = p_person_id;

l_exists varchar2(1);
l_count  number;

begin

-- Bug 2017198: changed the check, if check is done after the delete of rship we need only
-- see that no rows remain for the person as the contact_person_id
-- Mirrors don't necessarily exist so no need to check against person_id
      open csr_count_relationships;
      fetch csr_count_relationships into l_count;
      close csr_count_relationships;
       if l_count >= 1  then
        return('Y');
      end if;
      return('N');
end multiple_contacts;

FUNCTION contact_only(p_person_id number) return VARCHAR2 is

--

/* Drive of person type usages table */
/*
CURSOR C is
select 'Y'
from per_all_people_f papf, per_person_types ppt
where papf.person_id = p_person_id
and papf.person_type_id = ppt.person_type_id
and ppt.system_person_type = 'OTHER'
and papf.effective_end_date = hr_general.end_of_time;*/
--
--Bug 3179566 Start here
--Description : Modified the cursor to include all the varriants of the
--		system person types 'EMP', 'APL','CWK'.
--

  CURSOR c IS
    SELECT 'Y'
    FROM   per_person_type_usages_f ptu,
           per_person_types ppt
    WHERE  (  ppt.system_person_type like '%EMP%'
              or ppt.system_person_type like '%APL%'
	      or ppt.system_person_type like '%CWK%')
    AND    ppt.person_type_Id = ptu.person_type_id
    AND    ptu.person_id = p_person_id
    AND    ptu.effective_end_Date = hr_general.end_of_time;

--
--Bug 3179566 End Here
--
l_exists varchar2(1);
--
begin

   open C;
   fetch C into l_exists;
   close C;
   if l_exists = 'Y' then
      return('N');
   end if;
   return('Y');

end contact_only;

PROCEDURE get_default_ctype(p_business_group_id number
                           ,p_def_type_id IN OUT NOCOPY number
                           ,p_def_type IN OUT NOCOPY varchar2
                           ,p_def_sys_type IN OUT NOCOPY varchar2) is
CURSOR c is
select pt.person_type_id
,      pttl.user_person_type
,      pt.system_person_type
from   per_person_types_tl pttl,
       per_person_types pt
where  pt.system_person_type = 'OTHER'
and    pt.default_flag = 'Y'
and    pt.active_flag = 'Y'
and    pt.business_group_id  = p_business_group_id
and    pt.person_type_id = pttl.person_type_id
and    pttl.LANGUAGE = userenv('LANG');
--
begin
   open c;
   fetch c into p_def_type_id, p_def_type, p_def_sys_type;
   close c;
end get_default_ctype;

FUNCTION get_application(p_form_name VARCHAR2) return VARCHAR2 is
l_appl_short_name varchar2(30);
--
CURSOR application is
select a.application_short_name
from fnd_application a
,    fnd_form f
where a.application_id = f.application_id
and   f.form_name = p_form_name;
--
begin
   open application;
   fetch application into l_appl_short_name;
   close application;
--
   return(l_appl_short_name);
end;
--
FUNCTION validate_address(p_contact_id NUMBER) RETURN BOOLEAN
is
l_dummy VARCHAR2(1);
cursor address_exists
is
select 'Y'
from per_addresses pa
where pa.person_id = p_contact_id;
--
Begin
   open address_exists;
   fetch address_exists into l_dummy;
   if address_exists%NOTFOUND
   then
     hr_utility.set_message(801,'PAY_ASSIGNEE_NO_ADDRESS');
     return FALSE;
   end if;
   close address_exists;
   RETURN TRUE;
end validate_address;
--
PROCEDURE check_ppm(p_contact_id NUMBER
                    ,p_contact_relationship_id  NUMBER
                    ,p_mode VARCHAR2)
is
l_dummy VARCHAR2(1);
l_contact_relationship_id NUMBER;
l_contact_id NUMBER;
--
Cursor get_mirror is
select pcr1.contact_relationship_id
,      pcr1.contact_person_id
from   per_contact_relationships pcr1
where exists (select 1
              from per_contact_relationships pcr2
              where contact_relationship_id = p_contact_relationship_id
              and pcr1.contact_person_id = pcr2.person_id
             );
--
Cursor check_garnishor(l_contact_id NUMBER,l_contact_relationship_id NUMBER)
is select '1'
from pay_personal_payment_methods_f ppm
, per_assignments_f paf
, per_contact_relationships pcr
, fnd_sessions f
where ppm.payee_type = 'P'
and   ppm.payee_id   = l_contact_id
and   ppm.assignment_id = paf.assignment_id
and   paf.person_id  = pcr.person_id
and   pcr.contact_relationship_id = l_contact_relationship_id
and   f.session_id   = userenv('sessionid')
and   f.effective_date between
   ppm.effective_start_date and ppm.effective_end_date;
Begin
  open get_mirror;
  fetch get_mirror into l_contact_relationship_id,l_contact_id;
  close get_mirror;
  --
  open check_garnishor(p_contact_id,p_contact_relationship_id);
  fetch check_garnishor into l_dummy;
  if check_garnishor%FOUND
  then
    if p_mode = 'D' -- delete message
    then
      hr_utility.set_message(801,'PAY_GARNISHOR_PAYMENT_METHOD');
      hr_utility.raise_error;
    else
      hr_utility.set_message(801,'HR_7874_GARNISHMENT_IS_PAYEE');
      hr_utility.raise_error;
    end if;
  end if;
  close check_garnishor;
  open check_garnishor(l_contact_id,l_contact_relationship_id);
  fetch check_garnishor into l_dummy;
  if check_garnishor%FOUND
  then
    if p_mode = 'D' -- delete message
    then
      hr_utility.set_message(801,'PAY_GARNISHOR_PAYMENT_METHOD');
      hr_utility.raise_error;
    else
      hr_utility.set_message(801,'HR_7874_GARNISHMENT_IS_PAYEE');
      hr_utility.raise_error;
    end if;
  end if;
  close check_garnishor;
end check_ppm;
--
--
PROCEDURE check_beneficiary(p_person_id NUMBER, p_contact_id NUMBER) is
--
-- when unchecking the beneficiary flag in the contact form, check that
-- the contact is not designated as a beneficiary for the person.
--
  cursor cur_ben is
    select 'Y'
    from
	   fnd_sessions		   fnd,
	   per_assignments_f	   asg,
	   pay_element_entries_f   ent,
	   ben_beneficiaries_f     ben
    where  ben.source_id   		= p_contact_id
    and    ben.source_type 		= 'P'
    and    ben.element_entry_id  	= ent.element_entry_id
    and    ent.assignment_id		= asg.assignment_id
    and    asg.person_id + 0		= p_person_id
    and    fnd.session_id		= userenv('sessionid')
    --
    -- check that the contact is currently designated as a beneficiary
    -- or is designated as a beneficiary in the future.
    --
    and    (fnd.effective_date between asg.effective_start_date
		and asg.effective_end_date
            or fnd.effective_date < asg.effective_start_date)
   and     (fnd.effective_date between ent.effective_start_date
		and ent.effective_end_date
            or fnd.effective_date < ent.effective_start_date)
   and	   (fnd.effective_date between ben.effective_start_date
		and ben.effective_end_date
	    or fnd.effective_date < ent.effective_start_date);
  --
  l_check varchar2(1);
  --
  begin
    open cur_ben;
    fetch cur_ben into l_check;
    close cur_ben;
    --
    if l_check = 'Y' then
      hr_utility.set_message(801,'HR_CONTACT_MARKED_AS_BENF');
      hr_utility.raise_error;
    end if;
    --
  end check_beneficiary;
--
PROCEDURE check_dependent (p_contact_relationship_id NUMBER) is
  cursor cur_dep is
     select 'Y'
     from
	    fnd_sessions	     fnd,
	    ben_covered_dependents_f dep
     where  dep.contact_relationship_id = p_contact_relationship_id
     and    fnd.session_id              = userenv('sessionid')
     and    (fnd.effective_date between dep.effective_start_date
		and dep.effective_end_date
	     or fnd.effective_date < dep.effective_start_date);
  --
  l_check varchar2(1);
  --
  begin
    open cur_dep;
    fetch cur_dep into l_check;
    close cur_dep;
    --
    if l_check = 'Y' then
      hr_utility.set_message(801,'HR_CONTACT_MARKED_AS_COVDEP');
      hr_utility.raise_error;
    end if;
    --
  end check_dependent;
--
--
END HR_CONTACT_RELATIONSHIPS;

/
