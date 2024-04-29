--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BKC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BKC" 
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
AUTHID CURRENT_USER AS
--
-- -----------------------------------------------------------------------------
-- |--------------------------< activate_apl_asg_b >---------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE activate_apl_asg_b
  (p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_assignment_status_type_id    IN     NUMBER
  ,p_change_reason                IN     VARCHAR2
  );
--
-- -----------------------------------------------------------------------------
-- |--------------------------< activate_apl_asg_a >---------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE activate_apl_asg_a
  (p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN     NUMBER
  ,p_assignment_status_type_id    IN     NUMBER
  ,p_change_reason                IN     VARCHAR2
  ,p_effective_start_date         IN     DATE
  ,p_effective_end_date           IN     DATE
  );
--
END hr_assignment_bkc;

/
