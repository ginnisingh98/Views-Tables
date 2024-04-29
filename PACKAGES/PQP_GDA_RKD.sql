--------------------------------------------------------
--  DDL for Package PQP_GDA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GDA_RKD" AUTHID CURRENT_USER as
/* $Header: pqgdarhi.pkh 120.0.12010000.1 2008/07/28 11:12:36 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_gap_daily_absence_id         in number
  ,p_gap_absence_plan_id_o        in number
  ,p_absence_date_o               in date
  ,p_work_pattern_day_type_o      in varchar2
  ,p_level_of_entitlement_o       in varchar2
  ,p_level_of_pay_o               in varchar2
  ,p_duration_o                   in number
  ,p_duration_in_hours_o          in number
  ,p_working_days_per_week_o      in number
  ,p_fte_o                        in number -- LG
  ,p_object_version_number_o      in number
  );
--
end pqp_gda_rkd;

/
