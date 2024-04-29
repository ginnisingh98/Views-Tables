--------------------------------------------------------
--  DDL for Package PAAP_PWP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAAP_PWP_PKG" AUTHID CURRENT_USER AS
-- /* $Header: PAAPPWPS.pls 120.1.12010000.7 2009/07/31 11:11:29 jravisha noship $ */

  Type InvoiceId Is Table Of AP_INVOICES_ALL.INVOICE_ID%Type Index By Binary_Integer;

  ProjFunc_Currency                         PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;
  Proj_Currency                             PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  Pa_Curr_Code                              PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  ProjFunc_Cst_Rate_Date                    PA_PROJECTS_ALL.PROJFUNC_BIL_RATE_DATE%TYPE;
  ProjFunc_Cst_Rate_Type                    PA_PROJECTS_ALL.PROJFUNC_BIL_RATE_TYPE%TYPE;
  ProjFunc_Cst_Rate                         NUMBER;
  Proj_Cst_Rate_Date                        PA_PROJECTS_ALL.PROJECT_BIL_RATE_DATE%TYPE;
  Proj_Cst_Rate_Type                        PA_PROJECTS_ALL.PROJECT_BIL_RATE_TYPE%TYPE;
  Proj_Cst_Rate                             NUMBER;
  Acct_Cst_Rate_Date                        PA_PROJECTS_ALL.PROJECT_BIL_RATE_DATE%TYPE;
  Acct_Cst_Rate_Type                        PA_PROJECTS_ALL.PROJECT_BIL_RATE_TYPE%TYPE;
  Acct_Cst_Rate                             NUMBER;
  G_Project_Id                              PA_PROJECTS_ALL.PROJECT_ID%TYPE;
  G_Invoice_Id                              AP_INVOICES_ALL.INVOICE_ID%TYPE;
  G_From_Curr                               PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE; /*Bug# 7830751*/

  G_Task_Id                                 PA_TASKS.TASK_ID%TYPE;
  G_Expenditure_Item_Date                   PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_DATE%TYPE;

  G_Draft_Inv_Num                           PA_CUST_REV_DIST_LINES.DRAFT_INVOICE_NUM%TYPE;
  G_InvId_Tab                               InvoiceId;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure populates pa_pwp_ap_inv_hdr, pa_pwp_ap_inv_dtl tables by processing all the supplier
    -- invoices pertaining to the project_id being passed. Returns Success/Failure to the calling module.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER         YES       It stores the project_id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  X_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                  Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  X_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  x_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Process_SuppInv_Dtls1  (P_Project_Id      IN  NUMBER
                                   ,X_return_status   OUT NOCOPY VARCHAR2
                                   ,X_msg_count       OUT NOCOPY NUMBER
                                   ,X_msg_data        OUT NOCOPY VARCHAR2);



  ---------------------------------------------------------------------------------------------------------
    -- This procedure in turn calls Process_SuppInv_Dtls1, to populate pa_pwp_ap_inv_hdr, pa_pwp_ap_inv_dtl
    -- tables by processing all the supplier invoices pertaining to the project_id being passed.
    -- This is being called from the Summary Page of Subcontractor tab.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER         YES       It stores the project_id
    -- Out parameters
  ----------------------------------------------------------------------------------------------------------
  Procedure Process_SuppInv_Dtls   (P_Project_Id  IN NUMBER,P_Draft_Inv_Num IN Number :='');


  ---------------------------------------------------------------------------------------------------------
    -- This function derives the all the conversion attributes from any currency passed as a parameter to
    -- Project Functional/Project/Acct Currencies. This function returns any of the Currency /Exchange Rate/
    -- Exchange Rate Date/Exchange Rate Type/Amount values based on the parameter p_ret_atr value.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER         YES       It stores the project_id
    --  p_task_id                NUMBER         YES       It stores the task_Id
    --  p_ei_date                DATE           YES       It stores the expenditure item date
    --  p_from_currency          VARCHAR2       NO        If not passed, this will be same as the
    --                                                    Functional Currency
    --  p_ret_atr                VARCHAR2       NO        Default value is 'ProjFunc_Rate'
    --                                                      Valid Values are:
    --                                                         ProjFunc_Rate
    --                                                         ProjFunc_Rate_Type
    --                                                         ProjFunc_Rate_Date
    --                                                         ProjFunc_Amt
    --                                                         Proj_Rate
    --                                                         Proj_Rate_Type
    --                                                         Proj_Rate_Date
    --                                                         Proj_Amt
    --                                                         Proj_Curr
    --                                                         ProjFunc_Curr
    --  p_amt                    NUMBER         NO        Amount to be converted
    -- Out parameters
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_Curr_Amt (P_Project_Id      IN NUMBER,
                              P_Task_Id         IN NUMBER,
                              P_EI_Date         IN DATE := SYSDATE,
                              P_FromCurrency    IN VARCHAR2 :='',
                              P_RET_ATR         IN VARCHAR2 :='ProjFunc_Rate',
                              P_Amt             IN NUMBER := 0) RETURN VARCHAR2;



  /*--------------------------------------------------------------------------------------------------------
    -- This procedure releases PWP Hold, DLV Hold for the supplier invoices passed as a pl/sql table
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  P_Inv_Tbl                PL/SQL Tbl     YES       It stores a list of invoice_id's for which
    --                                                    the PWP/DLV Hold needs to be released.
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  X_return_status          VARCHAR2       YES       The return status of the APIs.
                                                          Valid values are:
                                                          S (API completed successfully),
                                                          E (business rule violation error) and
                                                          U(Unexpected error, such as an Oracle error.
    --  X_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  x_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Paap_Release_Hold (P_Inv_Tbl         IN  InvoiceId
                              ,p_rel_option      IN VARCHAR2 := 'REL_ALL_HOLD'
                              ,X_return_status   OUT NOCOPY VARCHAR2
                              ,X_msg_count       OUT NOCOPY NUMBER
                              ,X_msg_data        OUT NOCOPY VARCHAR2);

  /*--------------------------------------------------------------------------------------------------------
    -- This procedure applies Project Hold for the supplier invoices passed as a pl/sql table
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  P_Inv_Tbl                PL/SQL Tbl     YES       It stores a list of invoice_id's for which
    --                                                    the PWP/DLV Hold needs to be released.
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  X_return_status          VARCHAR2       YES       The return status of the APIs.
                                                          Valid values are:
                                                          S (API completed successfully),
                                                          E (business rule violation error) and
                                                          U(Unexpected error, such as an Oracle error.
    --  X_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  x_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Paap_Apply_Hold (P_Inv_Tbl         IN  InvoiceId
                             ,X_return_status   OUT NOCOPY VARCHAR2
                             ,X_msg_count       OUT NOCOPY NUMBER
                             ,X_msg_data        OUT NOCOPY VARCHAR2);
END PAAP_PWP_PKG;

/
