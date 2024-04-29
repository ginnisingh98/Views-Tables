--------------------------------------------------------
--  DDL for Package AP_WEB_CUST_AME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CUST_AME_PKG" AUTHID CURRENT_USER AS
/* $Header: apwamecs.pls 120.5 2006/02/24 06:57:17 sbalaji noship $ */

FUNCTION getHeaderLevelApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN VARCHAR2;

FUNCTION getLineLevelApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			      p_dist_line_number IN AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE) RETURN VARCHAR2;

FUNCTION getCustomCostCenterOwner(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			    p_cost_center IN AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE) RETURN VARCHAR2;

FUNCTION getCostCenterApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN VARCHAR2;

FUNCTION getCCBusinessManager(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
			          p_cost_center IN AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE) RETURN VARCHAR2;

FUNCTION getTransactionRequestor(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE) RETURN NUMBER;

FUNCTION getProjectApprover(p_project_id IN VARCHAR2) RETURN NUMBER;

FUNCTION getAwardApprover(p_award_id IN VARCHAR2) RETURN NUMBER;

FUNCTION getDistCostCenterApprover(p_report_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
                                   p_cost_center IN VARCHAR2) RETURN NUMBER;

FUNCTION getJobSupervisorApprover(p_item_class IN VARCHAR2,
                                  p_report_header_id IN NUMBER,
              			  p_item_id IN VARCHAR2
                                 ) RETURN NUMBER;

END AP_WEB_CUST_AME_PKG;

 

/
