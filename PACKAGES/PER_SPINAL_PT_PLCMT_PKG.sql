--------------------------------------------------------
--  DDL for Package PER_SPINAL_PT_PLCMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SPINAL_PT_PLCMT_PKG" AUTHID CURRENT_USER as
/* $Header: pespp01t.pkh 115.4 2003/06/19 21:12:51 ynegoro ship $ */

procedure check_ass_end(p_ass_id IN NUMBER,
                        p_sess IN DATE,
                        p_grd_id IN NUMBER);

procedure b_delete_valid(p_ass_id IN NUMBER,
                         p_pmt_id IN NUMBER,
                         p_eed IN DATE);

procedure pop_flds(p_sess IN DATE,
                   p_step_id IN NUMBER,
                   p_step_dsc IN OUT NOCOPY VARCHAR2,
                   p_step_no IN OUT NOCOPY NUMBER,
                   p_spoint_id IN OUT NOCOPY NUMBER,
                   p_rsn IN VARCHAR2,
                   p_rsn_desc IN OUT NOCOPY VARCHAR2);

procedure chk_exist(p_ass_id IN NUMBER,
                    p_sess IN DATE);


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Placement_Id                  IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                 DATE,
                     X_Effective_End_Date                   DATE,
                     X_Business_Group_Id                    NUMBER,
                     X_Assignment_Id                        NUMBER,
                     X_Step_Id                              NUMBER,
                     X_Auto_Increment_Flag                  VARCHAR2,
                     X_Parent_Spine_Id                      NUMBER,
                     X_Reason                               VARCHAR2,
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
                   X_Placement_Id                           NUMBER,
                   X_Effective_Start_Date                   DATE,
                   X_Effective_End_Date                     DATE,
                   X_Business_Group_Id                      NUMBER,
                   X_Assignment_Id                          NUMBER,
                   X_Step_Id                                NUMBER,
                   X_Auto_Increment_Flag                    VARCHAR2,
                   X_Parent_Spine_Id                        NUMBER,
                   X_Reason                                 VARCHAR2,
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
                     X_Placement_Id                        NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Step_Id                             NUMBER,
                     X_Auto_Increment_Flag                 VARCHAR2,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Reason                              VARCHAR2,
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

PROCEDURE Delete_Row(X_rowid VARCHAR2);

procedure pop_ctrl(p_ass_id IN NUMBER,
                   p_grd_id IN OUT NOCOPY NUMBER ,
                   p_grd_name IN OUT NOCOPY VARCHAR2 ,
                   p_ceil_sp IN OUT NOCOPY VARCHAR2 ,
                   p_parent_name IN OUT NOCOPY VARCHAR2 ,
                   p_parent_id IN OUT NOCOPY NUMBER ,
                   p_ceil_seq In OUT NOCOPY NUMBER ,
                   p_ceil_step In OUT NOCOPY NUMBER ,
                   p_ass_eed IN OUT NOCOPY DATE ,
                   p_inc_def IN OUT NOCOPY VARCHAR2 ,
                   p_sess In DATE,
                   p_bgroup_id IN NUMBER,
		   p_check IN VARCHAR2,
                   p_grd_ldr_name in out nocopy varchar2);


procedure test_path_to_perwsspp (p_ass_id    NUMBER);

end PER_SPINAL_PT_PLCMT_PKG;

 

/
