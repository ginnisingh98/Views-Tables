--------------------------------------------------------
--  DDL for Package HR_APPLICANT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_BK3" 
/* $Header: peappapi.pkh 120.5.12010000.5 2009/08/04 11:21:03 pannapur ship $ */
AUTHID CURRENT_USER AS
--
-- -----------------------------------------------------------------------------
-- |-------------------------< terminate_applicant_b >-------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE terminate_applicant_b
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_person_type_id               IN     NUMBER
  ,p_termination_reason           IN     VARCHAR2
  );
--
-- -----------------------------------------------------------------------------
-- |-------------------------< terminate_applicant_a >-------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE terminate_applicant_a
  (p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_person_type_id               IN     NUMBER
  ,p_termination_reason           IN     VARCHAR2
  ,p_effective_start_date         IN     DATE
  ,p_effective_end_date           IN     DATE
  ,p_remove_fut_asg_warning       IN     BOOLEAN
  );
--
END hr_applicant_bk3;

/
