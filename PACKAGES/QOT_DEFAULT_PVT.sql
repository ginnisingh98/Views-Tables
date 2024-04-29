--------------------------------------------------------
--  DDL for Package QOT_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QOT_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: qotvdefs.pls 120.4 2006/09/28 09:00:11 hekumar noship $ */
-- Package name     : QOT_DEFAULT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT    VARCHAR2(30):=  'QOT_DEFAULT_PVT';


FUNCTION Get_CustAcct_From_CustParty (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_PriceList_From_Agreement (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_PriceList_From_CustAcct (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_PriceList_From_OrderType (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_PaymentTerm_From_Agreement (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_ExpirationDate (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN DATE;

FUNCTION Get_QuoteAddress (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_QuotePhone (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_BillAddress (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_ShipAddress (
		   P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_SalesGroup_From_Profile (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_SalesGroup_From_Salesrep(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_SalesRep(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_Currency_From_Pricelist(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN VARCHAR2;

FUNCTION Get_Currency_from_Profile(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN VARCHAR2;

FUNCTION Get_OperatingUnit(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_OrderType(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_ContractTemplate(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_RequestedDateType(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN VARCHAR2;

FUNCTION Get_PaymentTerm_From_Customer(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER;

FUNCTION Get_ChargePeriodicity(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN VARCHAR2;

END QOT_DEFAULT_PVT;

 

/
