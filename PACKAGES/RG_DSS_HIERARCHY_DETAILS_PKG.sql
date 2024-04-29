--------------------------------------------------------
--  DDL for Package RG_DSS_HIERARCHY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_HIERARCHY_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: rgidhrds.pls 120.2 2002/11/14 02:58:44 djogg ship $ */

  /* Name: check_unique
   * Desc: Check if the sequence already exists. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_sequence(X_Rowid VARCHAR2,
                         X_Hierarchy_Id NUMBER,
                         X_Sequence NUMBER);

  /* Name: check_unique
   * Desc: Check if the segment already exists. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_segment(X_Rowid VARCHAR2,
                         X_Hierarchy_Id NUMBER,
                         X_Application_Column_Name VARCHAR2);

  /* Name: insert_row
   * Desc: Insert a row into rg_dss_hierarchy_details. Ensure that the
   *       hierarchy name doesn't exist already. Assign the
   *       primary key (hierarchy_id). Return the rowid of the inserted
   *       row to the form.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE Insert_Row(X_Master_Hierarchy_Id       IN OUT NOCOPY NUMBER,
		     X_Rowid                       IN OUT NOCOPY VARCHAR2,
                     X_Hierarchy_Id                IN OUT NOCOPY NUMBER,
                     X_Sequence                             NUMBER,
                     X_Application_Column_Name              VARCHAR2,
                     X_Root_Node                            VARCHAR2,
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
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
                     X_Hierarchy_Id                         NUMBER,
                     X_Sequence                             NUMBER,
                     X_Application_Column_Name              VARCHAR2,
                     X_Root_Node                            VARCHAR2,
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
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE Update_Row(X_Rowid                              VARCHAR2,
                     X_Hierarchy_Id                         NUMBER,
                     X_Sequence                             NUMBER,
                     X_Application_Column_Name              VARCHAR2,
                     X_Root_Node                            VARCHAR2,
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
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Hierarchy_Id NUMBER);


END RG_DSS_HIERARCHY_DETAILS_PKG;

 

/
