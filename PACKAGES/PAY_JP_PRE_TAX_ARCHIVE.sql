--------------------------------------------------------
--  DDL for Package PAY_JP_PRE_TAX_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_PRE_TAX_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyjppretaxarch.pkh 120.0 2005/09/22 03:03:38 sgottipa noship $ */
--
-- Procedures for ARCHIVE process
--
procedure initialization_code(p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE);

procedure range_code(
        p_payroll_action_id     in  pay_payroll_actions.payroll_action_id%TYPE,
        p_sqlstr                out nocopy varchar2);
procedure assignment_action_code(
        p_payroll_action_id     in  pay_payroll_actions.payroll_action_id%TYPE,
        p_start_person_id       in  number,
        p_end_person_id         in  number,
        p_chunk_number          in  pay_assignment_actions.chunk_number%TYPE);
procedure archive_code(
        p_assignment_action_id  in  pay_assignment_actions.assignment_action_id%TYPE,
        p_effective_date        in  pay_payroll_actions.effective_date%TYPE);
procedure deinitialization_code(p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE);
--
END PAY_JP_PRE_TAX_ARCHIVE;

 

/
