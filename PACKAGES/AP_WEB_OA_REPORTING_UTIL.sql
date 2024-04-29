--------------------------------------------------------
--  DDL for Package AP_WEB_OA_REPORTING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_REPORTING_UTIL" AUTHID CURRENT_USER AS
/* $Header: apwrputs.pls 120.5 2005/10/02 20:19:05 albowicz noship $ */

   FUNCTION GetCostCenterSegmentName RETURN VARCHAR2;

   FUNCTION GetCostCenter (p_code_combination_id IN NUMBER) RETURN VARCHAR2;

   PROCEDURE GetUserAcctInfo ( p_cost_center_segment_name OUT NOCOPY VARCHAR2,
                               p_chart_of_accounts_id     OUT NOCOPY NUMBER,
                               p_base_currency_code       OUT NOCOPY VARCHAR2,
                               p_exchange_rate_type       OUT NOCOPY VARCHAR2);

   PROCEDURE GetBaseCurrencyInfo ( P_BaseCurrencyCode   OUT NOCOPY VARCHAR2,
                                   P_ExchangeRateType   OUT NOCOPY VARCHAR2 );

   FUNCTION MENU_ENTRY_EXISTS( p_menu_name IN VARCHAR2,
                              p_function_name IN VARCHAR2) RETURN VARCHAR2;

END AP_WEB_OA_REPORTING_UTIL;

 

/
