--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPE_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyetr01t.pkh 115.0 99/07/17 06:02:16 porting ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_element_type_rules_pkg
  Purpose
    Supports the ETR block in the form PAYWSDRP (Define Element and
    Distributuion Set.
  Notes

  History
    24-Mar-94  J.S.Hobbs   40.0         Date created.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   include_element                                                       --
 -- Purpose                                                                 --
 --   Adds an element to a set NB. this may involve adding an include       --
 --   element rule or removing an exclude element rule.                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure include_element
 (
  p_element_set_id    number,
  p_element_type_id   number,
  p_classification_id number,
  p_element_set_type  varchar2
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   exclude_element                                                       --
 -- Purpose                                                                 --
 --   Removes an element from a set NB. this may involve adding an exclude  --
 --   element rule or removing an include element rule.                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure exclude_element
 (
  p_element_set_id  number,
  p_element_type_id number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of an element rule   --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                      X_Element_Type_Id                     NUMBER,
                      X_Element_Set_Id                      NUMBER,
                      X_Include_Or_Exclude                  VARCHAR2,
                      X_Last_Update_Date                    DATE,
                      X_Last_Updated_By                     NUMBER,
                      X_Last_Update_Login                   NUMBER,
                      X_Created_By                          NUMBER,
                      X_Creation_Date                       DATE);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of an element rule by applying a lock on an element rule within the   --
 --   Define Element and Distribution Set form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Element_Type_Id                       NUMBER,
                    X_Element_Set_Id                        NUMBER,
                    X_Include_Or_Exclude                    VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of an element rule   --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Element_Type_Id                     NUMBER,
                      X_Element_Set_Id                      NUMBER,
                      X_Include_Or_Exclude                  VARCHAR2,
                      X_Last_Update_Date                    DATE,
                      X_Last_Updated_By                     NUMBER,
                      X_Last_Update_Login                   NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of an element rule   --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
END PAY_ELEMENT_TYPE_RULES_PKG;

 

/
