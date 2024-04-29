--------------------------------------------------------
--  DDL for Package HR_SPP_EXCEPTION_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SPP_EXCEPTION_DATA" AUTHID CURRENT_USER AS
/* $Header: pesppexc.pkh 115.11 2003/07/11 13:26:18 vramanai noship $ */

TYPE SPPTableType is record
  (placement_id_val		number
  ,full_name_val 		varchar2(60)
  ,org_name_val                 varchar2(60)
  ,pay_scale_val		varchar2(30)
  ,grade_name_val		per_grades.name%TYPE
  ,start_date_val		date
  ,end_date_val 		date
  ,assignment_number_val	per_all_assignments_f.assignment_number%TYPE
  ,increment_number_val		number
  ,original_inc_number_val	number
  ,sequence_number_val		number
  ,next_sequence_number_val	number
  ,spinal_point_val		number
  ,reason_val			varchar2(100));

TYPE SPPTable is TABLE of SPPTableType
Index by binary_integer;
--
SPPDATA SPPTable;
--
function get_placement_id_val (p_placement_id NUMBER) return NUMBER;
function get_full_name_val(p_placement_id NUMBER) return VARCHAR2;
function get_pay_scale_val(p_placement_id NUMBER) return VARCHAR2;
function get_grade_name_val(p_placement_id NUMBER) return VARCHAR2;
function get_start_date_val(p_placement_id NUMBER) return DATE;
function get_end_date_val(p_placement_id NUMBER) return DATE;
function get_assignment_number_val(p_placement_id NUMBER) return varchar2;
function get_increment_number_val(p_placement_id NUMBER) return NUMBER;
function get_sequence_number_val(p_placement_id NUMBER) return NUMBER;
function get_spinal_point_val(p_placement_id NUMBER) return NUMBER;
function get_original_inc_number_val(p_placement_id NUMBER) return NUMBER;
function get_next_sequence_number_val(p_placement_id NUMBER) return NUMBER;
function get_reason_val(p_placement_id NUMBER) return VARCHAR2;
function get_org_name_val(p_placement_id NUMBER) return VARCHAR2;

procedure populate_spp_table
  (p_effective_date		date
  ,p_placement_id		number
  ,p_effective_start_date	date
  ,p_effective_end_date		date
  ,p_assignment_id		number
  ,p_parent_spine_id		number
  ,p_increment_number		number
  ,p_original_increment_number  number
  ,p_sequence_number		number
  ,p_next_sequence_number	number
  ,p_spinal_point_id		number
  ,p_step_id			number
  ,p_new_step_id		number
  ,p_grade_spine_id		number
  ,p_update			varchar2);

END HR_SPP_EXCEPTION_DATA;

 

/
