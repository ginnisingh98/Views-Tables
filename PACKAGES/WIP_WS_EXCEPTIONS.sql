--------------------------------------------------------
--  DDL for Package WIP_WS_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_EXCEPTIONS" AUTHID CURRENT_USER as
/* $Header: wipvexcs.pls 120.1 2005/10/19 05:01:46 amgarg noship $ */

 /*
  * Close all exceptions for a Job
  */
  function close_exception_job
  (
    p_wip_entity_id number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job Op combination
  */
  function close_exception_jobop
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job Op combination
  * check if department changed, close exception.
  */
  function close_exception_jobop
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_department_id number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job,Op,Res combination
  */
  function close_exception_jobop_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job,Op,Res combination.
  * Check if resource Id changed, only then close exceptions.
  */
  function close_exception_jobop_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job,Op,Res combination
  * Check if either resource_id changed or department_id changed, close exceptions
  */
  function close_exception_jobop_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_department_code varchar2,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job,Op,Replacement Group Num combination
  * Resolves exception when altenates are assigned.
  */
  function close_exception_alt_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_substitute_group_num number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job,Op,Res Instance combination
  * when doing a res Instance deleted
  * Serial Number field won't be used.
  */
  function close_exception_res_instance
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_instance_id number,
    p_serial_number varchar2,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job,Op,Res Instance combination
  * Closes exception when a Res Instance is Updated.
  * Check if Serial_Number is changed, close exception.
  */
  function close_exp_res_instance_update
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_instance_id number,
    p_serial_number varchar2,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for a Job:Op component.
  * component_item_id is inventory_item_id from WRO.
  */
  function close_exception_component
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_component_item_id number,
    p_organization_id number
  ) return boolean;

 /*
  * Close exception for this exception_id.
  */
  function close_exception
  (
    p_exception_id number
  ) return boolean;

 /*
  * Delete exception for a Job:Op combination.
  */
  function delete_exception_jobop
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_organization_id number
  ) return boolean;

 /*
  * Delete all exceptions for a Job.
  */
  function delete_exception_job
  (
    p_wip_entity_id number,
    p_organization_id number
  ) return boolean;


end WIP_WS_EXCEPTIONS;


 

/
