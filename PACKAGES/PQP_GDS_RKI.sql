--------------------------------------------------------
--  DDL for Package PQP_GDS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GDS_RKI" AUTHID CURRENT_USER as
/* $Header: pqgdsrhi.pkh 120.0 2005/10/28 07:32 rvishwan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_gap_duration_summary_id      in number
  ,p_assignment_id                in number
  ,p_gap_absence_plan_id          in number
  ,p_summary_type                 in varchar2
  ,p_gap_level                    in varchar2
  ,p_duration_in_days             in number
  ,p_duration_in_hours            in number
  ,p_date_start                   in date
  ,p_date_end                     in date
  ,p_object_version_number        in number
  );
end pqp_gds_rki;

 

/
