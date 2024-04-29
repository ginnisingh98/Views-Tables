--------------------------------------------------------
--  DDL for Package BEN_COVERED_DEPENDENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COVERED_DEPENDENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pebcd01t.pkh 115.1 2004/03/25 17:29:37 ynegoro ship $ */


  PROCEDURE Insert_Row(P_Rowid                   IN OUT nocopy VARCHAR2,
                       P_Covered_Dependent_Id    IN OUT nocopy NUMBER,
                       P_Contact_Relationship_Id        NUMBER,
                       P_Element_Entry_Id               NUMBER,
                       P_Effective_Start_Date           DATE,
                       P_Effective_End_Date             DATE
                      );

  PROCEDURE Lock_Row(P_Rowid                            VARCHAR2,
                     P_Covered_Dependent_Id             NUMBER,
                     P_Contact_Relationship_Id          NUMBER,
                     P_Element_Entry_Id                 NUMBER,
                     P_Effective_Start_Date             DATE,
                     P_Effective_End_Date               DATE
                    );

  PROCEDURE Update_Row(P_Rowid				VARCHAR2,
		       P_Covered_Dependent_Id		NUMBER,
		       P_Contact_Relationship_Id	NUMBER,
		       P_Element_Entry_Id		NUMBER,
		       P_Effective_Start_Date		DATE,
		       P_Effective_End_Date		DATE
		      );


  PROCEDURE Delete_Row(P_Rowid VARCHAR2);

  PROCEDURE Test_Path_To_PERBECVD (P_Element_Entry_Id 	NUMBER);

END BEN_COVERED_DEPENDENTS_PKG;

 

/
