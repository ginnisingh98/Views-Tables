--------------------------------------------------------
--  DDL for Package RG_DSS_VAR_DIMENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_VAR_DIMENSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: rgidvdms.pls 120.2 2002/11/14 02:59:34 djogg ship $ */


  /* Name: check_unique_sequence
   * Desc: Check if sequence already exists for specified variable. If it does,
   *       raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_sequence(X_Rowid VARCHAR2,
                                  X_Variable_Id NUMBER,
                                  X_Sequence NUMBER);


  /* Name: check_unique
   * Desc: Check if dimension already exists for specified variable. If it
   *       does raise an exception. If it doesn't, do nothing.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE check_unique_dimension(X_Rowid VARCHAR2,
                                   X_Variable_Id NUMBER,
                                   X_Dimension_Id NUMBER);


  /* Name: insert_row
   * Desc: Insert a row into rg_dss_var_dimensions. Ensure that the variable id
   *       and sequence combination doesn't exist already.Return the rowid
   *       of the inserted row to the form.
   *
   * History:
   *   06/26/95   S. Rahman   Created.
   */
  PROCEDURE Insert_Row(
              X_Master_Variable_Id          IN OUT NOCOPY NUMBER,
              X_Rowid                       IN OUT NOCOPY VARCHAR2,
              X_Variable_Id                 IN OUT NOCOPY NUMBER,
              X_Sequence                             NUMBER,
              X_Dimension_Id                         NUMBER,
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
                     X_Variable_Id                          NUMBER,
                     X_Sequence                             NUMBER,
                     X_Dimension_Id                         NUMBER,
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
                     X_Variable_Id                          NUMBER,
                     X_Sequence                             NUMBER,
                     X_Dimension_Id                         NUMBER,
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
  PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Variable_Id NUMBER);


END RG_DSS_VAR_DIMENSIONS_PKG;

 

/
