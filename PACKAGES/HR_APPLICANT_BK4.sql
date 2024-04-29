--------------------------------------------------------
--  DDL for Package HR_APPLICANT_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_BK4" 
/* $Header: peappapi.pkh 120.5.12010000.5 2009/08/04 11:21:03 pannapur ship $ */
AUTHID CURRENT_USER AS
--
-- -----------------------------------------------------------------------------
-- |------------------------< convert_to_applicant_b >-------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE convert_to_applicant_b
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_business_group_id            IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_applicant_number             IN     VARCHAR2
  ,p_person_type_id               IN     NUMBER
  );
--
-- -----------------------------------------------------------------------------
-- |------------------------< convert_to_applicant_a >-------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE convert_to_applicant_a
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_business_group_id            IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_applicant_number             IN     VARCHAR2
  ,p_person_type_id               IN     NUMBER
  ,p_effective_start_date         IN     DATE
  ,p_effective_end_date           IN     DATE
  ,p_appl_override_warning        IN     BOOLEAN
  );
--
END hr_applicant_bk4;

/
