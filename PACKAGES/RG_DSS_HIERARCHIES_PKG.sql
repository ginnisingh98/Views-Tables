--------------------------------------------------------
--  DDL for Package RG_DSS_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_HIERARCHIES_PKG" AUTHID CURRENT_USER as
/* $Header: rgidhrcs.pls 120.2 2002/11/14 02:58:32 djogg ship $ */


  /* Name: get_new_id
   * Desc: Gets a new id from the sequence RG_DSS_HIERARCHIES_S
   *
   * History:
   *   11/02/95   S. Rahman   Created.
   */
  FUNCTION get_new_id RETURN NUMBER;


  /* Name: used_in_frozen_system
   * Desc: Return TRUE if the hierarchy is used in a frozen system;
   *       FALSE otherwise.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  FUNCTION used_in_frozen_system(X_Hierarchy_Id NUMBER) RETURN BOOLEAN;


  /* Name: check_unique_name
   * Desc: Check if the hierarchy name already exists. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_name(X_Rowid VARCHAR2, X_Name VARCHAR2);


  /* Name: details_exists
   * Desc: Return TRUE if any details records exist; otherwise return FALSE.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  FUNCTION details_exists(X_Hierarchy_Id NUMBER) RETURN BOOLEAN;


  /* Name: num_details
   * Desc: Return the number detail records for this hierarchy.
   *
   * History:
   *   11/02/95   S. Rahman   Created.
   */
  FUNCTION num_details(X_Hierarchy_Id NUMBER) RETURN NUMBER;


  /* Name: check_references
   * Desc: Check if the hierarchy is used in a system.
   *
   * History:
   *   07/17/95   S. Rahman   Created.
   */
  PROCEDURE check_references(X_Hierarchy_Id NUMBER);


  /* Name: insert_row
   * Desc: Insert a row into rg_dss_hierarchies. Ensure that the
   *       hierarchy name doesn't exist already. Assign the
   *       primary key (hierarchy_id). Return the rowid of the inserted
   *       row to the form.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Insert_Row(X_Rowid                       IN OUT NOCOPY VARCHAR2,
                     X_Hierarchy_Id                  IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Dimension_Id                         NUMBER,
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
                     X_Attribute15                          VARCHAR2
                     );


  /* Name: lock_row
   * Desc: Lock the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
                     X_Hierarchy_Id                         NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Dimension_Id                         NUMBER,
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
                     X_Hierarchy_Id                         NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Dimension_Id                         NUMBER,
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
                     X_Attribute15                          VARCHAR2
                     );


  /* Name: delete_row
   * Desc: Delete the row specified by X_Rowid.
   *
   * History:
   *   06/20/95   S. Rahman   Created.
   */
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Hierarchy_Id NUMBER);


END RG_DSS_HIERARCHIES_PKG;

 

/
