--------------------------------------------------------
--  DDL for Package PAY_IE_LEGISLATIVE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_LEGISLATIVE_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyieparc.pkh 120.0.12010000.2 2009/07/28 09:05:04 vijranga ship $ */

PROCEDURE archinit (p_payroll_action_id IN NUMBER);

PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2);

PROCEDURE action_creation (pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number);

PROCEDURE archive_code (p_assactid in number,
                        p_effective_date in date);

Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER);

-- Start fix for Bug#8522324
PROCEDURE get_pay_deduct_element_info ( p_assignment_action_id  IN NUMBER,
                                        p_assignment_id IN NUMBER DEFAULT NULL,
                                        p_effective_date IN DATE DEFAULT NULL);
-- End fix for Bug#8522324
END;

/
