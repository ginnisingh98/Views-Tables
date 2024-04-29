--------------------------------------------------------
--  DDL for Package HR_NI_CHK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NI_CHK_PKG" AUTHID CURRENT_USER AS
/* $Header: penichk.pkh 120.0.12000000.2 2007/03/29 12:50:08 ghshanka ship $ */
/*
 Name        : hr_ni_chk_pkg  (HEADER)
*/
-- ------------------- validate_national_identifier -----------------------
--
-- Pass in national identifier and validate both construct (dependent on
-- the legislation of the business group) and uniqueness within business
-- group
--
FUNCTION validate_national_identifier
( p_national_identifier    VARCHAR2,
  p_birth_date             DATE,
  p_gender                 VARCHAR2,
  p_business_group_id      NUMBER,
  p_session_date           DATE
     ) RETURN VARCHAR2;
--
FUNCTION validate_national_identifier
( p_national_identifier     VARCHAR2,
  p_birth_date              DATE,
  p_gender                  VARCHAR2,
  p_event                   VARCHAR2 default 'WHEN-VALIDATE-RECORD',
  p_person_id               NUMBER,
  p_business_group_id       NUMBER,
  p_legislation_code        VARCHAR2,
  p_session_date            DATE,
  p_warning             OUT NOCOPY VARCHAR2,
  p_person_type_id          NUMBER default NULL,
  p_region_of_birth         VARCHAR2 default NULL,
  p_country_of_birth        VARCHAR2 default NULL
      ) RETURN VARCHAR2;
--
--
-- added a new parameter p_nationality
FUNCTION validate_national_identifier
( p_national_identifier     VARCHAR2,
  p_birth_date              DATE,
  p_gender                  VARCHAR2,
  p_event                   VARCHAR2 default 'WHEN-VALIDATE-RECORD',
  p_person_id               NUMBER,
  p_business_group_id       NUMBER,
  p_legislation_code        VARCHAR2,
  p_session_date            DATE,
  p_warning             OUT NOCOPY VARCHAR2,
  p_person_type_id          NUMBER default NULL,
  p_region_of_birth         VARCHAR2 default NULL,
  p_country_of_birth        VARCHAR2 default NULL,
  p_nationality            VARCHAR2  -- added for the bug 5961277
      ) RETURN VARCHAR2 ;

FUNCTION chk_nat_id_format
( p_national_identifier VARCHAR2,
  p_format_string       VARCHAR2) RETURN VARCHAR2;
--
procedure check_ni_unique
( p_national_identifier       VARCHAR2,
  p_person_id                 NUMBER,
  p_business_group_id         NUMBER,
  p_raise_error_or_warning    VARCHAR2);
--
end hr_ni_chk_pkg;

 

/
