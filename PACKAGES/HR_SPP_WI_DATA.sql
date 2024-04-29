--------------------------------------------------------
--  DDL for Package HR_SPP_WI_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SPP_WI_DATA" AUTHID CURRENT_USER AS
/* $Header: pesppwif.pkh 120.0.12010000.1 2008/07/28 05:59:57 appldev ship $ */

TYPE SPP_WI_TableType is record
  (placement_id_val		number
  ,assignment_id_val		number
  ,assignment_number_val	per_all_assignments_f.assignment_number%TYPE
  ,pay_scale_val		varchar2(30)
  ,grade_name_val		per_grades.name%TYPE
  ,old_spinal_point_val		varchar2(30)
  ,new_spinal_point_val		varchar2(30)
  ,old_value_val		number
  ,new_value_val		number
  ,difference_val		number
  ,full_name_val		varchar2(60)
  ,org_name_val                 varchar2(60));

TYPE SPP_WI_Table is TABLE of SPP_WI_TableType
Index by binary_integer;
--
SPP_WI_DATA SPP_WI_Table;
--
function get_placement_id_val (p_placement_id NUMBER) return NUMBER;
function get_assignment_number_val (p_placement_id NUMBER) return VARCHAR2;
function get_pay_scale_val (p_placement_id NUMBER) return VARCHAR2;
function get_grade_name_val (p_placement_id NUMBER) return VARCHAR2;
function get_old_spinal_point_val (p_placement_id NUMBER) return VARCHAR2;
function get_new_spinal_point_val (p_placement_id NUMBER) return VARCHAR2;
function get_old_value_val (p_placement_id NUMBER) return NUMBER;
function get_new_value_val (p_placement_id NUMBER) return NUMBER;
function get_difference_val (p_placement_id NUMBER) return NUMBER;
function get_full_name_val (p_placement_id NUMBER) return VARCHAR2;
function get_assignment_id_val (p_placement_id NUMBER) return NUMBER;
function get_org_name_val (p_placement_id NUMBER) return VARCHAR2;

procedure populate_spp_wi_table
  (p_placement_id		number
  ,p_assignment_id		number
  ,p_effective_date		date
  ,p_parent_spine_id		number
  ,p_step_id			number
  ,p_spinal_point_id		number
  ,p_rate_id			number
  );

END HR_SPP_WI_DATA;

/
