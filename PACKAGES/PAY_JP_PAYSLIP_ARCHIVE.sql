--------------------------------------------------------
--  DDL for Package PAY_JP_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyjpparc.pkh 120.0.12010000.1 2008/07/27 23:00:52 appldev ship $ */

PROCEDURE archinit (p_payroll_action_id IN NUMBER);

PROCEDURE range_cursor (p_payroll_action_id IN NUMBER,
                        p_sqlstr OUT NOCOPY VARCHAR2);

PROCEDURE action_creation (p_payroll_action_id IN NUMBER,
                           p_start_person_id IN NUMBER,
                           p_end_person_id IN NUMBER,
                           p_chunk IN NUMBER);

PROCEDURE archive_code (p_assignment_action_id IN NUMBER,
                        p_effective_date IN DATE);

PROCEDURE deinitialization_code (p_payroll_action_id IN NUMBER);

end pay_jp_payslip_archive;

/
