--------------------------------------------------------
--  DDL for Package PER_RECRUITMENT_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUITMENT_ACTIVITIES_PKG" AUTHID CURRENT_USER as
/* $Header: perca01t.pkh 115.1 2003/02/11 11:55:05 eumenyio ship $ */
--
/*  +=======================================================================+
    |           Copyright (c) 1993 Oracle Corporation                       |
    |              Redwood Shores, California, USA                          |
    |                   All rights reserved.                                |
    +=======================================================================+
 Note
    Changed X_Parent_Recruitment_Activity_Id to X_Parent_Rec_Activity_Id
    because was too long otherwise.
 Name
    per_recruitment_activities_pkg
 Purpose
    Supports the Activity blk in PERWSRA Define Recruitment Activity form

 History
   03-MAR-94	H.Minton	40.0		Date Created
   01-JUL-94    H.Minton        40.1            Added procedure chk_auth_date.
   29-JAN-95    D.Kerr		70.5		Removed WHO-columns for Set8
   22-MAR-96    A.Mills         70.7            Altered procedure chk_vacancy_
                                                dates to accept and test on
                                                p_rec_activity_id.
============================================================================*/
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_Unique_Name                                                     --
-- Purpose                                                                 --
--   checks that the recruitment activity name is unique. Called from the  --
--   client side package ACTIVITY_ITEMS from the procedure 'name'. Called  --
--   on WHEN-VALIDATE-ITEM from Name.                                      --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Check_Unique_Name(P_Name                      VARCHAR2,
                            P_Business_group_id         NUMBER,
                            P_rowid                     VARCHAR2);
--
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   checks that deletes cannot take place of a recruitment activity if    --
--   there are vacancies i.e recruitment_activities_for the recruitment-   --
--   activity, or if the recruitment activity is being used in an          --
--   assignment or if the recruitment activity is a parent.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --

-----------------------------------------------------------------------------
--
PROCEDURE check_References(P_recruitment_activity_id 	NUMBER,
                           P_Business_group_id          NUMBER);
--
-----------------------------------------------------------------------------

--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_org_date                                                           --
-- Purpose                                                                 --
--   checks that update of the activity start date does not invalidate     --
--   any of the components of the recruitment activity                     --
--   such as the organization, the parent recruitment activity and any     --
--   child recruitment activities, and any vacancies.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE chk_org_date(P_date_start 	  DATE,
                      P_org_run_by_Id     NUMBER,
                      P_Business_Group_id NUMBER);
--

-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_auth_date                                                         --
-- Purpose                                                                 --
--   checks that update of the activity start date does not invalidate     --
--   any of the components of the recruitment activity, in this case it    --
--   to check that the authoriser is not invalidated.                      --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE chk_auth_date(P_date_start 	          DATE,
                      P_authorising_person_id     NUMBER,
                      P_Business_Group_id         NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_int_cont_date                                                     --
-- Purpose                                                                 --
--    Checks that on update of the Activity Start that the internal contact--
--     is not invalidated.                                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   Called from the client side the WVI for the date_start                --
-----------------------------------------------------------------------------
--
--
   PROCEDURE chk_int_cont_date(P_date_start              DATE,
                           P_internal_contact_person_id  NUMBER,
                           P_Business_Group_id           NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_parent_dates                                                      --
-- Purpose                                                                 --
--   Validates that the parent rec.act start date is not invalid if the    --
--   user updates the start date of the recruitment activity. Called from  --
--   the client side trigger WVI on the rec act Start date.                --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_parent_dates(P_date_start        DATE,
                           P_Business_Group_id NUMBER,
                           P_parent_rec_id     NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_vacancy_dates                                                     --
-- Purpose                                                                 --
--   Validates that the vacancy start date is not invalid if the           --
--   user updates the start date of the recruitment activity. Called from  --
--   the client side trigger WVI on the rec act Start date.                --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_vacancy_dates(P_date_start        DATE,
                           P_Business_Group_id NUMBER,
                           P_rec_activity_id        NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_child_rec_date                                                    --
-- Purpose                                                                 --
--   Validates that the date is not invalid if the recruitment activity is --
--   used as a parent recruitment activity elsewhere.                      --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_child_rec_dates(P_date_start        DATE,
                              P_Business_Group_id NUMBER,
                              P_rec_act_id        NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_child_end_dates                                                   --
-- Purpose                                                                 --
--   Validates that the end date is not invalid if the recruitment activity--
--   is used as a parent recruitment activity elsewhere.                   --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_child_end_dates(P_date_end          DATE,
                              P_Business_Group_id NUMBER,
                              P_rec_act_id        NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   default_currency_code                                                 --
-- Purpose                                                                 --
--   to show the default currency code for the legislation of the business --
--   group for the recruitment activity.                                   --
-----------------------------------------------------------------------------
FUNCTION default_currency_code(P_Business_Group_Id   NUMBER) return VARCHAR2;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Insert_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure. Supports the insert of an ACTIVITY via the   --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
 -----------------------------------------------------------------------------
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Recruitment_Activity_Id              IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Authorising_Person_Id                NUMBER,
                     X_Run_By_Organization_Id               NUMBER,
                     X_Internal_Contact_Person_Id           NUMBER,
                     X_Parent_Rec_Activity_Id               NUMBER,
                     X_Currency_Code                        VARCHAR2,
                     X_Date_Start                           DATE,
                     X_Name                                 VARCHAR2,
                     X_Actual_Cost                          VARCHAR2,
                     X_Comments                             varchar2,
                     X_Contact_Telephone_Number             VARCHAR2,
                     X_Date_Closing                         DATE,
                     X_Date_End                             DATE,
                     X_External_Contact                     VARCHAR2,
                     X_Planned_Cost                         VARCHAR2,
                     X_Type                                 VARCHAR2,
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
--   of an activity by applying a lock on an activity in the Define        --
--   Recruitment Activity form.                                            --
-- Arguments                                                               --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Recruitment_Activity_Id                NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Authorising_Person_Id                  NUMBER,
                   X_Run_By_Organization_Id                 NUMBER,
                   X_Internal_Contact_Person_Id             NUMBER,
                   X_Parent_Rec_Activity_Id                 NUMBER,
                   X_Currency_Code                          VARCHAR2,
                   X_Date_Start                             DATE,
                   X_Name                                   VARCHAR2,
                   X_Actual_Cost                            VARCHAR2,
                   X_Comments                               varchar2,
                   X_Contact_Telephone_Number               VARCHAR2,
                   X_Date_Closing                           DATE,
                   X_Date_End                               DATE,
                   X_External_Contact                       VARCHAR2,
                   X_Planned_Cost                           VARCHAR2,
                   X_Type                                   VARCHAR2,
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
--   Table handler procedure that supports the update of an ACTIVITY via   --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Recruitment_Activity_Id             NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Authorising_Person_Id               NUMBER,
                     X_Run_By_Organization_Id              NUMBER,
                     X_Internal_Contact_Person_Id          NUMBER,
                     X_Parent_Rec_Activity_Id              NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Date_Start                          DATE,
                     X_Name                                VARCHAR2,
                     X_Actual_Cost                         VARCHAR2,
                     X_Comments                            varchar2,
                     X_Contact_Telephone_Number            VARCHAR2,
                     X_Date_Closing                        DATE,
                     X_Date_End                            DATE,
                     X_External_Contact                    VARCHAR2,
                     X_Planned_Cost                        VARCHAR2,
                     X_Type                                VARCHAR2,
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
--   Table handler procedure that supports the delete of an ACTIVITY via   --
--   the Define Recruitment Activity form.                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--

 PROCEDURE Delete_Row(X_Rowid VARCHAR2);

--

END PER_RECRUITMENT_ACTIVITIES_PKG;

 

/
