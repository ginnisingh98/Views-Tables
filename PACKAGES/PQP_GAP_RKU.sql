--------------------------------------------------------
--  DDL for Package PQP_GAP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GAP_RKU" AUTHID CURRENT_USER as
/* $Header: pqgaprhi.pkh 120.0.12010000.2 2008/08/05 13:57:16 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_gap_absence_plan_id          in number
  ,p_assignment_id                in number
  ,p_absence_attendance_id        in number
  ,p_pl_id                        in number
  ,p_last_gap_daily_absence_date  in date
  ,p_object_version_number        in number
  ,p_assignment_id_o              in number
  ,p_absence_attendance_id_o      in number
  ,p_pl_id_o                      in number
  ,p_last_gap_daily_absence_dat_o in date
  ,p_object_version_number_o      in number
  );
--
end pqp_gap_rku;

/
