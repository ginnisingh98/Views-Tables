--------------------------------------------------------
--  DDL for Package HR_KW_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KW_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pekwvald.pkh 120.0.12000000.1 2007/01/21 23:59:07 appldev ship $ */
  PROCEDURE person_validate
  (p_person_id                      in      number
  ,p_person_type_id                 in      number
  ,p_effective_date                 in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  );

  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_date_received                  in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  );

  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_hire_date                      in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  );

  PROCEDURE contact_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_start_date                     in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  );

  PROCEDURE CWK_VALIDATE
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_start_date                     in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  );


  PROCEDURE CONTRACT_VALIDATE
  (p_effective_date                 in      date
  ,p_type                           in      varchar2
  ,p_duration                       in      number   default null
  ,p_duration_units                 in      varchar2 default null
  ,p_ctr_information_category       in      varchar2 default null
  ,p_ctr_information1               in      varchar2 default null
  ,p_ctr_information2               in      varchar2 default null
  ,p_ctr_information3               in      varchar2 default null
  ,p_ctr_information4               in      varchar2 default null
  ,p_ctr_information5               in      varchar2 default null
  );

  PROCEDURE previous_employer_validate
  (p_employer_name                  IN      varchar2  default hr_api.g_varchar2
  ,p_effective_date                     IN      date      default hr_api.g_date
  ,p_pem_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information1               IN      varchar2  default hr_api.g_varchar2
  );

  PROCEDURE VALIDATE_CREATE_ORG_INF(
      p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT null
     ,p_org_information2               IN  VARCHAR2 DEFAULT null
     ,p_org_information3               IN  VARCHAR2 DEFAULT null
     ,p_org_information4               IN  VARCHAR2 DEFAULT null
     ,p_org_information5               IN  VARCHAR2 DEFAULT null
     ,p_org_information6               IN  VARCHAR2 DEFAULT null
     ,p_org_information7               IN  VARCHAR2 DEFAULT null
     ,p_org_information8               IN  VARCHAR2 DEFAULT null
     ,p_org_information9               IN  VARCHAR2 DEFAULT null
     ,p_org_information10              IN  VARCHAR2 DEFAULT null
   );
  PROCEDURE VALIDATE_UPDATE_ORG_INF(
      p_effective_date                 IN  DATE
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT null
     ,p_org_information2               IN  VARCHAR2 DEFAULT null
     ,p_org_information3               IN  VARCHAR2 DEFAULT null
     ,p_org_information4               IN  VARCHAR2 DEFAULT null
     ,p_org_information5               IN  VARCHAR2 DEFAULT null
     ,p_org_information6               IN  VARCHAR2 DEFAULT null
     ,p_org_information7               IN  VARCHAR2 DEFAULT null
     ,p_org_information8               IN  VARCHAR2 DEFAULT null
     ,p_org_information9               IN  VARCHAR2 DEFAULT null
     ,p_org_information10              IN  VARCHAR2 DEFAULT null
   );

  PROCEDURE ASSIGNMENT_VALIDATE(
      p_segment2                       IN  VARCHAR2
     ,p_effective_date	               IN  DATE
     ,p_assignment_id                  IN  NUMBER
   );

  PROCEDURE DISABILITY_VALIDATE(
       p_effective_date                in     date
      ,p_category                      in     varchar2
      ,p_degree                        in     number   default null
      ,p_dis_information_category      in     varchar2 default null
      ,p_dis_information1              in     varchar2 default null
      ,p_dis_information2              in     varchar2 default null
   );


END HR_KW_VALIDATE_PKG;


 

/
