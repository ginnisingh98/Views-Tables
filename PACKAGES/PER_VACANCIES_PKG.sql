--------------------------------------------------------
--  DDL for Package PER_VACANCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VACANCIES_PKG" AUTHID CURRENT_USER as
/* $Header: pevac01t.pkh 120.2.12010000.3 2010/04/08 10:16:09 karthmoh ship $ */
/*+=========================================================================+
  |             Copyright (c) 1993 Oracle Corporation                       |
  |                Redwood Shores, California, USA                          |
  |                     All rights reserved.                                |
  +=========================================================================+
 Name
    per_vacancies_pkg
  Purpose
    Supports the VACANCY block in the form PERWSVAC (Define Requistion and
    Vacancy form).
  Notes

  History
    13-APR-94  H.Minton   40.0         Date created.

    23-MAY-94  H.Minton   40.1         Added new functions for folder form.

    19-JAN-95  D.Kerr     70.5         Removed WHO- columns

    17-MAY-95  D.Kerr     70.6         1.Removed p_business_group_id
                                       parameter from D_from_updt_rec_act_chk
                                       2.Removed check_references1 and
                                       renamed check_references2 to
                                       check_references.
                                       3.Added vacancy_id parameter to
                                       delete_row to make ref. int check
                                       easier.

    26-JAN-98  I.Harding  110.1        Added extra vacancy_category parameter
                                       to insert, update and lock procs.

    25-FEB-98  B.Goodsell 115.1        Added Budget Measurement columns to
                                       Table Handler procedures
    03-JUL-06  avarri     115.4        Modiifed the procedure Check_Unique_Name
                                       for 4262036.
    04-Nov-08  sidsaxen   115.6        Added procedure end_date_irec_RA, end_date_PER_RA
                                       and stubbed procedure D_from_updt_rec_act_chk
                                       for bug 6497289
    08-APR-10 karthmoh    120.2.12010000.2 Modified/Added Procedures for ER#8530112

============================================================================*/
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   To ensure the referential integrity when a vacancy is deleted from the--
--   Define Requisition and Vacancy form.                                  --
-----------------------------------------------------------------------------
--
 PROCEDURE Check_References(P_vacancy_id                NUMBER);

----------------------------------------------------------------------------
--
-- Name                                                                    --
--   B_counter                                                             --
-- Purpose                                                                 --
--   The purpose of this function is to return the values for the FOLDER
--   block of the forms VIEW VACANCIES.
-----------------------------------------------------------------------------
FUNCTION B_counter(P_Business_group_id         NUMBER,
                    P_vacancy_id               NUMBER,
                    P_legislation_code         VARCHAR2,
                    P_vac_type                 VARCHAR2) return NUMBER;
----------------------------------------------------------------------------
--
-- Name                                                                    --
--   folder_hires                                                          --
-- Purpose                                                                 --
--   the purpose of this function is to return the number of applicants who
--   have been hired as employees as a result of being hired into a vacancy.
--   This function is used by the folder form PERWILVA - View Vacancies.
-----------------------------------------------------------------------------
FUNCTION folder_hires(P_Business_group_id        NUMBER,
                      P_vacancy_id               NUMBER
                      ) return NUMBER;
----------------------------------------------------------------------------
-- Name                                                                    --
--   folder_current                                                        --
-- Purpose                                                                 --
--   the purpose of this function is to return the number of current openings
--   for the vacancy as of the session date i.e it is the initial number of
--   openings for the vacancy as when the vacancy was defined minus the
--   number of applicants who have been hired into the vacancy.
-----------------------------------------------------------------------------
FUNCTION folder_current(P_Business_group_id        NUMBER,
                        P_vacancy_id               NUMBER,
                        P_session_date             DATE
                        ) return NUMBER;
----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_Unique_Name                                                     --
-- Purpose                                                                 --
--   checks that the vacancy name is unique. Called from the               --
--   client side package VACANCY_ITEM from the procedure 'name'. Called    --
--   on WHEN-VALIDATE-ITEM from Name.                                      --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Check_Unique_Name(P_Name                      VARCHAR2,
                            P_business_group_id         NUMBER,
                            P_rowid                     VARCHAR2);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Chk_appl_exists                                                       --
-- Purpose                                                                 --
--   Verify the effective date, you cannot change the effective date of    --
--   this vacancy to a future date as applications exist within the vacancy--
--   availability period.                                                  --
--   Called from WHEN-VALIDATE-ITEM in the vacancy block.                  --
--                                                                         --
-----------------------------------------------------------------------------
--
procedure chk_appl_exists (P_vacancy_id		NUMBER,
                           P_vac_date_from       DATE,
                           P_vac_date_to         DATE,
	                   P_end_of_time	 DATE
		           );
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_in_req_dates                                                    --
-- Purpose                                                                 --
--   to check that the vacancy date_from is not < than the requisition date--
--   date_from.                                                            --
-----------------------------------------------------------------------------
PROCEDURE Check_in_req_dates(P_requisition_id           NUMBER,
                             P_Business_group_id        NUMBER,
                             P_vac_date_from            DATE);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Chk_dt_to_in_req_dates                                                --
-- Purpose                                                                 --
--   Ensure that the vacancy date to is witin the requisition dates.       --
--   Called from WHEN-VALIDATE-ITEM in the vacancy block.                  --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Chk_dt_to_in_req_dates(P_requisition_id               NUMBER,
                                 P_Business_group_id            NUMBER,
                                 P_vac_date_to                  DATE);
----------------------------------------------------------------------------
-- Name                                                                    --
--   Date_from_upd_validation                                              --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate any of the      --
--   vacancy_for region.
-----------------------------------------------------------------------------
PROCEDURE Date_from_upd_validation(
                                    Pz_vac_date_from       DATE,
                                    Pz_business_group_id   NUMBER,
                                    Pz_start_of_time       DATE,
                                    Pz_end_of_time         DATE,
                                    Pz_organization_id     NUMBER,
                                    Pz_position_id         NUMBER,
                                    Pz_people_group_id     NUMBER,
                                    Pz_job_id              NUMBER,
                                    Pz_grade_id            NUMBER,
                                    Pz_recruiter_id        NUMBER,
                                    Pz_location_id         NUMBER);
----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_rec_act_chk                                               --
-- Purpose                                                                 --
--   to check that the vacancy date_from does not invalidate any recruitment
--   activity which uses this vacancy.                                     --
-----------------------------------------------------------------------------
PROCEDURE D_from_updt_rec_act_chk(P_vacancy_id          NUMBER,
                                  P_vac_date_from       DATE,
                                  P_vac_date_to         DATE,
                                  P_end_of_time         DATE);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_org_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the organization--
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
PROCEDURE D_from_updt_org_chk(P_Business_group_id   NUMBER,
                              P_vac_date_from       DATE,
                              P_organization_id     NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_pos_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the position    --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_pos_chk(P_Business_group_id   NUMBER,
                                P_vac_date_from       DATE,
                                P_position_id         NUMBER);

-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_grp_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the group       --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_grp_chk(P_vac_date_from       DATE,
                                P_start_of_time         DATE,
                                P_people_group_id     NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_job_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the job         --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_job_chk(P_vac_date_from       DATE,
                                P_business_group_id   NUMBER,
                                P_job_id              NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_grd_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the grade       --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_grd_chk(P_vac_date_from       DATE,
                                P_business_group_id   NUMBER,
                                P_grade_id            NUMBER);

-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_loc_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the location    --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_loc_chk(P_vac_date_from       DATE,
                                P_end_of_time         DATE,
                                P_location_id         NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_person
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the recruiter   --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_person(P_vac_date_from       DATE,
                               P_recruiter_id        NUMBER,
                               P_business_group_id   NUMBER);

-----------------------------------------------------------------------------
-- Name                                                                    --
--   FUNCTION get_people_group
-- Purpose                                                                 --
--   to get the people_group_structure for the group key flexfield in the  --
--   vacancy block of PERWSVAC.l
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
FUNCTION get_people_group(P_Business_Group_Id   NUMBER) return VARCHAR2;

-----------------------------------------------------------------------------
-- Name                                                                    --
--   Insert_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure. Supports the insert of a VACANCY via the     --
--   Define Requistion and Vacancy form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Insert_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                     X_Vacancy_Id                           IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Job_Id                               NUMBER,
                     X_Grade_Id                             NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Requisition_Id                       NUMBER,
                     X_People_Group_Id                      NUMBER,
                     X_People_Group_Name                    VARCHAR2,
                     X_Location_Id                          NUMBER,
                     X_Recruiter_Id                         NUMBER,
                     X_Date_From                            DATE,
                     X_Name                                 VARCHAR2,
                     X_Comments                             VARCHAR2,
                     X_Date_To                              DATE,
                     X_Description                          VARCHAR2,
                     X_Vacancy_category                     varchar2,
                     X_Number_Of_Openings                   NUMBER,
                     X_Status                               VARCHAR2,
                     X_Budget_Measurement_Type              VARCHAR2,
                     X_Budget_Measurement_Value             NUMBER,
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
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Lock_Row                                                              --
-- Purpose                                                                 --
--   Table handler procedure that supports the insert , update and delete  --
--   of an activity by applying a lock on a vacancy in the Define          --
--   Requistion and Vacancy form.                                            --
-- Arguments                                                               --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Vacancy_Id                             NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Position_Id                            NUMBER,
                   X_Job_Id                                 NUMBER,
                   X_Grade_Id                               NUMBER,
                   X_Organization_Id                        NUMBER,
                   X_Requisition_Id                         NUMBER,
                   X_People_Group_Id                        NUMBER,
                   X_Location_Id                            NUMBER,
                   X_Recruiter_Id                           NUMBER,
                   X_Date_From                              DATE,
                   X_Name                                   VARCHAR2,
                   X_Comments                               VARCHAR2,
                   X_Date_To                                DATE,
                   X_Description                            VARCHAR2,
                   X_Vacancy_category                       VARCHAR2,
                   X_Number_Of_Openings                     NUMBER,
                   X_Status                                 VARCHAR2,
                   X_Budget_Measurement_Type                VARCHAR2,
                   X_Budget_Measurement_Value               NUMBER,
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
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Update_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the update of a VACANCY via     --
--   Define Requistion and Vacancy form.                                   --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Vacancy_Id                          NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Requisition_Id                      NUMBER,
                     X_People_Group_Id                     NUMBER,
                     X_People_Group_Name                   VARCHAR2,
                     X_Location_Id                         NUMBER,
                     X_Recruiter_Id                        NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Description                         VARCHAR2,
                     X_Vacancy_category                    varchar2,
                     X_Number_Of_Openings                  NUMBER,
                     X_Status                              VARCHAR2,
                     X_Budget_Measurement_Type             VARCHAR2,
                     X_Budget_Measurement_Value            NUMBER,
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
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Delete_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the delete of a VACANCY via     --
--   the Define Requistion and Vacancy form.                               --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_vacancy_id in number );

g_Recinfo per_vacancies%ROWTYPE;

-- start changes for bug 6497289
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   end_date_iRec_RA                                                      --
-- Purpose                                                                 --
--   To End-Date the i-Rec Site Recruitment Activity                       --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE end_date_iRec_RA(P_vacancy_id        IN  NUMBER,
                          P_vac_date_from      IN  DATE,
                          P_vac_date_to        IN  DATE);

--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   end_date_per_RA                                                       --
-- Purpose                                                                 --
--   To End-Date the PER Recruitment Activity                              --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE end_date_per_RA(P_vacancy_id               IN NUMBER,
                          P_recruitment_activity_id  IN NUMBER,
                          P_vac_date_from            IN DATE,
                          P_vac_date_to              IN DATE);

-- end changes for bug 6497289
-- Begin - Changes for ER#8530112
-----------------------------------------------------------------------------
-- Name                                                                    --
--  GET_POS_HC_BUDGET_VAL                               	                 --
-- Purpose                                                                 --
--   To get the Position Headcount Budget value														 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
function GET_POS_HC_BUDGET_VAL(p_position_id in number default null,
															  p_effective_date in date) return number;
-----------------------------------------------------------------------------
-- Name                                                                    --
--  GET_ASGND_HC_BUDGET_VAL                              	                 --
-- Purpose                                                                 --
--   To get the Assigned HeadCount for that position											 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
function GET_ASGND_HC_BUDGET_VAL(p_position_id in number default null,
																 p_effective_date in date) return number;
-----------------------------------------------------------------------------
-- Name                                                                    --
--  GET_NUM_OF_VAC                              	                 --
-- Purpose                                                                 --
--   To get the number of vacancies for that position											 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
function GET_NUM_OF_VAC(p_position_id in number,p_effective_date in date,p_vacancy_id in number) return number;
-----------------------------------------------------------------------------
-- Name                                                                    --
--  CHK_POS_BUDGET_VAL                              	          	         --
-- Purpose                                                                 --
--   To check whether vancancy is available for that position 						 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
procedure CHK_POS_BUDGET_VAL(p_position_id in number,
														 p_effective_date in date,p_org_id in number,p_number_of_openings in number,p_vacancy_id in number);

-- End - Changes for ER#8530112

END PER_VACANCIES_PKG;

/
