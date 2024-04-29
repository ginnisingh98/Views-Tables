--------------------------------------------------------
--  DDL for Package QA_SEQ_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SEQ_AUDIT_PKG" AUTHID CURRENT_USER as
/* $Header: qaseqads.pls 115.0 2003/08/26 13:49:57 rponnusa noship $ */
  PROCEDURE Insert_Row(P_Rowid                  IN OUT NOCOPY VARCHAR2,
                       P_Plan_Id                NUMBER,
                       P_Collection_Id          NUMBER,
                       P_Occurrence             NUMBER,
                       P_Char_Id                NUMBER,
                       P_Txn_Header_Id          NUMBER,
                       P_Sequence_Value         VARCHAR2,
                       P_User_Id                NUMBER,
                       P_Source_Code            VARCHAR2,
                       P_Source_Id              NUMBER,
                       P_Audit_Type             VARCHAR2,
		       P_Audit_Date             DATE,
                       P_Last_Update_Date       DATE,
                       P_Last_Updated_By        NUMBER,
                       P_Creation_Date          DATE,
                       P_Created_By             NUMBER,
                       P_Last_Update_Login      NUMBER
                      );

  PROCEDURE Lock_Row  (P_Rowid                  VARCHAR2,
                       P_Plan_Id                NUMBER,
                       P_Collection_Id          NUMBER,
                       P_Occurrence             NUMBER,
                       P_Char_Id                NUMBER,
                       P_Txn_Header_Id          NUMBER,
                       P_Sequence_Value         VARCHAR2,
                       P_User_Id                NUMBER,
                       P_Source_Code            VARCHAR2,
                       P_Source_Id              NUMBER,
                       P_Audit_Type             VARCHAR2,
                       P_Audit_Date             DATE,
                       P_Last_Update_Date       DATE,
                       P_Last_Updated_By        NUMBER,
                       P_Creation_Date          DATE,
                       P_Created_By             NUMBER,
                       P_Last_Update_Login      NUMBER
                      );

  PROCEDURE Update_Row(P_Rowid                  VARCHAR2,
                       P_Plan_Id                NUMBER,
                       P_Collection_Id          NUMBER,
                       P_Occurrence             NUMBER,
                       P_Char_Id                NUMBER,
                       P_Txn_Header_Id          NUMBER,
                       P_Sequence_Value         VARCHAR2,
                       P_User_Id                NUMBER,
                       P_Source_Code            VARCHAR2,
                       P_Source_Id              NUMBER,
                       P_Audit_Type             VARCHAR2,
                       P_Audit_Date             DATE,
                       P_Last_Update_Date       DATE,
                       P_Last_Updated_By        NUMBER,
                       P_Creation_Date          DATE,
                       P_Created_By             NUMBER,
                       P_Last_Update_Login      NUMBER
                      );

  PROCEDURE Delete_Row(P_Rowid VARCHAR2);


END QA_SEQ_AUDIT_PKG;

 

/
