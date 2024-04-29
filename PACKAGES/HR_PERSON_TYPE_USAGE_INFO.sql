--------------------------------------------------------
--  DDL for Package HR_PERSON_TYPE_USAGE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_TYPE_USAGE_INFO" AUTHID CURRENT_USER AS
/* $Header: hrptuinf.pkh 120.0.12010000.2 2009/07/07 09:12:22 gpurohit ship $ */
  --
  -- g_actions type to store a list of available actions for a particular
  -- person
  --
  TYPE g_actions_r IS RECORD
    (action   per_form_functions.restriction_code%TYPE
    ,meaning  per_form_functions.restriction_value%TYPE);

  TYPE g_actions_t IS TABLE OF g_actions_r index by binary_integer;

  --
  -- Character(s) used to separate the distinct components of the concatenated
  -- user person type.
  --
  g_user_person_type_separator   VARCHAR2(1) := '.';

--
-- ------------------------------------------------------------------------------
-- |---------------------< get_user_person_type_separator >---------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_user_person_type_separator
RETURN g_user_person_type_separator%TYPE;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< get_default_person_type_id >-----------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_default_person_type_id
  (p_person_type_id               IN     NUMBER
  )
RETURN NUMBER;
--
-- ------------------------------------------------------------------------------
-- |-----------------------< get_default_person_type_id >-----------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_default_person_type_id
  (p_business_group_id            IN     NUMBER
  ,p_system_person_type           IN     VARCHAR2
  )
RETURN NUMBER;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< get_user_person_type >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2;
--
-- -----------------------------------------------------------------------------
-- |----------------------< get_worker_user_person_type >----------------------|
-- -----------------------------------------------------------------------------
FUNCTION get_worker_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2;
--
-- -----------------------------------------------------------------------------
-- |----------------------< get_worker_number >--------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION get_worker_number
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2;
--
-- ---------------------------------------------------------------------------
-- |--------------------< get_apl_user_person_type >--------------------------|
-- ---------------------------------------------------------------------------
FUNCTION get_apl_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2;
--
FUNCTION get_emp_person_type_id
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2;
-- ------------------------------------------------------------------------------
-- |--------------------------< get_emp_user_person_type >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION get_emp_user_person_type
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  )
RETURN VARCHAR2;
-- ------------------------------------------------------------------------------
-- |--------------------------< GetSystemPersonType >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION GetSystemPersonType
  (p_person_type_id 		IN     NUMBER)
RETURN VARCHAR2;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< IsNonCoreHRPersonType >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION IsNonCoreHRPersonType
  (p_person_type_usage_id 		IN     NUMBER,
   p_effective_date			IN	DATE)
RETURN BOOLEAN;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< FutSysPerTypeChgExists >--------------------------|
-- ------------------------------------------------------------------------------
FUNCTION FutSysPerTypeChgExists
  (p_person_type_usage_id               IN     NUMBER,
   p_effective_date                     IN      DATE)
RETURN BOOLEAN;

FUNCTION FutSysPerTypeChgExists
  (p_person_type_usage_id 		IN     NUMBER,
   p_effective_date			IN	DATE
  ,p_person_id                          IN     NUMBER)
RETURN BOOLEAN;

--
-- ------------------------------------------------------------------------------
-- |--------------------------< is_person_of_type >-----------------------------|
-- ------------------------------------------------------------------------------
FUNCTION is_person_of_type
  (p_effective_date                     IN     DATE
  ,p_person_id                          IN     NUMBER
  ,p_system_person_type                 IN     VARCHAR2
  )
RETURN BOOLEAN;
--
-- ------------------------------------------------------------------------------
-- |-------------------------< is_person_a_worker >-----------------------------|
-- ------------------------------------------------------------------------------
--
FUNCTION is_person_a_worker
  (p_effective_date IN     DATE
  ,p_person_id      IN     per_all_people_f.person_id%TYPE) RETURN BOOLEAN;
--
-- ------------------------------------------------------------------------------
-- |--------------------------< get_person_actions >----------------------------|
-- ------------------------------------------------------------------------------
--
FUNCTION get_person_actions
  (p_person_id            		IN     NUMBER
  ,p_effective_date			IN     DATE
  ,p_customized_restriction_id          IN     NUMBER DEFAULT NULL)
RETURN g_actions_t;
--
END hr_person_type_usage_info;

/
