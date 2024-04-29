--------------------------------------------------------
--  DDL for Package IGW_PROP_COMMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_COMMENTS_PKG" AUTHID CURRENT_USER as
--$Header: igwprnps.pls 115.3 2002/03/28 19:13:44 pkm ship    $

  PROCEDURE Insert_Row(X_Rowid IN OUT      VARCHAR2,
                       X_Proposal_Id       NUMBER,
                       X_Comment_Id        NUMBER,
                       X_Comments          VARCHAR2,
                       X_Last_Update_Date  DATE,
                       X_Last_Updated_By   NUMBER,
                       X_Creation_Date     DATE,
                       X_Created_By        NUMBER,
                       X_Last_Update_Login NUMBER);

  PROCEDURE Update_Row(X_Rowid             VARCHAR2,
                       X_Proposal_Id       NUMBER,
                       X_Comment_Id        NUMBER,
                       X_Comments          VARCHAR2,
                       X_Last_Update_Date  DATE,
                       X_Last_Updated_By   NUMBER,
                       X_Creation_Date     DATE,
                       X_Created_By        NUMBER,
                       X_Last_Update_Login NUMBER);

  PROCEDURE Lock_Row(X_Rowid               VARCHAR2,
                       X_Proposal_Id       NUMBER,
                       X_Comment_Id        NUMBER,
                       X_Comments          VARCHAR2,
                       X_Last_Update_Date  DATE,
                       X_Last_Updated_By   NUMBER,
                       X_Creation_Date     DATE,
                       X_Created_By        NUMBER,
                       X_Last_Update_Login NUMBER);

  PROCEDURE Delete_Row(X_Rowid             VARCHAR2);

END IGW_PROP_COMMENTS_PKG;

 

/
