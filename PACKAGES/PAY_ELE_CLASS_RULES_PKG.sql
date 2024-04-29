--------------------------------------------------------
--  DDL for Package PAY_ELE_CLASS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELE_CLASS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyecr01t.pkh 115.1 2002/12/16 17:45:43 dsaxby ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_ele_class_rules_pkg
  Purpose
    Supports the ECR block in the form PAYWSDRP (Define Element and
    Distributuion Set.
  Notes

  History
    24-Mar-94  J.S.Hobbs   40.0         Date created.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a classification  --
 --   rule via the Define Element and Distributuion Set form.               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Element_Set_Id               IN OUT NOCOPY NUMBER,
                      X_Classification_Id                          NUMBER,
                      -- Extra Columns
                      X_Element_Set_Type                    VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a classification rule by applying a lock on a classification rule  --
 --   within the Define Element and Distribution Set form.                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Element_Set_Id                        NUMBER,
                    X_Classification_Id                     NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a classification  --
 --   rule via the Define Element and Distributuion Set form.               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Element_Set_Id                      NUMBER,
                      X_Classification_Id                   NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a classification  --
 --   rule via the Define Element and Distributuion Set form.               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
		      -- Extra Columns
                      X_Element_Set_Id                      NUMBER,
                      X_Classification_Id                   NUMBER);
--
END PAY_ELE_CLASS_RULES_PKG;

 

/
