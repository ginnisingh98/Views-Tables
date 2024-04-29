--------------------------------------------------------
--  DDL for Package AP_WEB_OA_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_CUSTOM_PKG" AUTHID CURRENT_USER AS
/* $Header: apwcstms.pls 115.2 2004/04/27 22:30:11 qle noship $ */

    -- Page Constants
    C_ReviewPage       CONSTANT VARCHAR2(30) := 'OIEReviewPage';
    C_ConfirmPage      CONSTANT VARCHAR2(30) := 'OIEConfirmPage';

    ------------------------------------------------------------------------------------
    -- Function   : GetCustomizedExpRepSummary
    -- Author     : krmenon
    -- Description: This function is part of the client extension solution which provides
    --              a way to display a customized Expense Report Summary in the
    --              Review Page and the Confirmation Page.
    -- Assumptions: In order to enable access to the amounts that the user has entered, for
    --              performing calculations, the user must save the expense report. If the
    --              user has not saved the expense report, before reaching the Review Page,
    --              the input parameter will be a null string.
    --              NO EXCEPTIONS ARE PROPAGATED TO THE CLIENT!!!
    --              Please handle all error conditions in the customization itself. Do not
    --              raise any exceptions.
    --
    -- Parameters :
    --
    --    P_ReportHeaderId    Contains the Expense Report Header Id
    --    P_CurrentPage       Contains the page where the call was made (Current Page)
    ------------------------------------------------------------------------------------
    FUNCTION GetCustomizedExpRepSummary(P_ReportHeaderId IN VARCHAR2,
                                        P_CurrentPage    IN VARCHAR2) RETURN VARCHAR2;


    ------------------------------------------------------------------------------------
    -- Function   : GetNewExpenseReportInvoice
    -- Author     : Quan Le
    -- Description: This is to enable customers to customize the way expense report invoice
    --              is created.
    -- Assumptions: Note that the max length of the report number is 50.
    --
    -- Parameters :
    --
    --    p_employeeId    id of the employee whom the report is for
    --    p_userId        fnd user_id of the employee whom the report is for
    --    p_reportHeaderId  report_header_id of the curent report
    ------------------------------------------------------------------------------------
    FUNCTION GetNewExpenseReportInvoice(p_employeeId IN ap_expense_report_headers.employee_id%TYPE,
                                        p_userId     IN fnd_user.user_id%TYPE,
                                        p_reportHeaderId IN ap_expense_report_headers.report_header_id%TYPE) RETURN VARCHAR2;

END AP_WEB_OA_CUSTOM_PKG;

 

/
