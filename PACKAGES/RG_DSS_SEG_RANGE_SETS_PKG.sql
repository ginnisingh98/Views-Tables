--------------------------------------------------------
--  DDL for Package RG_DSS_SEG_RANGE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_SEG_RANGE_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: rgidrgss.pls 120.2 2002/11/14 02:58:56 djogg ship $ */


  /* Name: check_unique
   * Desc: Check if the segment range set name already exists. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE check_unique(X_Rowid VARCHAR2, X_Name VARCHAR2);


  /* Name: details_exist
   * Desc: Returns TRUE if there are details for the passed range_set_id,
   *       otherwise returns FALSE.
   *
   * History:
   *   06/21/95   S. Rahman   Created.
   */
  FUNCTION details_exist(X_Range_Set_id NUMBER) RETURN BOOLEAN;


  /* Name: used_in_frozen_system
   * Desc: Check if the range set is used in a frozen system.
   *
   * History:
   *   07/17/95   S. Rahman   Created.
   */
  FUNCTION used_in_frozen_system(X_Range_Set_Id NUMBER) return NUMBER;


  /* Name: details_exist
   * Desc: Check if the range set is used in a variable or dimension.
   *
   * History:
   *   07/17/95   S. Rahman   Created.
   */
  PROCEDURE check_references(X_Range_Set_Id NUMBER);


  /* Name: insert_row
   * Desc: Insert a row into rg_dss_seg_range_sets. Ensure that the
   *       segment range set name doesn't exist already. Assign the
   *       primary key (range_set_id). Return the rowid of the inserted
   *       row to the form.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Insert_Row(X_Rowid                       IN OUT NOCOPY VARCHAR2,
                     X_Range_Set_Id                  IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Application_Column_Name              VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
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
                     X_Attribute15                          VARCHAR2
                     );


  /* Name: lock_row
   * Desc: Lock the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
                     X_Range_Set_Id                         NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Application_Column_Name              VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
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
                     X_Attribute15                          VARCHAR2
                   );


  /* Name: update_row
   * Desc: Update the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Update_Row(X_Rowid                              VARCHAR2,
                     X_Range_Set_Id                         NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Application_Column_Name              VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
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
                     X_Attribute15                          VARCHAR2
                     );


  /* Name: delete_row
   * Desc: Delete the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END RG_DSS_SEG_RANGE_SETS_PKG;

 

/
