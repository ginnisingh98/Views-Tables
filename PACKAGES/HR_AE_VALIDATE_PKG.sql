--------------------------------------------------------
--  DDL for Package HR_AE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AE_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: peaevald.pkh 120.2 2006/12/22 09:39:09 spendhar noship $ */
  PROCEDURE person_validate
  (p_person_id                      in      number
  ,p_person_type_id                 in      number
  ,p_effective_date                 in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
  );

  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_date_received                  in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
  );

  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_hire_date                      in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
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
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
  );

  PROCEDURE cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_start_date                     in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
  );
  --
  PROCEDURE contract_validate
  (p_effective_date                 IN      DATE
  ,p_type                           IN      VARCHAR2
  ,p_duration                       IN      NUMBER   DEFAULT NULL
  ,p_duration_units                 IN      VARCHAR2 DEFAULT NULL
  ,p_ctr_information_category       IN      VARCHAR2 DEFAULT NULL
  ,p_ctr_information1               IN      VARCHAR2 DEFAULT NULL
  ,p_ctr_information2               IN      VARCHAR2 DEFAULT NULL
  ,p_ctr_information3               IN      VARCHAR2 DEFAULT NULL
  ,p_ctr_information4               IN      VARCHAR2 DEFAULT NULL
  ,p_ctr_information5               IN      VARCHAR2 DEFAULT NULL
  );

--
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
--
  /*PROCEDURE previous_employer_validate
  (p_employer_name                  IN      varchar2  default hr_api.g_varchar2
  ,p_effective_date                 IN      date      default hr_api.g_date
  ,p_pem_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information1               IN      varchar2  default hr_api.g_varchar2
  );

  PROCEDURE ASSIGNMENT_VALIDATE(
      p_segment2                       IN  VARCHAR2
     ,p_effective_date	               IN  DATE
     ,p_assignment_id                  IN  NUMBER
   );*/

  PROCEDURE create_address_validate
  (p_style                         IN      VARCHAR2
   ,p_effective_date               IN      DATE
   ,p_address_line3                IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2);

  PROCEDURE update_address_validate
  (p_address_id                    IN      NUMBER
   ,p_effective_date               IN      DATE
   ,p_address_line3                IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2);

  PROCEDURE create_location_validate
  (p_style                         IN      VARCHAR2
   ,p_effective_date               IN      DATE
   ,p_address_line_3               IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2);

  PROCEDURE update_location_validate
  (p_style                         IN      VARCHAR2
   ,p_effective_date               IN      DATE
   ,p_address_line_3               IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2);

  PROCEDURE update_asg_validate
    (p_effective_date	           IN      DATE
     ,p_assignment_id	           IN      NUMBER
     ,p_segment1                   IN      VARCHAR2
     ,p_segment2                   IN      VARCHAR2
     ,p_segment3                   IN      VARCHAR2
     ,p_segment4                   IN      VARCHAR2
     ,p_segment5                   IN      VARCHAR2);

  PROCEDURE CREATE_DISABILITY_VALIDATE
    (p_effective_date              IN     DATE
    ,p_person_id                   IN     NUMBER
    ,p_category                    IN     VARCHAR2
    ,p_degree                      IN     NUMBER   DEFAULT NULL
    ,p_dis_information_category    IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information1            IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information2            IN     VARCHAR2 DEFAULT NULL);

  PROCEDURE UPDATE_DISABILITY_VALIDATE
    (p_effective_date              IN     DATE
    ,p_disability_id               IN     NUMBER
    ,p_category                    IN     VARCHAR2
    ,p_degree                      IN     NUMBER   DEFAULT NULL
    ,p_dis_information_category    IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information1            IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information2            IN     VARCHAR2 DEFAULT NULL);

  PROCEDURE CREATE_PAYMENT_METHOD_VALIDATE
    (P_EFFECTIVE_DATE		   IN     DATE
    ,P_ASSIGNMENT_ID               IN     NUMBER
    ,P_ORG_PAYMENT_METHOD_ID	   IN     NUMBER
    ,P_PPM_INFORMATION1            IN     VARCHAR2 DEFAULT NULL);

  PROCEDURE UPDATE_PAYMENT_METHOD_VALIDATE
    (P_EFFECTIVE_DATE              IN     DATE
    ,P_PERSONAL_PAYMENT_METHOD_ID  IN     NUMBER
    ,P_PPM_INFORMATION1            IN     VARCHAR2);

END HR_AE_VALIDATE_PKG;


/
