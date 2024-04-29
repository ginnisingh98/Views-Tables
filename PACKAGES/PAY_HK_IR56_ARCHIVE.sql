--------------------------------------------------------
--  DDL for Package PAY_HK_IR56_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_IR56_ARCHIVE" AUTHID CURRENT_USER AS
  --  $Header: pyhk56ar.pkh 120.0.12010000.1 2008/07/27 22:48:06 appldev ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create pay_hk_ir56_archive package header
  --  for HK IR56B Archive
  --
  --  Change List
  --  ===========
  --
  --  Date           Author         Reference Description
  --  -----------+----------------+---------+------------------------------------------
  --  05 Jul 2001    A Tripathi               Initial version
  --  27 Aug 2001    a Tripathi		      Changed archive message curosr
  --  01 Dec 2002    srrajago        2689229  Included the nocopy option for 'OUT'
  --                                          parameter of the procedure range_code.
  --  10 Jan 2003    srrajago        2740270  A PL/SQL table defined to store assignment ids.

/* Bug No : 2740270 - Defined PL/SQL table to store assignment_ids */
TYPE t_assignmentid_store_tab
IS   table of per_all_assignments.assignment_id%type
index by binary_integer;

t_assignmentid_store t_assignmentid_store_tab;

LEVEL_CNT Number;

CURSOR archive_messages
IS
   SELECT DISTINCT
           'ARCHIVE_MESSAGE=P',
           fai.value
    FROM   per_all_assignments_f paa,
           pay_payroll_actions ppa,
           pay_assignment_actions pac,
           ff_database_items      fdi,
           ff_archive_items       fai
    WHERE  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    AND    pac.action_status = 'C'
    AND    ppa.payroll_action_id = pac.payroll_action_id
    AND    paa.assignment_id = pac.assignment_id
    AND    fdi.user_entity_id = fai.user_entity_id
    AND    fdi.user_name = 'X_HK_ARCHIVE_MESSAGE'
    AND    fai.context1  = pac.assignment_action_id
    AND    fai.value is not null;

CURSOR csr_submit_reports
IS
   SELECT 'P_ARCHIVE_OR_MAGTAPE=P',
           'ARCHIVE'
   FROM dual;


PROCEDURE ARCHIVE_CODE
(
 p_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE,
 P_EFFECTIVE_DATE        IN       DATE
  );

PROCEDURE ARCHIVE_ITEM
(
 p_user_entity_name      IN ff_user_entities.user_entity_name%TYPE,
 p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE,
 p_archive_value         IN ff_archive_items.value%TYPE
);

PROCEDURE ASSIGNMENT_ACTION_CODE
(
 p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
 p_start_person_id    in per_all_people_f.person_id%TYPE,
 p_end_person_id      in per_all_people_f.person_id%TYPE,
 p_chunk              in number
);



PROCEDURE INITIALIZATION_CODE
(
 p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE
);

PROCEDURE RANGE_CODE
(
 P_PAYROLL_ACTION_ID    IN   pay_payroll_actions.payroll_action_id%TYPE,
 P_SQL   		OUT  nocopy VARCHAR2
);

FUNCTION SUBMIT_REPORT
(p_archive_or_magtape    in varchar2)
RETURN Number;

END pay_hk_ir56_archive;

/
