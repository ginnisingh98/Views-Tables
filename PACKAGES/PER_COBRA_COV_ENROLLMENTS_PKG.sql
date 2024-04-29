--------------------------------------------------------
--  DDL for Package PER_COBRA_COV_ENROLLMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_COBRA_COV_ENROLLMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pecobcce.pkh 120.0 2006/04/18 18:10:58 ssouresr noship $ */
--
/*
-- CHANGE HISTORY
--
   Name     Date        Versn  Bug       Text
   ========================================================================
-- gpaytonm 31-JAN-1994                  Removed WHO column references
-- ssattini 03-OCT-2005 115.1  4599753   Added dbdrv lines and nocopy for
--                                       out parameters
--
*/
--
--
PROCEDURE Insert_Row(X_Rowid                                  IN OUT nocopy VARCHAR2,
                     X_Cobra_Coverage_Enrollment_Id           IN OUT nocopy NUMBER,
                     X_Business_Group_Id                      NUMBER,
                     X_Assignment_Id                          NUMBER,
                     X_Period_Type                            VARCHAR2,
                     X_Qualifying_Date                        DATE,
                     X_Qualifying_Event                       VARCHAR2,
                     X_Coverage_End_Date                      DATE,
                     X_Coverage_Start_Date                    DATE,
                     X_Termination_Reason                     VARCHAR2,
                     X_Contact_Relationship_Id                NUMBER,
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
                     X_Attribute20                            VARCHAR2,
                     X_Grace_Days                             NUMBER,
                     X_Comments                               VARCHAR2
                     );
--
PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                   X_Cobra_Coverage_Enrollment_Id      NUMBER,
                   X_Business_Group_Id                 NUMBER,
                   X_Assignment_Id                     NUMBER,
                   X_Period_Type                       VARCHAR2,
                   X_Qualifying_Date                   DATE,
                   X_Qualifying_Event                  VARCHAR2,
                   X_Coverage_End_Date                 DATE,
                   X_Coverage_Start_Date               DATE,
                   X_Termination_Reason                VARCHAR2,
                   X_Contact_Relationship_Id           NUMBER,
                   X_Attribute_Category                VARCHAR2,
                   X_Attribute1                        VARCHAR2,
                   X_Attribute2                        VARCHAR2,
                   X_Attribute3                        VARCHAR2,
                   X_Attribute4                        VARCHAR2,
                   X_Attribute5                        VARCHAR2,
                   X_Attribute6                        VARCHAR2,
                   X_Attribute7                        VARCHAR2,
                   X_Attribute8                        VARCHAR2,
                   X_Attribute9                        VARCHAR2,
                   X_Attribute10                       VARCHAR2,
                   X_Attribute11                       VARCHAR2,
                   X_Attribute12                       VARCHAR2,
                   X_Attribute13                       VARCHAR2,
                   X_Attribute14                       VARCHAR2,
                   X_Attribute15                       VARCHAR2,
                   X_Attribute16                       VARCHAR2,
                   X_Attribute17                       VARCHAR2,
                   X_Attribute18                       VARCHAR2,
                   X_Attribute19                       VARCHAR2,
                   X_Attribute20                       VARCHAR2,
                   X_Grace_Days                        NUMBER,
                   X_Comments                          VARCHAR2
                   );
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Qualifying_Date                     DATE,
                     X_Qualifying_Event                    VARCHAR2,
                     X_Coverage_End_Date                   DATE,
                     X_Coverage_Start_Date                 DATE,
                     X_Termination_Reason                  VARCHAR2,
                     X_Contact_Relationship_Id             NUMBER,
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
                     X_Grace_Days                          NUMBER,
                     X_Comments                            VARCHAR2
                     );
--
--
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
--
--
-- Name       hr_cobra_chk_unique_enrollment
--
-- Purpose
--
-- Checks that the enrollment entered is unique
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_assignment_id
-- p_contact_relationship_id
-- p_qualifying_event
-- p_qualifying_date
--
-- Example
--
-- Notes
--
--
PROCEDURE hr_cobra_chk_unique_enrollment ( p_cobra_coverage_enrollment_id NUMBER,
                                           p_assignment_id                NUMBER,
                                           p_contact_relationship_id      NUMBER,
                                           p_qualifying_event             VARCHAR2,
                                           p_qualifying_date              DATE );
--
--
--
END PER_COBRA_COV_ENROLLMENTS_PKG;

 

/
