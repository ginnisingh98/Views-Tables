--------------------------------------------------------
--  DDL for Package PER_VALID_GRADES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VALID_GRADES_PKG2" AUTHID CURRENT_USER as
/* $Header: pevgr02t.pkh 120.1 2005/10/03 12:03:59 hsajja noship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Valid_Grade_Id                IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Grade_Id                             NUMBER,
                     X_Date_From                            DATE,
                     X_Comments                             VARCHAR2,
                     X_Date_To                              DATE,
                     X_Job_Id                               NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Attribute_Category                   VARCHAR2,
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
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2,
                     x_end_of_time                          DATE,
                     x_pst1_date_end                        DATE,
                     x_pst1_date_effective                  DATE
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Valid_Grade_Id                         NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Grade_Id                               NUMBER,
                   X_Date_From                              DATE,
                   X_Comments                               VARCHAR2,
                   X_Date_To                                DATE,
                   X_Job_Id                                 NUMBER,
                   X_Position_Id                            NUMBER,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Valid_Grade_Id                      NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Date_From                           DATE,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     x_end_of_time                         DATE,
                     x_pst1_date_end                       DATE,
                     x_pst1_date_effective                 DATE
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_VALID_GRADES_PKG2;

 

/
