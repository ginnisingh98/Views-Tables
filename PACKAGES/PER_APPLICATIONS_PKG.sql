--------------------------------------------------------
--  DDL for Package PER_APPLICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APPLICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: peapp01t.pkh 120.0.12010000.1 2008/07/28 04:06:18 appldev ship $ */
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_prev_ass_type_id                                                  --
-- Purpose                                                                 --
--  to populate a field in the F4 form PERWSTAP, needed for the procedure  --
--  del_letter_term when terminating an applicant.
-- Notes                                                                   --
-----------------------------------------------------------------------------
FUNCTION get_prev_ass_type_id(P_Business_Group_id   NUMBER,
                              p_person_id           NUMBER,
                              p_application_id      NUMBER,
                              p_date_end            DATE) return NUMBER;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   del_letter_term                                                       --
-- Purpose                                                                 --
--   on termination of an applicant's application delete any letter request--
--   lines for the applicant's assignments if they exist for assigment status-
--   types other than TERM_APL.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--  NB. The applicant status TERM_APL is never held on the applicant's     --
-- assignment record.
-----------------------------------------------------------------------------
PROCEDURE del_letter_term(p_person_id           NUMBER,
                          p_business_group_id   NUMBER,
                          p_date_end            DATE,
                          p_application_id      NUMBER,
                          P_dummy_asg_stat_id   NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   insert_letter_term                                                    --
-- Purpose                                                                 --
--   to insert letter request if needs be and to insert letter request lines-
--   when the user specifies a termination status(otional) when doing an   --
--   applicant termination.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE insert_letter_term(P_business_group_id   NUMBER,
                             p_application_id      NUMBER,
                             p_person_id           NUMBER,
                             p_session_date        DATE,
                             p_last_updated_by     NUMBER,
                             p_last_update_login   NUMBER,
                             p_assignment_status_type_id NUMBER );
-----------------------------------------------------------------------------
-- Name                                                                    --
--   del_letters_cancel                                                    --
-- Purpose                                                                 --
--   to delete any letter request lines for the applicant that may exist   --
--   that have an assignment status of TERM_APL.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE del_letters_cancel(p_business_group_id NUMBER,
                             P_person_id         NUMBER,
                             p_application_id     NUMBER
                            );
-----------------------------------------------------------------------------
-- Name                                                                    --
--   cancel_update_assigns                                                 --
-- Purpose                                                                 --
--   on cancelling a termination open the applicant assignments to the end of
--   time.
--   If the applicant was entered through the Quick Entry screen with a    --
--   status of TERM_APL i.e just for recording purposes then the applicant --
--   assignment must be re-opened with the status of ACTIVE_APL.           --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
-- Name                                                                    --
--   cancel_chk_current_emp                                                --
-- Purpose                                                                 --
--   to ensure that if the applicant has been hired as an employee that the -
--   user cannot canel a termination of the applicant's application
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--  called from the client PERWSTAP pre-cancellation
-----------------------------------------------------------------------------
PROCEDURE cancel_chk_current_emp(p_person_id         NUMBER,
                                 p_business_group_id NUMBER,
                                 p_date_end 	     DATE); -- Bug 3380724
-----------------------------------------------------------------------------
PROCEDURE cancel_update_assigns(p_person_id         NUMBER,
                                p_business_group_id NUMBER,
                                P_date_end          DATE,
                                P_application_id    NUMBER,
                                p_legislation_code  VARCHAR2,
                                P_end_of_time       DATE,
                                P_last_updated_by   NUMBER,
                                p_last_update_login NUMBER) ;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   term_update_assignments                                               --
-- Purpose                                                                 --
--   when terminating an applicant close down all the applicant assignments
--   as of the termination date.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE term_update_assignments(p_person_id         NUMBER,
                                  p_business_group_id NUMBER,
                                  P_date_end          DATE,
                                  P_application_id    NUMBER,
                                  p_last_updated_by   NUMBER,
                                  p_last_update_login NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   canc_chk_fut_person_changes                                           --
-- Purpose                                                                 --
--   Check that there are no person type changes after the termination
--   date
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE canc_chk_fut_per_changes(p_person_id      NUMBER,
                                   p_application_id NUMBER,
                                   p_date_end       DATE     ) ;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   term_chk_fut_person_changes                                           --
-- Purpose                                                                 --
--   check that the applicant has no future person record changes after the
--   apparent termination date since this would prohibit a termination.    --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE term_chk_fut_per_changes(p_person_id         NUMBER,
                                      p_business_group_id NUMBER,
                                      P_date_end          DATE);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   term_chk_fut_assign_changes                                           --
-- Purpose                                                                 --
--   if future assignment changes of any sort exist for the person, then   --
--   the user cannot terminate the application.                            --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE term_chk_fut_assign_changes(p_person_id         NUMBER,
                                      p_business_group_id NUMBER,
                                      P_date_end          DATE);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   maint_security_cancel                                                 --
-- Purpose                                                                 --
--   when an applicant's termination is cancelled delete the applicant and --
--   their security profile id from per_person_list_changes.               --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE maint_security_cancel(p_person_id        NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   maint_security_term                                                   --
-- Purpose                                                                 --
--   when the applicant has been terminated ensure that
--   per_person_list_changes is maintained and that a row is inserted for
--   each security profile in which the applicant appears.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE maint_security_term(p_person_id        NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   sec_statuses_cancel                                                   --
-- Purpose                                                                 --
--   to nuliify any secondary assignment statuses end dates on the applicant's
--   assignments if they are currently the same as the termination date when
--   the applicant was terminated.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE sec_statuses_cancel(p_end_date          DATE,
                           p_application_id     NUMBER,
                           p_business_group_id  NUMBER,
                           p_last_updated_by    NUMBER,
                           p_last_update_login  NUMBER,
                           p_person_id          NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   sec_statuses_term                                                     --
-- Purpose                                                                 --
--   to delete any future sec.statuses when terminating an applicant. Puts an
--   end date as of the applicant's termination date for any secondary
--   applicant assignment statuses that start before the termination date
--   and which don't have end dates before the termination end date.       --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE sec_statuses_term(p_end_date          DATE,
                           p_application_id     NUMBER,
                           p_business_group_id  NUMBER,
                           p_last_updated_by    NUMBER,
                           p_last_update_login  NUMBER,
                           p_person_id          NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   del_interviews_term                                                   --
-- Purpose                                                                 --
--   To delete any future interviews that an applicant may have when being --
--   terminated.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE del_interviews_term(P_person_id               NUMBER,
                              P_date_end                DATE,
                              P_Business_group_id       NUMBER,
                              P_application_id          NUMBER);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   maintain_ppt_cancel                                                   --
-- Purpose                                                                 --
--   On cancellation of a termination, delete the last record in PER_PEOPLE_F
--   and open out the previous recordto the end of time.                   --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE maintain_ppt_cancel(P_person_id               NUMBER,
                              P_Business_group_id       NUMBER,
                              P_date_end                DATE,
                              P_last_updated_by         NUMBER,
                              P_last_update_login       NUMBER,
                              P_end_of_time             DATE);

-----------------------------------------------------------------------------
PROCEDURE chk_not_already_termed(P_Business_group_id         NUMBER,
                                 P_person_id                 NUMBER,
                                 P_application_id            NUMBER,
                                 P_date_end                  DATE);
-----------------------------------------------------------------------------

PROCEDURE maintain_ppt_term(P_Business_group_id    NUMBER,
                            P_person_id                 NUMBER,
                            P_date_end                  DATE,
                            P_end_of_time               DATE,
                            P_last_updated_by           NUMBER,
                            P_last_update_login         NUMBER);

PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Application_Id                       IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Person_Id                            NUMBER,
                     p_Date_Received                        DATE,
                     p_Comments                             VARCHAR2,
                     p_Current_Employer                     VARCHAR2,
                     p_Date_End                             DATE,
                     p_Projected_Hire_Date                  DATE,
                     p_Successful_Flag                      VARCHAR2,
                     p_Termination_Reason                   VARCHAR2,
                     p_Appl_Attribute_Category              VARCHAR2,
                     p_Appl_Attribute1                      VARCHAR2,
                     p_Appl_Attribute2                      VARCHAR2,
                     p_Appl_Attribute3                      VARCHAR2,
                     p_Appl_Attribute4                      VARCHAR2,
                     p_Appl_Attribute5                      VARCHAR2,
                     p_Appl_Attribute6                      VARCHAR2,
                     p_Appl_Attribute7                      VARCHAR2,
                     p_Appl_Attribute8                      VARCHAR2,
                     p_Appl_Attribute9                      VARCHAR2,
                     p_Appl_Attribute10                     VARCHAR2,
                     p_Appl_Attribute11                     VARCHAR2,
                     p_Appl_Attribute12                     VARCHAR2,
                     p_Appl_Attribute13                     VARCHAR2,
                     p_Appl_Attribute14                     VARCHAR2,
                     p_Appl_Attribute15                     VARCHAR2,
                     p_Appl_Attribute16                     VARCHAR2,
                     p_Appl_Attribute17                     VARCHAR2,
                     p_Appl_Attribute18                     VARCHAR2,
                     p_Appl_Attribute19                     VARCHAR2,
                     p_Appl_Attribute20                     VARCHAR2,
                     p_Last_Update_Date                     DATE,
                     p_Last_Updated_By                      NUMBER,
                     p_Last_Update_Login                    NUMBER,
                     p_Created_By                           NUMBER,
                     p_Creation_Date                        DATE);

PROCEDURE Lock_Row(p_Rowid                                  VARCHAR2,
                   p_Application_Id                         NUMBER,
                   p_Business_Group_Id                      NUMBER,
                   p_Person_Id                              NUMBER,
                   p_Date_Received                          DATE,
                   p_Comments                               VARCHAR2,
                   p_Current_Employer                       VARCHAR2,
                   p_Date_End                               DATE,
                   p_Projected_Hire_Date                    DATE,
                   p_Successful_Flag                        VARCHAR2,
                   p_Termination_Reason                     VARCHAR2,
                   p_Appl_Attribute_Category                VARCHAR2,
                   p_Appl_Attribute1                        VARCHAR2,
                   p_Appl_Attribute2                        VARCHAR2,
                   p_Appl_Attribute3                        VARCHAR2,
                   p_Appl_Attribute4                        VARCHAR2,
                   p_Appl_Attribute5                        VARCHAR2,
                   p_Appl_Attribute6                        VARCHAR2,
                   p_Appl_Attribute7                        VARCHAR2,
                   p_Appl_Attribute8                        VARCHAR2,
                   p_Appl_Attribute9                        VARCHAR2,
                   p_Appl_Attribute10                       VARCHAR2,
                   p_Appl_Attribute11                       VARCHAR2,
                   p_Appl_Attribute12                       VARCHAR2,
                   p_Appl_Attribute13                       VARCHAR2,
                   p_Appl_Attribute14                       VARCHAR2,
                   p_Appl_Attribute15                       VARCHAR2,
                   p_Appl_Attribute16                       VARCHAR2,
                   p_Appl_Attribute17                       VARCHAR2,
                   p_Appl_Attribute18                       VARCHAR2,
                   p_Appl_Attribute19                       VARCHAR2,
                   p_Appl_Attribute20                       VARCHAR2);

PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Application_Id                      NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Person_Id                           NUMBER,
                     p_Person_Type_Id                      NUMBER,
                     p_Date_Received                       DATE,
                     p_Comments                            VARCHAR2,
                     p_Current_Employer                    VARCHAR2,
                     p_Date_End                            DATE,
                     p_Projected_Hire_Date                 DATE,
                     p_Successful_Flag                     VARCHAR2,
                     p_Termination_Reason                  VARCHAR2,
                     p_Cancellation_Flag                   VARCHAR2, -- parameter added for Bug 3053711
                     p_Appl_Attribute_Category             VARCHAR2,
                     p_Appl_Attribute1                     VARCHAR2,
                     p_Appl_Attribute2                     VARCHAR2,
                     p_Appl_Attribute3                     VARCHAR2,
                     p_Appl_Attribute4                     VARCHAR2,
                     p_Appl_Attribute5                     VARCHAR2,
                     p_Appl_Attribute6                     VARCHAR2,
                     p_Appl_Attribute7                     VARCHAR2,
                     p_Appl_Attribute8                     VARCHAR2,
                     p_Appl_Attribute9                     VARCHAR2,
                     p_Appl_Attribute10                    VARCHAR2,
                     p_Appl_Attribute11                    VARCHAR2,
                     p_Appl_Attribute12                    VARCHAR2,
                     p_Appl_Attribute13                    VARCHAR2,
                     p_Appl_Attribute14                    VARCHAR2,
                     p_Appl_Attribute15                    VARCHAR2,
                     p_Appl_Attribute16                    VARCHAR2,
                     p_Appl_Attribute17                    VARCHAR2,
                     p_Appl_Attribute18                    VARCHAR2,
                     p_Appl_Attribute19                    VARCHAR2,
                     p_Appl_Attribute20                    VARCHAR2);

PROCEDURE Delete_Row(p_Rowid VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< maintain_irc_ass_status >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to update the IRC_ASSIGNMENT_STATUSES when an
--   application is terminated/reverse terminated. This status will be
--   displayed to an External site visitor of iRecruitment
--
-- Prerequisites:
--   An applicant assignment should be existing
--
-- In Parameters:
--   Name                        Reqd   Type     Description
--   p_person_id                 Yes    Number   System generated person
--                                               primary key from PER_PEOPLE_S
--   p_business_group_id         Yes    Number
--   p_application_id            Yes    Number   Id of the application to be
--                                               terminated
--   p_date_end                  Yes    Date     Application end date
--   p_effective_date            Yes    Date     Effective date (Session date)
--   p_legislation_code          Yes    Varchar2 Language sepecific code
--   p_action                    Yes    Varchar2 Action should be 'TERM' or
--                                               'CANCEL'
--
-- Post Success:
--   Will update the application status in IRC_ASSIGNMENT_STATUSES
--
-- Post Failure:
--   None
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
-- ---------------------------------------------------------------------------
procedure maintain_irc_ass_status(p_person_id         number,
                                  p_business_group_id number,
                                  p_date_end          date,
                                  p_effective_date    date,
                                  p_application_id    number,
                                  p_legislation_code  varchar2,
                                  p_action            varchar2);
--
END PER_APPLICATIONS_PKG;

/
