--------------------------------------------------------
--  DDL for Package PQP_GDS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GDS_BK1" AUTHID CURRENT_USER as
/* $Header: pqgdsapi.pkh 120.0 2005/10/28 07:31 rvishwan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_duration_summary_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_duration_summary_b
 (p_date_start                        IN  DATE
 ,p_gap_duration_summary_id     IN  NUMBER
 ,p_date_end                          IN  DATE
 ,p_assignment_id                     IN  NUMBER
 ,p_gap_absence_plan_id               IN  NUMBER
 ,p_duration_in_days                  IN  NUMBER
 ,p_duration_in_hours                 IN  NUMBER
 ,p_summary_type                      IN  VARCHAR2
 ,p_gap_level                         IN  VARCHAR2
 ,p_object_version_number             IN  NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_duration_summary_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_duration_summary_a
 (p_date_start                        IN  DATE
 ,p_gap_duration_summary_id     IN  NUMBER
 ,p_date_end                          IN  DATE
 ,p_assignment_id                     IN  NUMBER
 ,p_gap_absence_plan_id               IN  NUMBER
 ,p_duration_in_days                  IN  NUMBER
 ,p_duration_in_hours                 IN  NUMBER
 ,p_summary_type                      IN  VARCHAR2
 ,p_gap_level                         IN  VARCHAR2
 ,p_object_version_number             IN  NUMBER
  );
--
end pqp_gds_bk1;

 

/
