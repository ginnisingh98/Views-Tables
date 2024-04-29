--------------------------------------------------------
--  DDL for Package PAY_BAL_CLASSIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_CLASSIFICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pyblc01t.pkh 115.4 2002/12/06 14:20:15 alogue ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_bal_classifications_pkg
  Purpose
    Used by PAYWSDBT (Define Balance Type) for the balance classification
    block (BLC).
  Notes

  History
    01-Mar-94  J.S.Hobbs   40.0         Date created.
    01-Feb-95  J.S.Hobbs   40.4         Removed aol WHO columns.
    16-NOV-2001 RThirlby  115.1  930964 New parameter X_mode added to procedure
             delivered in patch 2000669 insert_row so that the startup mode
                                        (either GENERIC, STARTUP or USER) can
                                        be identified. This is required, as a
                                        enhancement request was made where by
                                        functionality for chk_bal_clasification
                                        if different depending on what mode
                                        you are in. In USER mode there is no
                                        change. In STARTUP mode, it is now
                                        possible to feed a balance from more
                                        than one secondary classifcation.
    16-NOV-2001 RThirlby  115.2         Added commit to end of file for GSCC
                                        standards.
    01-JUL-2002 RCallaghan 115.3        Added checkfile line
    06-DEC-2002 ALogue     115.4        NOCOPY changes.  Bug 2692195.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a balance         --
 --   classification via the Define Balance Type form.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   Bug 930964 - new parameter X_mode, to enable different functionality  --
 --                in chk_balance_classification depending on the startup   --
 --                mode.
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                     IN OUT NOCOPY VARCHAR2,
                      X_Balance_Classification_Id IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id                NUMBER,
                      X_Legislation_Code                 VARCHAR2,
                      X_Balance_Type_Id                  NUMBER,
                      X_Classification_Id                NUMBER,
                      X_Scale                            NUMBER,
                      X_Legislation_Subgroup             VARCHAR2,
                      X_mode                             VARCHAR2 default null);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a balance classification by applying a lock on a balance           --
 --   classification in the Define Balance Type form.                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Balance_Classification_Id             NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Classification_Id                     NUMBER,
                    X_Scale                                 NUMBER,
                    X_Legislation_Subgroup                  VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a balance         --
 --   classification via the Define Balance Type form.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Classification_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Classification_Id                   NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a balance         --
 --   classification via the Define Balance Type form.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                      VARCHAR2,
                      -- Extra Columns
                      X_Balance_Classification_Id  NUMBER);
--
END PAY_BAL_CLASSIFICATIONS_PKG;

 

/
