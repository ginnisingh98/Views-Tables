--------------------------------------------------------
--  DDL for Package PER_COBRA_COV_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_COBRA_COV_STATUSES_PKG" AUTHID CURRENT_USER as
/* $Header: pecobccs.pkh 115.0 99/07/17 18:50:03 porting ship $ */
--
--
-- CHANGE HISTORY
--
-- gpaytonm 31-JAN-1994 Removed WHO column references
--
PROCEDURE Insert_Row(X_Rowid                           IN OUT VARCHAR2,
                     X_Cobra_Coverage_Status_Id               IN OUT NUMBER,
                     X_Business_Group_Id                      NUMBER,
                     X_Cobra_Coverage_Enrollment_Id           NUMBER,
                     X_Cobra_Coverage_Status_Type             VARCHAR2,
                     X_Effective_Date                         DATE,
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
                     X_Comments                               VARCHAR2
                     );
--
PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                   X_Cobra_Coverage_Status_Id          NUMBER,
                   X_Business_Group_Id                 NUMBER,
                   X_Cobra_Coverage_Enrollment_Id      NUMBER,
                   X_Cobra_Coverage_Status_Type        VARCHAR2,
                   X_Effective_Date                    DATE,
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
                   X_Comments                          VARCHAR2
                   );
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Business_Group_Id                   NUMBER,
                     X_Cobra_Coverage_Enrollment_Id        NUMBER,
                     X_Cobra_Coverage_Status_Type          VARCHAR2,
                     X_Effective_Date                      DATE,
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
                     X_Comments                            VARCHAR2
                     );
--
--
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
--
--
-- Name        hr_cobra_chk_status_unique
--
-- Purpose
--
-- Ensures that the status being entered is unique
--
-- Arguments
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_status_unique ( p_business_group_id            NUMBER,
				       p_cobra_coverage_status_id     NUMBER,
				       p_cobra_coverage_enrollment_id NUMBER,
				       p_cobra_coverage_status_type   VARCHAR2 );
--
--
--
-- Name
--
-- Purpose
--
-- Ensures status inserted in correct order
--
-- Arguments
--
-- Example
--
-- Notes
--
--
PROCEDURE hr_cobra_chk_status_order ( p_business_group_id            NUMBER,
				      p_cobra_coverage_enrollment_id NUMBER,
                                      p_cobra_coverage_status_id     NUMBER,
				      p_cobra_coverage_status_type   VARCHAR2,
				      p_effective_date               DATE );
--
--
--
-- Name       hr_cobra_chk_status_elect_rej
--
-- Purpose
--
-- Ensures that Accept/Reject do not coexist
--
-- Arguments
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_status_elect_rej( p_business_group_id            NUMBER,
                                         p_cobra_coverage_enrollment_id NUMBER,
                                         p_cobra_coverage_status_id     NUMBER,
                                         p_cobra_coverage_status_type   VARCHAR2);
--
--
--
END PER_COBRA_COV_STATUSES_PKG;

 

/
