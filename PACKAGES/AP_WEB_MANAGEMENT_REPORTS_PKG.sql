--------------------------------------------------------
--  DDL for Package AP_WEB_MANAGEMENT_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_MANAGEMENT_REPORTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apwmrpts.pls 120.1.12010000.3 2008/12/18 23:57:09 rveliche ship $ */


   PROCEDURE GetBaseCurrencyInfo ( P_BaseCurrencyCode   OUT NOCOPY VARCHAR2,
                                   P_ExchangeRateType   OUT NOCOPY VARCHAR2 );

   PROCEDURE ManagerHierarchySearch ( P_EmployeeId         IN    VARCHAR2,
                                      P_ExpenseCategory    IN    VARCHAR2,
                                      P_ViolationType      IN    VARCHAR2,
                                      P_PeriodType         IN    VARCHAR2,
                                      P_Date               IN    VARCHAR2,
                                      P_UserCurrencyCode   IN    VARCHAR2,
                                      P_QryType            IN    VARCHAR2);

   PROCEDURE ExpenseCategorySearch ( P_EmployeeId         IN    VARCHAR2,
                                     P_ExpenseCategory    IN    VARCHAR2,
                                     P_ViolationType      IN    VARCHAR2,
                                     P_PeriodType         IN    VARCHAR2,
                                     P_Date               IN    VARCHAR2,
                                     P_UserCurrencyCode   IN    VARCHAR2,
                                     P_QryType            IN    VARCHAR2);

   PROCEDURE ViolationTypeSearch ( P_EmployeeId         IN    VARCHAR2,
                                   P_ExpenseCategory    IN    VARCHAR2,
                                   P_ViolationType      IN    VARCHAR2,
                                   P_PeriodType         IN    VARCHAR2,
                                   P_Date               IN    VARCHAR2,
                                   P_UserCurrencyCode   IN    VARCHAR2,
                                   P_QryType            IN    VARCHAR2);

   FUNCTION HasPermission ( P_SupervisorId IN NUMBER,
                            P_PersonId     IN NUMBER,
                            P_StartDate    IN DATE,
                            P_EndDate      IN DATE
                          ) RETURN VARCHAR2;

   FUNCTION HasPermission ( P_SupervisorId IN NUMBER,
                            P_PersonId     IN NUMBER,
                            P_PeriodType   IN VARCHAR2,
                            P_Date      IN DATE
                          ) RETURN VARCHAR2;

END AP_WEB_MANAGEMENT_REPORTS_PKG;

/
