--------------------------------------------------------
--  DDL for Package AP_WEB_AME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AME_PKG" AUTHID CURRENT_USER AS
/* $Header: apwxames.pls 120.4 2006/02/24 10:25:44 sbalaji noship $ */

-- Constants
C_AWARD_MANAGER_ROLE	       CONSTANT VARCHAR(30) := 'AM';
C_PROJECT_MANAGER_ROLE_TYPE  CONSTANT VARCHAR(20) := 'PROJECT MANAGER';
C_ACTIVE_STATUS 	     CONSTANT VARCHAR(30) := 'ACTIVE_ASSIGN';

FUNCTION getViolationTotal(p_report_header_id IN VARCHAR2) RETURN NUMBER;

FUNCTION getAwardManagerID(p_award_id IN NUMBER, p_as_of_date IN DATE) RETURN NUMBER;

FUNCTION getProjectManagerID(p_project_id IN NUMBER, p_as_of_date IN DATE) RETURN NUMBER;

FUNCTION getTotalPerCostCenter(p_report_header_id  IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			       p_line_number       IN AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE) RETURN NUMBER;

FUNCTION getCostCenterOwner(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			    p_cost_center IN AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE) RETURN VARCHAR2;

FUNCTION getViolationPercentage(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN NUMBER;

FUNCTION isMissingReceiptsShortpay(p_report_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION getAwardNumber(p_award_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE InitOieAmeNotifGT(p_report_header_id IN NUMBER,
                            p_approver_id      IN NUMBER,
			    p_display_instr     OUT  NOCOPY VARCHAR2);

PROCEDURE InitOieAmeApproverAmtGT(p_report_header_id IN NUMBER);

END AP_WEB_AME_PKG;

 

/
