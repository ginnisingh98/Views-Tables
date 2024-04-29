--------------------------------------------------------
--  DDL for Package IGI_BUD_CODE_COMBINATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_CODE_COMBINATIONS_PKG" AUTHID CURRENT_USER as
--  $Header: igibudis.pls 120.3 2005/10/30 05:57:55 appldev ship $

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Code_Combination_Id              NUMBER,
                     X_Igi_Balanced_Budget_Flag         VARCHAR2
  ) ;


  PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Code_Combination_Id             NUMBER,
                       X_Igi_Balanced_Budget_Flag       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) ;

END IGI_BUD_CODE_COMBINATIONS_PKG;

/
