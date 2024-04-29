--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: pyels01t.pkh 120.0 2005/09/27 04:03:51 shisriva noship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_element_sets_pkg
  Purpose
    Supports the ELS block in the form PAYWSDRP (Define Element and
    Distributuion Set.
  Notes

  History
    24-Mar-94  J.S.Hobbs   40.0         Date created.
    26-Aug-05  Shisriva      115.1       Changes for MLS enabling.
						     Added extra parameter in update_row proc. and
						     New procedures - validate_translations,
						                               add_language,
									       translate_row,
									       set_translation_globals
   26-Sep-05  Shisriva      115.2        Added dbdrv commands.
   26-Sep-05  Shisriva      115.3        Removed gscc violation for in out parameters.
						     Added NOCOPY for two parameters.
 ============================================================================*/
--
--
g_dml_status boolean := FALSE;  -- Global package variable
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   lock_element_set                                                      --
 -- Purpose                                                                 --
 --   Places a lock on the element set.                                     --
 -- Arguments                                                               --
 --   See Be;ow.                                                            --
 -- Notes                                                                   --
 --   Used when maintaining the members of an element set ie. when dealing  --
 --   with element type rules and classification rules.                     --
 -----------------------------------------------------------------------------
--
 procedure lock_element_set
 (
  p_element_set_id number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_debit_or_credit                                                   --
 -- Purpose                                                                 --
 --   When creating a distribution set all the elements within the set must --
 --   have the same debit or credit status ie. the combination of element   --
 --   rules and classification rules should result in a set of elements     --
 --   that have the same debit or credit status.                            --
 -- Arguments                                                               --
 --   p_classification_id - If adding an element type rule then this is the --
 --                         classification_of the element being added.      --
 --                         If adding a classification rule then this is    --
 --                         classification_of of the classification being   --
 --                         added.                                          --
 -- Notes                                                                   --
 --   This is used when adding element type or classification rules.        --
 -----------------------------------------------------------------------------
--
 procedure chk_debit_or_credit
 (
  p_element_set_id    number,
  p_classification_id number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of an element set    --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid             IN OUT NOCOPY VARCHAR2,
                      X_Element_Set_Id               IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Element_Set_Name                    VARCHAR2,
                      X_Element_Set_Type                    VARCHAR2,
                      X_Comments                            VARCHAR2,
                      -- Extra Columns
                      X_Session_Business_Group_Id           NUMBER,
                      X_Session_Legislation_Code            VARCHAR2);

--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of an element set by applying a lock on an element set within the     --
 --   Define Element and Distribution Set form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Element_Set_Id                        NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Element_Set_Name                      VARCHAR2,
                    X_Element_Set_Type                      VARCHAR2,
                    X_Comments                              VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of an element set    --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Element_Set_Id                      NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Element_Set_Name                    VARCHAR2,
                      X_Element_Set_Type                    VARCHAR2,
                      X_Comments                            VARCHAR2,
                      -- Extra Columns
                      X_Session_Business_Group_Id           NUMBER,
                      X_Session_Legislation_Code            VARCHAR2,
		      X_Base_Element_Set_Name in varchar2 default hr_api.g_varchar2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of an element set    --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
                      -- Extra Columns
                      X_Element_Set_Id                      NUMBER,
                      X_Element_Set_Type                    VARCHAR2);
--
--MLS Additions--
--
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (X_B_ELEMENT_SET_NAME in VARCHAR2,
					    X_B_LEGISLATION_CODE in VARCHAR2,
					    X_ELEMENT_SET_NAME in VARCHAR2,
					    X_OWNER in VARCHAR2);

procedure set_translation_globals( p_business_group_id IN NUMBER
                                 , p_legislation_code  IN NUMBER);

procedure validate_translation(element_set_id	NUMBER,
			       language		VARCHAR2,
			       element_set_name	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL);

function return_dml_status return boolean;
---
END PAY_ELEMENT_SETS_PKG;

 

/
