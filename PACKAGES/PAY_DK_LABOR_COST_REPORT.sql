--------------------------------------------------------
--  DDL for Package PAY_DK_LABOR_COST_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_LABOR_COST_REPORT" AUTHID CURRENT_USER AS
/* $Header: pydkalcr.pkh 120.0.12010000.1 2009/07/30 09:53:32 abraghun noship $ */
PROCEDURE  generate(p_legal_employer NUMBER
                   ,p_payroll        NUMBER
                   ,p_year           NUMBER
                   ,p_template_name  VARCHAR2
                   ,p_xml OUT NOCOPY CLOB);

END pay_dk_labor_cost_report;

/
