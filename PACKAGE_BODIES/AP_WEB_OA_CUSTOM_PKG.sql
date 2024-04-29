--------------------------------------------------------
--  DDL for Package Body AP_WEB_OA_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_OA_CUSTOM_PKG" AS
/* $Header: apwcstmb.pls 120.4 2005/10/02 20:11:25 albowicz noship $ */


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
                                        P_CurrentPage    IN VARCHAR2) RETURN VARCHAR2 IS
        l_msgtxt VARCHAR2(2000);
    BEGIN
        /*--------------------------------------------------------------+
         |If the report has not been saved, the report header id passed |
         |into this routine will be null. The default behaviour is that |
         |the fucntion will return null. If you wish to display a       |
         |message then customixe the if statement to return the         |
         |appropriate message.                                          |
         +--------------------------------------------------------------*/
        IF (P_ReportHeaderId IS NULL OR P_ReportHeaderId = '') THEN
            --
            -- For customization, the error message goes here if the expense report
            -- is not saved. Replace the 'NULL' with your customized error/warning
            -- message.
            --
            -- SAMPLE CODE
            --
            -- If you have translation, you can use the FND_MESSAGE functionality
            -- to create your translatable message.
            --
            -- l_msgtxt := '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">'||
            --             '<tr><td height="4"></td></tr>'||
            --             '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">'||
            --             '          <tr><td width="100%" class="OraHeader">Expense Report Summary</td></tr>'||
            --             '          <tr><td class="OraBGAccentDark"></td></tr>'||
            --             '        </table></td></tr>'||
            --             '<tr><td height="2"></td></tr>'||
            --             '<tr><td><b><font size="2" face="Arial, Helvetica, sans-serif">'||
            --             'Your expense account must be "saved" to ensure the calculated totals below include '||
            --             'all appropriate amounts. If you have not done so please do so now.'||
            --             '</tr></td>'||
            --             '<tr><td height="4"></td></tr>'||
            --             '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="60%" summary="">'||
            --             '          <tr><td><span class="OraPromptText">Total Expense Amount</span></td>'||
            --             '              <td class="OraDataText" align="right" nowrap>0.00</td>'||
            --             '          </tr>'||
            --             '          <tr><td><span class="OraPromptText">Amount Paid to You by paycheck</span></td>'||
            --             '              <td class="OraDataText" align="right" nowrap>0.00</td>'||
            --             '          </tr>'||
            --             '          <tr><td><span class="OraPromptText">Amount Paid to Credit card bank on your behalf'||
            --             '</span></td>'||
            --             '              <td class="OraDataText" align="right" nowrap>0.00</td>'||
            --             '          </tr></table>'||
            --             '</td></tr></table><p></p>';

            l_msgtxt := NULL;

        ELSE
            --
            -- For customization, call your custom function which returns the
            -- message text to be displayed. The returned text should have all
            -- formatting done.
            --
            -- SAMPLE CODE
            --
            -- l_msgtxt := <Package Name>.<Function Name>(P_ReportHeaderId, P_CurrentPage);
            --

            l_msgtxt := NULL;

        END IF;

        RETURN l_msgtxt;

    END GetCustomizedExpRepSummary;


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
                                        p_reportHeaderId IN ap_expense_report_headers.report_header_id%TYPE) RETURN VARCHAR2 IS
        l_reportNumber ap_expense_report_headers.invoice_num%TYPE := NULL;
        l_userName fnd_user.user_name%TYPE := null;
        l_nReport NUMBER := 0;
    BEGIN
        -- IF (p_employeeId is not NULL AND p_userId is not NULL) THEN
            -- SAMPLE CODE
            -- If you want to access the AP_WEB_REPNUM_PREFIX profile option,
            -- use the following function:
            -- fnd_profile.value_specific( 'AP_WEB_REPNUM_PREFIX', p_userId )
            --
            -- The following sample code will generate the report invoice of <userid><YY-DDMMHHMI><-><number> format
            -- where:
            --     userid : the employee's user name
            --     YY     : the las 2 digit of the current year and
            --     number : the total number of expense reports the employee has
            --              for the current year including the current report.
            --
            --
            -- Get the user name
            -- SELECT user_name INTO l_userName
            -- FROM fnd_user fnd
            -- WHERE fnd.employee_id = p_employeeId
            --   AND fnd.user_id = p_userId
            --   AND sysdate <= nvl(fnd.end_date, sysdate)
            --   AND rownum = 1;

            -- Get the total of the number of expense report
            -- this employee has for current year
            -- SELECT count(*) INTO l_nReport
            -- FROM ap_expense_report_headers
            -- WHERE employee_id = p_employeeId
            --   AND to_char(sysdate, 'RR') = to_char(CREATION_DATE, 'RR');

            -- l_nReport := l_nReport + 1;

            -- Max length of the report number is 50
            -- l_reportNumber := SUBSTR(l_userName, 1, 30) || to_char(sysdate,'RR-DDMMHHMI') || '-'|| ltrim(to_char(l_nReport,'0999'));
        -- END IF;

        RETURN l_reportNumber;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

	WHEN OTHERS THEN
            return NULL;

    END GetNewExpenseReportInvoice;



END AP_WEB_OA_CUSTOM_PKG;

/
