--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEEDS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEEDS_F_PKG" AUTHID CURRENT_USER as
/* $Header: pyblf01t.pkh 115.1 2003/12/08 03:56 thabara ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_balance_feeds_f_pkg
  Purpose
    Used by PAYWSDBT (Define Balance Type) for the balance feeds block (BLF).
  Notes

  History
    01-Mar-94  J.S.Hobbs   40.0         Date created.
    01-Feb-95  J.S.Hobbs   40.4         Removed aol WHO columns.
    19-Jul-95  D.Kerr      40.5		Changes to support initial balance
					upload
					Added X_Initial_Balance_Feed parameter
					to insert,update and delete procedures.
					New procedure check_run_result_usage.
    02-Oct-95  D.Kerr	   40.6 	310643 Added overloads to insert_row,
					update_row and delete_row
    08-Dec-03  T.Habara	   115.1 	Added nocopy.
                                        Added commit, dbdrv, whenever oserror.

 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a balance feed    --
 --   via the Define Balance Type form.                                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Balance_Feed_Id              IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2);
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Balance_Feed_Id              IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2,
		      X_Initial_Balance_Feed  		    BOOLEAN ) ;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a balance feed by applying a lock on a balance feed in the Define  --
 --   Balance Type form.                                                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Balance_Feed_Id                       NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Input_Value_Id                        NUMBER,
                    X_Scale                                 NUMBER,
                    X_Legislation_Subgroup                  VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a balance feed    --
 --   via the Define Balance Type form.                                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Feed_Id                     NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2);
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Feed_Id                     NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Input_Value_Id                      NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2,
		      X_Initial_Balance_Feed  		    BOOLEAN ) ;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a balance feed    --
 --   via the Define Balance Type form.                                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                VARCHAR2,
                      -- Extra Columns
                      X_Balance_Type_Id      NUMBER ) ;
 PROCEDURE Delete_Row(X_Rowid                VARCHAR2,
                      -- Extra Columns
                      X_Balance_Type_Id      NUMBER,
		      X_Input_Value_Id       NUMBER,
		      X_Initial_Balance_Feed BOOLEAN) ;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   check_run_result_usage	                                            --
 -- Purpose                                                                 --
 --  Checks to see whether the given input value has produced any run       --
 --  results. This is used to prevent an initial balance feed from being    --
 --  updated or deleted.						    --
 -- 									    --
 --  The function version returns FALSE if the input value is in use and    --
 --  TRUE otherwise							    --
 --  The procedure version raises an error if the input value is in use.    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
 FUNCTION  check_run_result_usage ( X_Input_Value_Id  IN NUMBER )
						RETURN BOOLEAN ;
 PROCEDURE check_run_result_usage ( X_Input_Value_Id  IN NUMBER ) ;
--
END PAY_BALANCE_FEEDS_F_PKG;

 

/
