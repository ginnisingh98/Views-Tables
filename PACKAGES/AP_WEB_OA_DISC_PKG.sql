--------------------------------------------------------
--  DDL for Package AP_WEB_OA_DISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_DISC_PKG" AUTHID CURRENT_USER AS
/* $Header: apwoadis.pls 115.7 2004/01/30 05:00:13 ammishra noship $ */

SUBTYPE DefaultExchangeRates   IS AP_POL_EXRATE_OPTIONS.default_exchange_rates%TYPE;

TYPE PolicyRateOptionsRec	IS RECORD (
   default_exchange_rates  DefaultExchangeRates
);


Procedure OAExpReport(
        p_exp            IN VARCHAR2,
        p_empid          IN VARCHAR2,
        p_receipt_count      OUT NOCOPY  NUMBER,
        p_receipt_with_error OUT NOCOPY  NUMBER,
        p_error_type     OUT NOCOPY VARCHAR2,
        p_return_status  OUT NOCOPY VARCHAR2,
        p_msg_count      OUT NOCOPY NUMBER,
        p_msg_data       OUT NOCOPY VARCHAR2);


Function AreMPDRateSchedulesAssigned (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE) RETURN  boolean;
Function ArePCRateSchedulesAssigned (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE) RETURN  boolean;
Function AreExpenseFieldsRequired (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE) RETURN  boolean;
Function AreExpenseFieldsEnabled (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE) RETURN  boolean;
Function IsItemizationRequired (p_parameter_id IN ap_expense_report_params.parameter_id%TYPE) RETURN  boolean;
Function AreMerchantFieldsRequired RETURN  boolean;
Function IsExchangeRateSetup RETURN  boolean;
Function IsGrantsEnabled RETURN  boolean;
Function IsLineLevelAcctingEnabled RETURN  boolean;
/*========================================================================
 | PROCEDURE GetPolicyRateOptions
 |
 | DESCRIPTION
 |   Get the default_exchange_rates from ap_pol_exrate_options
 |   we can add other fields to the record PolicyRateOptionsRec and
 |   the select statement to get values for other fields
 |
 | PARAMETERS
 |  None
 |
 | MODIFICATION HISTORY
 | Date                  Author                     Description of Changes
 | 28-JUL-2003           Srihari Koukuntla          Created
 |
 *=======================================================================*/
PROCEDURE GetPolicyRateOptions(p_policyRateOptions OUT NOCOPY PolicyRateOptionsRec);

END AP_WEB_OA_DISC_PKG;


 

/
