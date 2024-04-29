--------------------------------------------------------
--  DDL for Package PQP_GDA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GDA_RKI" AUTHID CURRENT_USER as
/* $Header: pqgdarhi.pkh 120.0.12010000.1 2008/07/28 11:12:36 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_gap_daily_absence_id         in number
  ,p_gap_absence_plan_id          in number
  ,p_absence_date                 in date
  ,p_work_pattern_day_type        in varchar2
  ,p_level_of_entitlement         in varchar2
  ,p_level_of_pay                 in varchar2
  ,p_duration                     in number
  ,p_duration_in_hours            in number
  ,p_working_days_per_week        in number
  ,p_fte                          in number -- LG
  ,p_object_version_number        in number
  );
end pqp_gda_rki;

/
