--------------------------------------------------------
--  DDL for Package PER_GRADE_SPINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GRADE_SPINES_PKG" AUTHID CURRENT_USER as
/* $Header: pegrs01t.pkh 120.0 2005/05/31 09:32:40 appldev noship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Grade_Spine_Id               IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Ceiling_Step_Id              IN OUT NOCOPY NUMBER
 );

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Grade_Spine_Id                        NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Parent_Spine_Id                       NUMBER,
                   X_Grade_Id                              NUMBER,
                   X_Ceiling_Step_Id                       NUMBER,
                   X_starting_step                         NUMBER,
                   X_request_id                            NUMBER,
                   X_program_application_id                NUMBER,
                   X_program_id                            NUMBER,
                   X_program_update_date                   DATE
);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Grade_Spine_Id                      NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Ceiling_Step_Id                     NUMBER
);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

procedure stb_del_validation(p_pspine_id IN NUMBER,
                             p_grd_id IN NUMBER);

procedure chk_unq_grade_spine(p_grd_id IN NUMBER,
                              p_sess IN DATE);

procedure first_step(
                     p_step_id IN NUMBER,
                     p_grade_spine_id IN NUMBER,
                     p_spinal_point_id IN NUMBER,
                     p_sequence IN NUMBER,
                     p_effective_start_date IN DATE,
                     p_effective_end_date IN DATE,
                     p_business_group_id IN NUMBER,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
                     p_created_by IN NUMBER,
                     p_creation_date IN DATE,
                     p_information_category IN VARCHAR2);

--
-- first_step_api will be required for Grade/Step Progression Support
-- BUG#2999562
--
procedure first_step_api(
                     p_step_id               IN NUMBER,
                     p_grade_spine_id        IN NUMBER,
                     p_spinal_point_id       IN NUMBER,
                     p_sequence              IN NUMBER,
                     p_effective_start_date  IN DATE,
                     p_effective_end_date    IN DATE,
                     p_business_group_id     IN NUMBER,
                     p_last_update_date      IN DATE,
                     p_last_updated_by       IN NUMBER,
                     p_last_update_login     IN NUMBER,
                     p_created_by            IN NUMBER,
                     p_creation_date         IN DATE,
                     p_information_category  IN VARCHAR2,
                     p_object_version_number IN number,
                     p_effective_date        in date);

procedure chk_low_ceiling(p_val_start IN DATE,
                          p_val_end IN DATE,
                          p_gspine_id IN NUMBER,
                          p_new_ceil IN NUMBER);

procedure get_gspine_end(p_gspine_id in number,
                         p_grade_id in number,
                         p_eff_end_date in date,
                         p_gspine_opento_date in out nocopy date);

procedure close_gspine(p_gspine_id IN NUMBER,
                       p_sess IN DATE);

procedure open_gspine(p_gspine_id in number,
                      p_grade_id in number,
                      p_eff_end_date in date);


end PER_GRADE_SPINES_PKG;

 

/
