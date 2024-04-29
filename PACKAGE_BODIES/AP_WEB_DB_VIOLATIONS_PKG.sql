--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_VIOLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_VIOLATIONS_PKG" AS
/* $Header: apwdbvib.pls 120.4.12010000.3 2010/06/22 10:51:19 rveliche ship $ */

--------------------------------------------------------------------------------
PROCEDURE deleteViolationEntry(
        p_report_header_id      IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE) IS
-------------------------------------------------------------------------------
  l_debug_info	     VARCHAR2(200);

BEGIN
  DELETE
  FROM	 ap_pol_violations
  WHERE	 report_header_id = p_report_header_id;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('deleteViolationEntry');
    APP_EXCEPTION.RAISE_EXCEPTION;
END deleteViolationEntry;

-------------------------------------------------------------------------------
FUNCTION updateViolationsHeaderId(
p_ReportHeaderID           IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
p_newReportHeaderID        IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
        -- set the report_header_id for the line

        UPDATE ap_pol_violations
        SET    report_header_id = p_newReportHeaderID
        WHERE  report_header_id = p_ReportHeaderID
        AND    distribution_line_number IN(
          SELECT distribution_line_number
          FROM   ap_expense_report_lines
          WHERE  report_header_id = p_newReportHeaderID);

        return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('updateViolationsHeaderId');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END updateViolationsHeaderId;

--------------------------------------------------------------------------------
PROCEDURE SetVioPolicyShortpaidReportID(
        p_orig_expense_report_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_report_header_id  IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE)IS
-------------------------------------------------------------------------------
  l_debug_info	     VARCHAR2(200);

BEGIN

  UPDATE ap_pol_violations
  SET	 report_header_id = p_new_report_header_id
  WHERE  distribution_line_number IN
      (select distribution_line_number
       from   ap_expense_report_lines
       where  report_header_id = p_new_report_header_id
       and   ( nvl(policy_shortpay_flag,'N') = 'Y'
               or
              (itemization_parent_id in
                  (select report_line_id
                   from   ap_expense_report_lines
                   where  report_header_id = p_new_report_header_id
                   and    nvl(policy_shortpay_flag,'N') = 'Y'
                   and    itemization_parent_id = -1
                  )
              )
            ))
  AND    report_header_id = p_orig_expense_report_id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetVioPolicyShortpaidReportID');
    APP_EXCEPTION.RAISE_EXCEPTION;
END SetVioPolicyShortpaidReportID;
--------------------------------------------------------------------------------
PROCEDURE SetVioReceiptShortpaidReportID(
        p_orig_expense_report_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_report_header_id   IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE)IS
-------------------------------------------------------------------------------
  l_debug_info	     VARCHAR2(200);

BEGIN
  UPDATE ap_pol_violations
  SET	 report_header_id = p_new_report_header_id
  WHERE  distribution_line_number IN
      (select distribution_line_number
       from   ap_expense_report_lines
       where  report_header_id = p_new_report_header_id
       and    (((receipt_required_flag = 'Y' OR image_receipt_required_flag = 'Y')
                and    nvl(receipt_verified_flag,'N') = 'N'
                and    nvl(policy_shortpay_flag, 'N') = 'N'
               )
               or
               (itemization_parent_id in
                 (select report_line_id
                  from   ap_expense_report_lines
                  where  report_header_id = p_new_report_header_id
                  and    (receipt_required_flag = 'Y' OR image_receipt_required_flag = 'Y')
                  and    nvl(receipt_verified_flag,'N') = 'N'
                  and    nvl(policy_shortpay_flag, 'N') = 'N'
                  and    itemization_parent_id = -1
                 )
               )
              ))
  AND    report_header_id = p_orig_expense_report_id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetVioReceiptShortpaidReportID');
    APP_EXCEPTION.RAISE_EXCEPTION;
END SetVioReceiptShortpaidReportID;
--------------------------------------------------------------------------------

PROCEDURE SetViolationBothpaidReportID(
        p_orig_expense_report_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_report_header_id   IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE)IS
-------------------------------------------------------------------------------
  l_debug_info	     VARCHAR2(200);

BEGIN
  UPDATE ap_pol_violations
  SET	 report_header_id = p_new_report_header_id
  WHERE  distribution_line_number IN
     (SELECT distribution_line_number
      FROM   ap_expense_report_lines
      WHERE  report_header_id = p_orig_expense_report_id
      AND    credit_card_trx_id IS NOT NULL)
  AND    report_header_id = p_orig_expense_report_id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetViolationBothpaidReportID');
    APP_EXCEPTION.RAISE_EXCEPTION;
END SetViolationBothpaidReportID;
--------------------------------------------------------------------------------

PROCEDURE deleteDupViolationEntry(
        p_report_header_id IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE) IS
--------------------------------------------------------------------------------

  l_report_prefix VARCHAR2(10);
  l_report_header_id VARCHAR2(30);

BEGIN

  FND_PROFILE.GET('AP_WEB_REPNUM_PREFIX', l_report_prefix);
  l_report_header_id := l_report_prefix || To_Char(p_report_header_id);

  DELETE FROM ap_pol_violations_all
  WHERE dup_report_header_id = l_report_header_id;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('deleteDupViolationEntry');
    APP_EXCEPTION.RAISE_EXCEPTION;

END deleteDupViolationEntry;
--------------------------------------------------------------------------------

END AP_WEB_DB_VIOLATIONS_PKG;

/
