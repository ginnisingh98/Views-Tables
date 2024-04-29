--------------------------------------------------------
--  DDL for Package HR_FI_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FI_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pefivald.pkh 120.3 2007/03/07 11:15:35 dbehera ship $ */

  PROCEDURE person_validate
  (p_person_type_id                 in      number
   ,p_first_name                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
  );

  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
  );

  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
  );

  PROCEDURE contact_cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
   );

  PROCEDURE qual_insert_validate
  (p_business_group_id              in      number
  ,p_qua_information_category       in      varchar2 default null
  ,p_person_id                      in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  );

  PROCEDURE qual_update_validate
  (p_qua_information_category       in      varchar2 default null
  ,p_qualification_id               in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  );
 PROCEDURE validate_create_org_inf
  (p_effective_date		    IN	    DATE
  ,p_org_info_type_code		    IN      VARCHAR2
  ,p_organization_id		    IN      NUMBER
  ,p_org_information1		    IN      VARCHAR2 DEFAULT null
  ,p_org_information2		    IN      VARCHAR2 DEFAULT null
  ,p_org_information3		    IN      VARCHAR2 DEFAULT null
  ,p_org_information4		    IN      VARCHAR2 DEFAULT null
  ,p_org_information5		    IN	    VARCHAR2 DEFAULT null
  ,p_org_information6		    IN	    VARCHAR2 DEFAULT null
  ,p_org_information7		    IN      VARCHAR2 DEFAULT null
  ,p_org_information8		    IN      VARCHAR2 DEFAULT null
  ,p_org_information9		    IN      VARCHAR2 DEFAULT null
  ) ;

  PROCEDURE validate_update_org_inf
  (p_effective_date		    IN	    DATE
  ,p_org_info_type_code		    IN      VARCHAR2
  ,p_org_information_id		    IN      NUMBER
  ,p_org_information1		    IN      VARCHAR2 DEFAULT null
  ,p_org_information2		    IN      VARCHAR2 DEFAULT null
  ,p_org_information3		    IN      VARCHAR2 DEFAULT null
  ,p_org_information4		    IN      VARCHAR2 DEFAULT null
  ,p_org_information5		    IN	    VARCHAR2 DEFAULT null
  ,p_org_information6		    IN	    VARCHAR2 DEFAULT null
  ,p_org_information7		    IN      VARCHAR2 DEFAULT null
  ,p_org_information8		    IN      VARCHAR2 DEFAULT null
  ,p_org_information9		    IN      VARCHAR2 DEFAULT null
  );

  PROCEDURE  CREATE_ASG_VALIDATE
  (p_scl_segment12                  IN      VARCHAR2  DEFAULT  NULL
  ,p_effective_date		    IN	    DATE
  ,p_person_id                      IN      NUMBER
  ,p_organization_id                IN      NUMBER
  );

  PROCEDURE  UPDATE_ASG_VALIDATE
  (p_segment2			    IN	    VARCHAR2
  ,p_segment12			    IN	    VARCHAR2
  ,p_effective_date		    IN	    DATE
  ,p_assignment_id		    IN	    NUMBER
  );
   PROCEDURE  UPDATE_TERMINATION_VALIDATE
  (p_leaving_reason                 IN	    VARCHAR2
  );
   PROCEDURE  CREATE_ORG_CLASS_VALIDATE
  (P_ORGANIZATION_ID                IN	    NUMBER
  ,P_ORG_INFORMATION1               IN      VARCHAR2
  );

   PROCEDURE VALIDATE_NUMBER
  (
   p_number		IN	VARCHAR2
  ,p_token		IN	VARCHAR2
  ,p_message		IN	VARCHAR2 DEFAULT NULL
  );

   PROCEDURE PERSON_ABSENCE_CREATE
  (
   p_business_group_id            IN number
  ,p_abs_information_category     IN varchar2
  ,p_person_id                    IN Number
  ,p_date_start                   IN Date
  ,p_date_end                     IN Date
  ,p_abs_information1             IN Varchar2 default NULL
  ,p_abs_information2             IN Varchar2 default NULL
  ,p_abs_information3             IN Varchar2 default NULL
  ,p_abs_information4             IN Varchar2 default NULL
  ,p_abs_information5             IN Varchar2 default NULL
  );

   PROCEDURE PERSON_ABSENCE_UPDATE
  (
   p_absence_attendance_id        IN Number
  ,p_abs_information_category     IN varchar2
  ,p_date_start                   IN Date
  ,p_date_end                     IN Date
  ,p_abs_information1             IN Varchar2 default NULL
  ,p_abs_information2             IN Varchar2 default NULL
  ,p_abs_information3             IN Varchar2 default NULL
  ,p_abs_information4             IN Varchar2 default NULL
  ,p_abs_information5             IN Varchar2 default NULL
  );



END HR_FI_VALIDATE_PKG;

/
