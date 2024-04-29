--------------------------------------------------------
--  DDL for Package PA_CAPITAL_PROJECT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CAPITAL_PROJECT_UTILS" AUTHID CURRENT_USER as
/* $Header: PAXCAUTS.pls 115.2 2003/08/14 23:36:39 pbandla noship $ */

   Function UnReversed_Assets_Exist
              (P_Asset_Id In Number) RETURN VARCHAR2;

   Function UnReversed_Costs_Exist
              (P_EI_Id In Number) RETURN VARCHAR2;

   Function Reverse_Event_Allow(P_Project_Id in Number,
                                P_Capital_Event_Id in Number)
         Return Varchar2;

   Function Reverse_Event_Upd(P_Project_Id in Number,
                              P_Capital_Event_Id in Number)
         Return Number;

   Function Is_Asset_Adj_Allowed(P_Fa_Asset_Id in Number,
                                 P_Book_Type_Code in Varchar2)
         Return Number;

   Function Tag_Number_Exists(P_Tag_Number in Varchar2) RETURN VARCHAR2;

   Function Allow_AssetType_Change(P_From_Asset_Type  in Varchar2,
                                   P_To_Asset_Type    in Varchar2,
                                   P_Project_Asset_Id in Number,
                                   P_Capitalized_Flag in Varchar2,
                                   P_Capital_Event_Id in Number
                                  ) Return Varchar2;

   PROCEDURE get_depreciation_expense_ccid
              (P_project_asset_id        IN  NUMBER,
               P_book_type_code          IN  VARCHAR2,
               P_asset_category_id       IN  NUMBER,
               P_date_placed_in_service  IN  DATE,
               P_deprn_expense_ccid      IN  NUMBER,
               X_Deprn_expense_CCID      OUT NOCOPY NUMBER,
               X_Error_Message_Code      OUT NOCOPY VARCHAR2
              );

   FUNCTION Can_Delete_Event(P_Project_Id in NUMBER, P_Capital_Event_Id in NUMBER) RETURN VARCHAR2;

   G_CCID_Tab PA_PLSQL_DATATYPES.Char1TabTyp;

   Function IsValidExpCCID(P_CCID    IN NUMBER) RETURN VARCHAR2;


END PA_CAPITAL_PROJECT_UTILS;

 

/
