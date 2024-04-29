--------------------------------------------------------
--  DDL for Package HR_SE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SE_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pesevald.pkh 120.6 2007/04/11 13:08:13 spendhar noship $ */

  PROCEDURE person_validate
  (p_person_type_id                 in      number
   ,p_first_name                     in      varchar2 default null
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

  PROCEDURE validate_create_org_inf
  (p_org_info_type_code		    IN      VARCHAR2
  ,p_organization_id		    IN      NUMBER
  ,p_org_information1		    IN      VARCHAR2 DEFAULT null
  ,p_org_information2		    IN      VARCHAR2 DEFAULT null
  ,p_org_information3		    IN	    VARCHAR2 DEFAULT null
  ,p_org_information4		    IN      VARCHAR2 DEFAULT null
  ,p_org_information5		    IN      VARCHAR2 DEFAULT null
  ,p_org_information6		    IN      VARCHAR2 DEFAULT null
  ,p_org_information7		IN  VARCHAR2 DEFAULT null
  ,p_org_information8		IN  VARCHAR2 DEFAULT null
  ,p_org_information9		IN  VARCHAR2 DEFAULT null
  ,p_org_information10		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information11		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information12		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information13		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information14		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information15		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information16		IN  VARCHAR2 DEFAULT null

  ) ;

  PROCEDURE validate_update_org_inf
  (p_org_info_type_code		    IN      VARCHAR2
  ,p_org_information_id		    IN      NUMBER
  ,p_org_information1		    IN      VARCHAR2 DEFAULT null
  ,p_org_information2		    IN      VARCHAR2 DEFAULT null
  ,p_org_information3		    IN      VARCHAR2 DEFAULT null
  ,p_org_information4		    IN      VARCHAR2 DEFAULT null
  ,p_org_information5		    IN      VARCHAR2 DEFAULT null
  ,p_org_information6		    IN      VARCHAR2 DEFAULT null
  ,p_org_information7		IN  VARCHAR2 DEFAULT null
  ,p_org_information8		IN  VARCHAR2 DEFAULT null
  ,p_org_information9		IN  VARCHAR2 DEFAULT null
  ,p_org_information10		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information11		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information12		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information13		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information14		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information15		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information16		IN  VARCHAR2 DEFAULT null
  );

 PROCEDURE VALIDATE_NUMBER
  (
   p_number		IN	VARCHAR2
  ,p_token		IN	VARCHAR2
  ,p_message		IN	VARCHAR2 DEFAULT NULL
  );

PROCEDURE  CREATE_ORG_CLASS_VALIDATE
  (P_ORGANIZATION_ID                IN	    NUMBER
  ,P_ORG_INFORMATION1               IN      VARCHAR2
  );

  PROCEDURE  CREATE_ASG_VALIDATE
  (p_scl_segment5                   IN      VARCHAR2  DEFAULT  NULL
  ,p_scl_segment6                   IN      VARCHAR2  DEFAULT  NULL
    );

  PROCEDURE  UPDATE_ASG_VALIDATE
  (p_segment5			    IN	    VARCHAR2
  ,p_segment6			    IN	    VARCHAR2
  );

END hr_se_validate_pkg;


/
