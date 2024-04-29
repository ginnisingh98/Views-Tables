--------------------------------------------------------
--  DDL for Package RG_DSS_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_VARIABLES_PKG" AUTHID CURRENT_USER as
/*$Header: rgidvars.pls 120.3 2003/04/29 00:47:32 djogg ship $*/

  /* Name: get_new_id
   * Desc: Return the next value from the sequence rg_dss_variables_s.
   *
   * History:
   *   09/14/95   S. Rahman   Created.
   */
  FUNCTION get_new_id RETURN NUMBER;


  FUNCTION num_dimensions(X_Variable_Id NUMBER) RETURN NUMBER;

  /* Name: used_in_frozen_system
   * Desc: Return TRUE if the financial data is used in a frozen system;
   *       FALSE otherwise.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  FUNCTION used_in_frozen_system(X_Variable_Id NUMBER) RETURN BOOLEAN;


  /* Name: check_for_details
   * Desc: Check if at least one dimension exists for the variable,
   *       and if at least one summary dimension exists for a summary
   *       level variable. Raise exception otherwise.
   *
   * History:
   *   00/14/95   S. Rahman         Created.
   *   07/03/97   Charmaine Wang    Modified for R11.
   */
  PROCEDURE check_for_details(X_Variable_Id NUMBER,
                              X_Level_Code  VARCHAR2);


  /* Name: check_unique_name
   * Desc: Check if the variable name already exists. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_name(X_Rowid VARCHAR2, X_Name VARCHAR2);


  /* Name: check_unique_object_name
   * Desc: Check if the object name already exists. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_object_name(X_Rowid VARCHAR2, X_Object_Name VARCHAR2);


  /* Name: check_references
   * Desc: Check if the variable is used in a system.
   *
   * History:
   *   07/17/95   S. Rahman   Created.
   */
  PROCEDURE check_references(X_Variable_Id NUMBER);

-- Function generate_matching_struc
-- Purpose
--   Generate the matching structure for summary templates
-- History:
--   07/02/97    Charmaine Wang Created.

  PROCEDURE generate_matching_struc(
                       X_Variable_Id                    NUMBER,
                       X_Chart_of_Account_Id            NUMBER,
                       X_Segment1_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment2_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment3_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment4_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment5_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment6_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment7_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment8_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment9_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment10_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment11_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment12_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment13_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment14_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment15_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment16_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment17_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment18_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment19_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment20_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment21_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment22_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment23_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment24_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment25_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment26_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment27_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment28_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment29_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment30_Type         IN OUT NOCOPY     VARCHAR2
                      );

  /* Name: insert_row
   * Desc: Insert a row into rg_dss_variables. Ensure that the
   *       variable name doesn't exist already. Assign the
   *       primary key (variable_id). Return the rowid of the inserted
   *       row to the form. Also generates matching structure.
   *
   * History:
   *   06/20/95   S. Rahman        Created.
   *   07/03/97   Charmaine Wang   Modified for R11.
   */
  PROCEDURE Insert_Row(X_Rowid                       IN OUT NOCOPY VARCHAR2,
                     X_Variable_Id                   IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Object_Name                          VARCHAR2,
                     X_Column_Label                         VARCHAR2,
                     X_Balance_Type                         VARCHAR2,
                     X_Currency_Type                        VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Budget_Version_Id                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Level_Code                           VARCHAR2,
                     X_Status_Code                          VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Segment1_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment2_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment3_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment4_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment5_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment6_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment7_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment8_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment9_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment10_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment11_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment12_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment13_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment14_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment15_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment16_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment17_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment18_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment19_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment20_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment21_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment22_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment23_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment24_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment25_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment26_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment27_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment28_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment29_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment30_Type            IN OUT NOCOPY     VARCHAR2);


  /* Name: lock_row
   * Desc: Lock the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
                     X_Variable_Id                          NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Object_Name                          VARCHAR2,
                     X_Column_Label                         VARCHAR2,
                     X_Balance_Type                         VARCHAR2,
                     X_Currency_Type                        VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Budget_Version_Id                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Level_Code                           VARCHAR2,
                     X_Status_Code                          VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Segment1_Type                        VARCHAR2,
                     X_Segment2_Type                        VARCHAR2,
                     X_Segment3_Type                        VARCHAR2,
                     X_Segment4_Type                        VARCHAR2,
                     X_Segment5_Type                        VARCHAR2,
                     X_Segment6_Type                        VARCHAR2,
                     X_Segment7_Type                        VARCHAR2,
                     X_Segment8_Type                        VARCHAR2,
                     X_Segment9_Type                        VARCHAR2,
                     X_Segment10_Type                       VARCHAR2,
                     X_Segment11_Type                       VARCHAR2,
                     X_Segment12_Type                       VARCHAR2,
                     X_Segment13_Type                       VARCHAR2,
                     X_Segment14_Type                       VARCHAR2,
                     X_Segment15_Type                       VARCHAR2,
                     X_Segment16_Type                       VARCHAR2,
                     X_Segment17_Type                       VARCHAR2,
                     X_Segment18_Type                       VARCHAR2,
                     X_Segment19_Type                       VARCHAR2,
                     X_Segment20_Type                       VARCHAR2,
                     X_Segment21_Type                       VARCHAR2,
                     X_Segment22_Type                       VARCHAR2,
                     X_Segment23_Type                       VARCHAR2,
                     X_Segment24_Type                       VARCHAR2,
                     X_Segment25_Type                       VARCHAR2,
                     X_Segment26_Type                       VARCHAR2,
                     X_Segment27_Type                       VARCHAR2,
                     X_Segment28_Type                       VARCHAR2,
                     X_Segment29_Type                       VARCHAR2,
                     X_Segment30_Type                       VARCHAR2
                   );


  /* Name: update_row
   * Desc: Update the row specified by X_Rowid.
   *       Also generates matching structure.
   *
   * History:
   *   06/20/95   S. Rahman       Created.
   *   07/03/97   Charmaine Wang  Modified.
   */
  PROCEDURE Update_Row(X_Rowid                              VARCHAR2,
                     X_Variable_Id                          NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Object_Name                          VARCHAR2,
                     X_Column_Label                         VARCHAR2,
                     X_Balance_Type                         VARCHAR2,
                     X_Currency_Type                        VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Budget_Version_Id                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Level_Code                           VARCHAR2,
                     X_Status_Code                          VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Segment1_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment2_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment3_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment4_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment5_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment6_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment7_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment8_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment9_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment10_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment11_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment12_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment13_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment14_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment15_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment16_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment17_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment18_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment19_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment20_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment21_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment22_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment23_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment24_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment25_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment26_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment27_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment28_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment29_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment30_Type            IN OUT NOCOPY     VARCHAR2);


  /* Name: delete_row
   * Desc: Delete the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Variable_Id NUMBER);


END RG_DSS_VARIABLES_PKG;

 

/
