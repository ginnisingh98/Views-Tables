--------------------------------------------------------
--  DDL for Package JTF_AGENDA_CALCULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AGENDA_CALCULATIONS" AUTHID CURRENT_USER as
/*$Header: JTFAGCAS.pls 115.5 2002/02/14 12:08:13 pkm ship     $*/
  function predict_time_difference
  (
    p_task_assignment_id number
  )
  return number;

  function set_sequence_flag
  (
    p_task_assignment_id number
  )
  return varchar2;

  function get_progress_status
  (
    p_resource_id        number
  , p_resource_type_code varchar2
  , p_date               date
  )
  return number;

  function get_shift_start
  (
     p_shift_construct_id number   default null
  ,  p_resource_id        number   default null
  ,  p_resource_type_code varchar2 default null
  ,  p_date               date     default null
  )
  return date;

  function get_shift_end
  (
     p_shift_construct_id number   default null
  ,  p_resource_id        number   default null
  ,  p_resource_type_code varchar2 default null
  ,  p_date               date     default null
  )
  return date;

  function get_assignment_status
  (
     p_resource_id        number
  ,  p_resource_type_code varchar2
  )
  return number;

  function get_status_name
  (
    p_status_id number
  )
  return varchar2;

  function get_current_task
  (
     p_resource_id        number
  ,  p_resource_type_code varchar2
  )
  return number;

  function set_escalation_flag
  (
     p_task_id number
  )
  return varchar2;

end JTF_AGENDA_CALCULATIONS;

 

/
