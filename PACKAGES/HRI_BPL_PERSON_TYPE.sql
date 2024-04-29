--------------------------------------------------------
--  DDL for Package HRI_BPL_PERSON_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_PERSON_TYPE" AUTHID CURRENT_USER AS
/* $Header: hribptu.pkh 120.1 2005/07/04 06:37:18 jtitmas noship $ */
--
-- Global Variables
--
g_warning_flag                      VARCHAR2(30);
--
FUNCTION get_emp_user_person_type
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2 ;
--
FUNCTION get_concat_user_person_type
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2 ;
--
FUNCTION get_apl_user_person_type
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2 ;
--
FUNCTION get_cwk_user_person_type
  (p_effective_date              IN    DATE
  ,p_person_id                   IN    NUMBER
  )
RETURN VARCHAR2 ;
--
FUNCTION get_emp_system_type(p_effective_date       IN DATE,
                             p_person_id            IN NUMBER)
RETURN VARCHAR2;
--
FUNCTION get_person_typ_ff_id
RETURN NUMBER;
--
FUNCTION get_wkth_lvl1_sk_fk
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION get_wkth_lvl2_sk_fk
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION get_wkth_lvl1_code
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION get_wkth_lvl2_code
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION get_wkth_wktyp_code
  (p_prsntyp_sk_pk  IN NUMBER)
       RETURN VARCHAR2;

FUNCTION get_include_flag
  (p_person_type_id       IN NUMBER
  ,p_system_person_type   IN VARCHAR2
  ,p_user_person_type     IN VARCHAR2
  ,p_business_group_id    IN NUMBER
  ,p_primary_flag         IN VARCHAR2
  ,p_employment_category  IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION get_prsntyp_sk_fk
  (p_person_type_id       IN NUMBER
  ,p_employment_category  IN VARCHAR2
  ,p_primary_flag         IN VARCHAR2
  ,p_assignment_type      IN VARCHAR2)
     RETURN NUMBER;

END HRI_BPL_PERSON_TYPE;

 

/
