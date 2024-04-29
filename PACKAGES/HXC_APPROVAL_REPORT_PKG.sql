--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: hxcaprrp.pkh 115.4 2002/06/10 00:36:12 pkm ship    $ */
--  get_employee_name
--
-- procedure
-- Brings back the employee name for a given person id
-- description
--
-- parameters
--              p_person_id          - person Id
--
function get_employee_name(
         p_person_id in varchar2
         ) return varchar2;



--  get_last_aprv
--
-- procedure
-- Brings back the last approver for a given Approval timecard  ID and OVN
-- parameters
--              p_timecard_id         - Application Period Building Block Id
--              p_timecard_ovn        - Application Period Building Block Ovn
--


function get_last_aprv(
               p_timecard_id in number,
               p_timecard_ovn in number)
           return varchar2;


--  get_project_name
--
-- procedure
-- Brings back the project name for a given project number
-- description
--
-- parameters
--              p_project_number         - project number
--

function get_project_name(
    p_project_number in varchar2
    ) return varchar2 ;

--  get_task_name
--
-- procedure
-- Brings back the task name for a given task number
-- description
--
-- parameters
--              p_task_number  - Task number
--
 function get_task_name(
    p_task_number in varchar2
    ) return varchar2 ;

--  get_element_name
--
-- procedure
-- Brings back the element name for a given element type id
--
-- parameters
--              p_element_type_id         - element type id
--
-- returns
--              varchar2     -   element name

function get_element_name(
 p_element_type_id varchar2)  return varchar2;

--  get_application_name
--
-- procedure
-- Brings back the application name for a given time recipient id
--
-- parameters
--              p_time_recipient_id         - Time Recipient Id
--
-- returns
--              varchar2     -   application Name


function get_application_name(
 p_time_recipient_id varchar2)  return varchar2;

--  get_supervisor_name
--
-- procedure
-- Brings back the supervior for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   supervisor full name


function get_supervisor_name(
         p_person_id in number
         ) return varchar2;

--  get_organization_name
--
-- procedure
-- Brings back the organization name for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   organization name

function get_organization_name(
         p_person_id in number
         ) return varchar2;

--  get_cost_center
--
-- procedure
-- Brings back the cost center for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   cost center

function get_cost_center(
         p_person_id in number
         ) return varchar2;

--  get_cost_center
--
-- procedure
-- Brings back the payroll for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   payroll_name

function get_payroll_name(
         p_person_id in number
         ) return varchar2;

--  get_business_group
--
-- procedure
-- Brings back the business group name for a given person
--
-- parameters
--              p_person_id         - person id
--
-- returns
--              varchar2     -   business_group_name

function get_business_group_name(
         p_person_id in number
         ) return varchar2;

end hxc_approval_report_pkg;


 

/
