--------------------------------------------------------
--  DDL for Package PER_JOB_EVALUATIONS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_EVALUATIONS_PKG2" AUTHID CURRENT_USER as
/* $Header: pejbe02t.pkh 115.0 99/07/18 13:55:03 porting ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT VARCHAR2,

                     X_Job_Evaluation_Id                    IN OUT NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Comments                             VARCHAR2,
                     X_Date_Evaluated                       DATE,
                     X_Job_Id                               NUMBER,
                     X_Measured_In                          VARCHAR2,
                     X_Overall_Score                        VARCHAR2,
                     X_Position_Id                          NUMBER,
                     X_System                               VARCHAR2,
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
                     X_Attribute20                          VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Job_Evaluation_Id                      NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Comments                               VARCHAR2,
                   X_Date_Evaluated                         DATE,
                   X_Job_Id                                 NUMBER,
                   X_Measured_In                            VARCHAR2,
                   X_Overall_Score                          VARCHAR2,
                   X_Position_Id                            NUMBER,
                   X_System                                 VARCHAR2,
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
                     X_Job_Evaluation_Id                   NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Comments                            VARCHAR2,
                     X_Date_Evaluated                      DATE,
                     X_Job_Id                              NUMBER,
                     X_Measured_In                         VARCHAR2,
                     X_Overall_Score                       VARCHAR2,
                     X_Position_Id                         NUMBER,
                     X_System                              VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_JOB_EVALUATIONS_PKG2;

 

/
