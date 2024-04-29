--------------------------------------------------------
--  DDL for Package AP_WEB_DB_VIOLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_VIOLATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbvis.pls 120.2.12010000.2 2010/04/16 11:57:19 dsadipir ship $ */

-------------------------------------------------------------------
PROCEDURE deleteViolationEntry(
        p_report_header_id      IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE);

-------------------------------------------------------------------
FUNCTION updateViolationsHeaderId(
p_ReportHeaderID           IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
p_newReportHeaderID        IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE)
RETURN BOOLEAN;

--------------------------------------------------------------------------------
PROCEDURE SetVioPolicyShortpaidReportID(
        p_orig_expense_report_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_report_header_id  IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE);
-------------------------------------------------------------------------------
PROCEDURE SetVioReceiptShortpaidReportID(
        p_orig_expense_report_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_report_header_id   IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE);
-------------------------------------------------------------------------------
PROCEDURE SetViolationBothpaidReportID(
        p_orig_expense_report_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_report_header_id   IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE);
-------------------------------------------------------------------------------
PROCEDURE deleteDupViolationEntry(
        p_report_header_id IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE);
-------------------------------------------------------------------------------


END AP_WEB_DB_VIOLATIONS_PKG;

/
