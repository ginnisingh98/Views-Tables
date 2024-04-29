--------------------------------------------------------
--  DDL for Package PER_SPINAL_POINT_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SPINAL_POINT_STEPS_PKG" AUTHID CURRENT_USER as
/* $Header: pesps01t.pkh 115.2 2002/12/09 10:42:51 eumenyio ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Step_Id                       IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                 DATE,
                     X_Effective_End_Date                   DATE,
                     X_Business_Group_Id                    NUMBER,
                     X_Spinal_Point_Id                      NUMBER,
                     X_Grade_Spine_Id                       NUMBER,
                     X_Sequence                             NUMBER,
                     X_request_id                           NUMBER,
                     X_program_application_id               NUMBER,
                     X_program_id                           NUMBER,
                     X_program_update_date                  DATE,
                     X_Information1                         VARCHAR2,
                     X_Information2                         VARCHAR2,
                     X_Information3                         VARCHAR2,
                     X_Information4                         VARCHAR2,
                     X_Information5                         VARCHAR2,
                     X_Information6                         VARCHAR2,
                     X_Information7                         VARCHAR2,
                     X_Information8                         VARCHAR2,
                     X_Information9                         VARCHAR2,
                     X_Information10                        VARCHAR2,
                     X_Information11                        VARCHAR2,
                     X_Information12                        VARCHAR2,
                     X_Information13                        VARCHAR2,
                     X_Information14                        VARCHAR2,
                     X_Information15                        VARCHAR2,
                     X_Information16                        VARCHAR2,
                     X_Information17                        VARCHAR2,
                     X_Information18                        VARCHAR2,
                     X_Information19                        VARCHAR2,
                     X_Information20                        VARCHAR2,
                     X_Information21                        VARCHAR2,
                     X_Information22                        VARCHAR2,
                     X_Information23                        VARCHAR2,
                     X_Information24                        VARCHAR2,
                     X_Information25                        VARCHAR2,
                     X_Information26                        VARCHAR2,
                     X_Information27                        VARCHAR2,
                     X_Information28                        VARCHAR2,
                     X_Information29                        VARCHAR2,
                     X_Information30                        VARCHAR2,
                     X_Information_category                 VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Step_Id                                NUMBER,
                   X_Effective_Start_Date                   DATE,
                   X_Effective_End_Date                     DATE,
                   X_Business_Group_Id                      NUMBER,
                   X_Spinal_Point_Id                        NUMBER,
                   X_Grade_Spine_Id                         NUMBER,
                   X_Sequence                               NUMBER,
                   X_request_id                             NUMBER,
                   X_program_application_id                 NUMBER,
                   X_program_id                             NUMBER,
                   X_program_update_date                    DATE,
                   X_Information1                           VARCHAR2,
                   X_Information2                           VARCHAR2,
                   X_Information3                           VARCHAR2,
                   X_Information4                           VARCHAR2,
                   X_Information5                           VARCHAR2,
                   X_Information6                           VARCHAR2,
                   X_Information7                           VARCHAR2,
                   X_Information8                           VARCHAR2,
                   X_Information9                           VARCHAR2,
                   X_Information10                          VARCHAR2,
                   X_Information11                          VARCHAR2,
                   X_Information12                          VARCHAR2,
                   X_Information13                          VARCHAR2,
                   X_Information14                          VARCHAR2,
                   X_Information15                          VARCHAR2,
                   X_Information16                          VARCHAR2,
                   X_Information17                          VARCHAR2,
                   X_Information18                          VARCHAR2,
                   X_Information19                          VARCHAR2,
                   X_Information20                          VARCHAR2,
                   X_Information21                          VARCHAR2,
                   X_Information22                          VARCHAR2,
                   X_Information23                          VARCHAR2,
                   X_Information24                          VARCHAR2,
                   X_Information25                          VARCHAR2,
                   X_Information26                          VARCHAR2,
                   X_Information27                          VARCHAR2,
                   X_Information28                          VARCHAR2,
                   X_Information29                          VARCHAR2,
                   X_Information30                          VARCHAR2,
                   X_Information_category                   VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Step_Id                             NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Spinal_Point_Id                     NUMBER,
                     X_Grade_Spine_Id                      NUMBER,
                     X_Sequence                            NUMBER,
                     X_request_id                          NUMBER,
                     X_program_application_id              NUMBER,
                     X_program_id                          NUMBER,
                     X_program_update_date                 DATE,
                     X_Information1                        VARCHAR2,
                     X_Information2                        VARCHAR2,
                     X_Information3                        VARCHAR2,
                     X_Information4                        VARCHAR2,
                     X_Information5                        VARCHAR2,
                     X_Information6                        VARCHAR2,
                     X_Information7                        VARCHAR2,
                     X_Information8                        VARCHAR2,
                     X_Information9                        VARCHAR2,
                     X_Information10                       VARCHAR2,
                     X_Information11                       VARCHAR2,
                     X_Information12                       VARCHAR2,
                     X_Information13                       VARCHAR2,
                     X_Information14                       VARCHAR2,
                     X_Information15                       VARCHAR2,
                     X_Information16                       VARCHAR2,
                     X_Information17                       VARCHAR2,
                     X_Information18                       VARCHAR2,
                     X_Information19                       VARCHAR2,
                     X_Information20                       VARCHAR2,
                     X_Information21                       VARCHAR2,
                     X_Information22                       VARCHAR2,
                     X_Information23                       VARCHAR2,
                     X_Information24                       VARCHAR2,
                     X_Information25                       VARCHAR2,
                     X_Information26                       VARCHAR2,
                     X_Information27                       VARCHAR2,
                     X_Information28                       VARCHAR2,
                     X_Information29                       VARCHAR2,
                     X_Information30                       VARCHAR2,
                     X_Information_category                VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

procedure del_chks_del(p_step_id IN NUMBER,
                       p_sess IN DATE);

procedure del_chks_zap(p_step_id IN NUMBER);

procedure chk_unq_step_point(p_gspine_id IN NUMBER,
                             p_spoint_id IN NUMBER,
                             p_step_id   IN NUMBER);

procedure pop_flds(p_d_step IN OUT NOCOPY NUMBER,
                   p_sess IN DATE,
                   p_spoint_id IN NUMBER,
                   p_gspine_id IN NUMBER);


END PER_SPINAL_POINT_STEPS_PKG;

 

/
