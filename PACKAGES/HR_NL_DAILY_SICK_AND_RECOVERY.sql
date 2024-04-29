--------------------------------------------------------
--  DDL for Package HR_NL_DAILY_SICK_AND_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_DAILY_SICK_AND_RECOVERY" AUTHID CURRENT_USER AS
/* $Header: pernldsr.pkh 120.0.12000000.1 2007/01/22 03:27:44 appldev noship $ */
--
--  Descroption
--    This procedure used in user hook creation for the API
--    CREATE_PERSON_ABSENCE
--    A row is inserted into PER_NL_ABSENCE_CHANGES
--    with UPDATE_TYPE as 'START' for every insert
--    into PER_ABSENCE_ATTENDANCES for category 'sickness'
--
PROCEDURE insert_person_absence_changes
  (p_absence_attendance_id        IN number
   ,p_effective_date              IN date
   ,p_person_id                   IN number
   ,p_date_Projected_start        IN date
   ,p_date_start                  IN date
   ,p_abs_information1            IN varchar2
   ,p_date_projected_end          IN date
   ,p_date_end                    IN date);
--
--  Description
--    This procedure used in user hook creation for the API
--    UPDATE_PERSON_ABSENCE
--    A row is inserted into PER_NL_ABSENCE_CHANGES
--    with UPDATE_TYPE as 'UPDATE' or 'END' for every
--    update in PER_ABSENCE_ATTENDANCES for category 'sickness'
--
procedure Update_person_absence_changes
  (p_absence_attendance_id        IN number
   ,p_effective_date              IN date
   ,p_date_end                    IN date
   ,p_date_projected_end          IN date
   ,p_date_start                  IN date
   ,p_date_projected_start        IN date
   ,p_abs_information1            IN varchar2);
--
--  Description
--    This procedure used in user hook creation for the API
--    DELETE_PERSON_ABSENCE
--    A row is inserted into PER_NL_ABSENCE_CHANGES
--    with UPDATE_TYPE as 'DELETE' for every
--    delete in PER_ABSENCE_ATTENDANCES for category 'sickness'
--
procedure Delete_person_absence_changes
(p_absence_attendance_id          IN number);
--
--  Description
--    This purge procedure will remove rows from the
--    the table PER_NL_ABSENCE_CHANGES which are older than
--    one year and will run through concurrent program scheduled to
--    run weekly.
--
procedure purge_per_nl_absence_changes
  (p_errbuf                       OUT nocopy varchar2
   ,p_retcode                     OUT nocopy varchar2
   ,p_effective_date              IN varchar2
   ,p_business_group_id           IN number);
--
--  Description
--    Call to this procedure will update the value for reported_indicator in
--    PER_NL_ABSENCE_CHANGES as 'Y'
--    This procedure is called from the report 'Daily Sick and Recovery Report'
--    All records reported in the report are updated as updated
--
procedure update_reported_absence_chgs
  (p_effective_date               IN date
   ,p_prev_rep_chg                IN varchar2
   ,p_structure_version_id        IN number
   ,p_top_org_id                  IN number);
--
END HR_NL_DAILY_SICK_AND_RECOVERY;

/
