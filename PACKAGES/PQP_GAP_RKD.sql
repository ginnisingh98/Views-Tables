--------------------------------------------------------
--  DDL for Package PQP_GAP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GAP_RKD" AUTHID CURRENT_USER as
/* $Header: pqgaprhi.pkh 120.0.12010000.2 2008/08/05 13:57:16 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_gap_absence_plan_id          in number
  ,p_assignment_id_o              in number
  ,p_absence_attendance_id_o      in number
  ,p_pl_id_o                      in number
  ,p_last_gap_daily_absence_dat_o in date
  ,p_object_version_number_o      in number
  );
--
end pqp_gap_rkd;

/
