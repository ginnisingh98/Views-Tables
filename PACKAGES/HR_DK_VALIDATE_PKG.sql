--------------------------------------------------------
--  DDL for Package HR_DK_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DK_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pedkvald.pkh 120.2.12000000.1 2007/01/21 21:56:47 appldev ship $ */

  /* Bug fix 4994922, added record type */
  TYPE l_type IS RECORD (value varchar2(5), date1 varchar2(30), date2 varchar2(30));
  TYPE l_rec IS VARRAY(20) OF l_type;


  PROCEDURE person_validate
  (p_person_type_id                 in      number
   ,p_first_name                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  );

  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  );

  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  );

  PROCEDURE contact_cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
   );

  /* Bug Fix 4994922, added parameters p_org_information2 and p_org_information3 */
  PROCEDURE validate_create_org_inf
  (p_org_info_type_code			in	varchar2
  ,p_organization_id			in	number
  ,p_org_information1			in	varchar2
  ,p_org_information2			in	varchar2
  ,p_org_information3			in	varchar2
  ) ;

  /* Bug Fix 4994922, added parameters p_org_information2 and p_org_information3 */
   PROCEDURE validate_update_org_inf
  (p_org_info_type_code			in	 varchar2
  ,p_org_information_id			in       number
  ,p_org_information1			in	 varchar2
  ,p_org_information2			in	 varchar2
  ,p_org_information3			in	 varchar2
  );

   PROCEDURE validate_update_emp_asg
  (p_assignment_id			in	number
  ,p_assignment_status_type_id		in      number
  ,p_segment6				in	varchar2
  ,p_segment7				in	varchar2
  ,p_segment8				in	varchar2
  ,p_segment9				in	varchar2
  );

PROCEDURE validate_create_org_cat
  (p_organization_id		in	number
  ,p_org_information1           in      varchar2
  ) ;

END hr_dk_validate_pkg;


 

/
