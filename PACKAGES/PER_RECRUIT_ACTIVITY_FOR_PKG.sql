--------------------------------------------------------
--  DDL for Package PER_RECRUIT_ACTIVITY_FOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUIT_ACTIVITY_FOR_PKG" AUTHID CURRENT_USER as
/* $Header: percf01t.pkh 115.1 2003/02/11 11:59:38 eumenyio ship $ */
--
/*  +=======================================================================+
    |           Copyright (c) 1993 Oracle Corporation                       |
    |              Redwood Shores, California, USA                          |
    |                   All rights reserved.                                |
    +=======================================================================+
  Name
    per_recruit_activity_for_pkg
  Purpose
    Supports the VACANCY block in the form PERWSDRA (Define Recruitment
    Activity).
  Notes

  History
    21-Feb-94  H.Minton   40.0         Date created.
    29-Jan-95  D.Kerr	  70.4	       Removed WHO-columns for Set8 changes
============================================================================*/
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   checks that deletes cannot take place of a recruitment activity if    --
--   there are vacancies i.e recruitment_activities_for the recruitment-   --
--   activity exist.
-----------------------------------------------------------------------------
--
PROCEDURE check_References(P_recruitment_activity_id    NUMBER,
                           P_Business_group_id          NUMBER);
--
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Insert_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure. Supports the insert of a VACANCY via the   --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
 -----------------------------------------------------------------------------
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Recruitment_Activity_For_Id          IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Vacancy_Id                           NUMBER,
                     X_Recruitment_Activity_Id              NUMBER
                     );
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Lock_Row                                                              --
-- Purpose                                                                 --
--   Table handler procedure that supports the insert , update and delete  --
--   of a vacancy by applying a lock on a vacancy in the Define            --
--   Recruitment Activity form.                                            --
-- Arguments                                                               --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Recruitment_Activity_For_Id            NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Vacancy_Id                             NUMBER,
                   X_Recruitment_Activity_Id                NUMBER
                   );
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Update_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the update of a VACACNY via     --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Recruitment_Activity_For_Id         NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Vacancy_Id                          NUMBER,
                     X_Recruitment_Activity_Id             NUMBER
                     );
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Delete_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the delete of a VACACNY via     --
--   the Define Recruitment Activity form.                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_RECRUIT_ACTIVITY_FOR_PKG;

 

/
