--------------------------------------------------------
--  DDL for Package HR_SA_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pesavald.pkh 120.3 2007/02/07 10:37:04 spendhar noship $ */
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
  PROCEDURE contact_cwk_validate
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
  PROCEDURE previous_employer_validate
  (p_employer_name                  IN      varchar2  default hr_api.g_varchar2
  ,p_start_date                     IN      date      default hr_api.g_date
  ,p_pem_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information1               IN      varchar2  default hr_api.g_varchar2
  );
  PROCEDURE contract_validate
  (p_effective_date                 in      date
  ,p_type                           in      varchar2
  ,p_duration                       in      number   default null
  ,p_duration_units                 in      varchar2 default null
  ,p_contractual_job_title          in      varchar2 default null
  ,p_ctr_information_category       in      varchar2 default null
  ,p_ctr_information1               in      varchar2 default null
  ,p_ctr_information2               in      varchar2 default null
  ,p_ctr_information3               in      varchar2 default null
  ,p_ctr_information4               in      varchar2 default null
  ,p_ctr_information5               in      varchar2 default null
  );
  PROCEDURE periods_of_service_validate
  (p_period_of_service_id           IN      number
  ,p_pds_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pds_information1               IN      varchar2  default hr_api.g_varchar2
  );
  PROCEDURE person_eit_validate
  (p_pei_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information1               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information2               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information3               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information4               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information5               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information6               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information7               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information8               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information9               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information10              IN      varchar2  default hr_api.g_varchar2
  );
  PROCEDURE create_person_eit_validate
  (p_person_id	                      IN      number
  ,p_pei_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information1               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information2               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information3               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information4               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information5               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information6               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information7               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information8               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information9               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information10              IN      varchar2  default hr_api.g_varchar2
  );
  PROCEDURE update_person_eit_validate
  (p_person_extra_info_id	    IN      number
  ,p_pei_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information1               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information2               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information3               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information4               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information5               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information6               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information7               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information8               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information9               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information10              IN      varchar2  default hr_api.g_varchar2
  );
  PROCEDURE assignment_annuities_validate
	(p_segment3		IN	VARCHAR2
	,p_effective_date	IN	DATE
	,p_assignment_id	IN	NUMBER);
END hr_sa_validate_pkg;

/
