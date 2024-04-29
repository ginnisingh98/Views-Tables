--------------------------------------------------------
--  DDL for Package BEN_BENEFICIARIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFICIARIES_PKG" AUTHID CURRENT_USER as
/* $Header: pebbe01t.pkh 115.0 99/07/17 18:46:23 porting ship $ */


  PROCEDURE Insert_Row(P_Rowid                   IN OUT VARCHAR2,
                       P_Beneficiary_Id          IN OUT NUMBER,
                       P_Source_Type                    VARCHAR2,
                       P_Source_Id                      NUMBER,
                       P_Element_Entry_Id               NUMBER,
                       P_Effective_Start_Date           DATE,
                       P_Effective_End_Date             DATE,
                       P_Benefit_Level                  VARCHAR2,
                       P_Proportion                     NUMBER
                      );
  --------------------------------------------------------------
  PROCEDURE Lock_Row(P_Rowid                            VARCHAR2,
                     P_Beneficiary_Id                   NUMBER,
                     P_Source_Type                      VARCHAR2,
                     P_Source_Id                        NUMBER,
                     P_Element_Entry_Id                 NUMBER,
                     P_Effective_Start_Date             DATE,
                     P_Effective_End_Date               DATE,
                     P_Benefit_Level                    VARCHAR2,
                     P_Proportion                       NUMBER
                    );
  --------------------------------------------------------------
  PROCEDURE Update_Row(P_Rowid                          VARCHAR2,
                       P_Beneficiary_Id                 NUMBER,
                       P_Source_Type                    VARCHAR2,
                       P_Source_Id                      NUMBER,
                       P_Element_Entry_Id               NUMBER,
                       P_Effective_Start_Date           DATE,
                       P_Effective_End_Date             DATE,
                       P_Benefit_Level                  VARCHAR2,
                       P_Proportion                     NUMBER
                      );
  --------------------------------------------------------------
  PROCEDURE Delete_Row(P_Rowid VARCHAR2);
  -------------------------------------------------------------
  PROCEDURE Test_Path_To_PERBEBEN (P_Element_Entry_Id 	NUMBER);

END BEN_BENEFICIARIES_PKG;

 

/
