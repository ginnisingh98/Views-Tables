--------------------------------------------------------
--  DDL for Package AP_IBY_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_IBY_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: apibexus.pls 120.2 2006/02/06 20:00:02 bghose noship $ */

/* Bug 5000194. Based on Bug 4965233 an Employee can have two types
   of Payment Function, hence Payment Function needs to be added
   as parameter */
  FUNCTION Get_Default_Iby_Bank_Acct_Id (
             X_Vendor_Id        IN      NUMBER,
             X_Vendor_Site_Id   IN      NUMBER    DEFAULT NULL,
             X_Payment_Function IN      VARCHAR2  DEFAULT NULL,
             X_Org_Id           IN      NUMBER    DEFAULT NULL,
             X_Currency_Code    IN      VARCHAR2,
             X_Calling_Sequence IN      VARCHAR2  DEFAULT NULL )
  RETURN NUMBER;

  FUNCTION Get_Default_Iby_Bank_Acct_Id (
             X_Party_Id         IN      NUMBER,
             X_Payment_Function IN      VARCHAR2,
             X_Party_Site_Id    IN      NUMBER    DEFAULT NULL,
             X_Org_Id           IN      NUMBER    DEFAULT NULL,
             X_Currency_Code    IN      VARCHAR2,
             X_Calling_Sequence IN      VARCHAR2  DEFAULT NULL )
  RETURN NUMBER;

END AP_IBY_UTILITY_PKG;

 

/
