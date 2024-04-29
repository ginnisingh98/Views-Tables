--------------------------------------------------------
--  DDL for Package PQH_FR_EMP_STAT_SITUATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_EMP_STAT_SITUATION_API" AUTHID CURRENT_USER as
/* $Header: pqpsuapi.pkh 120.0 2005/05/29 02:19:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< CREATE_EMP_STAT_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure creates statutory situation for a French Civil Servant. The
-- employee passed must be of agent type Fonctionnaire. There cannot be any
-- overlap with other statutory situations recorded for the employee. The
-- Eligibility Conditions defined for the Situation are evaluated, when the
-- situation is marked as approved.
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd    Type       Description
--  P_VALIDATE                      N	  BOOLEAN    If passed as  TRUE,then changes are not applied. Otherwise
--                                                   changes are applied to the Database.
--  P_EFFECTIVE_DATE                Y 	  DATE       Specifies the reference date for validating lookup values,
--                                                   applicable within the active date range. This date does
--                                                   not determine when the changes take effect.
--  P_STATUTORY_SITUATION_ID        Y    NUMBER      Statutory situation to be recorded for the employee.
--                                                   Foreign Key to PQH_FR_STAT_SITUATIONS table.
--  P_PERSON_ID                     Y    NUMBER      Employee for which the statutory situation is recorded. This
--                                                   is a foreign key to PER_ALL_PEOPLE_F table. Valid employees
--                                                   are those having agent type defined as Fonctionnaire.
--  P_PROVISIONAL_START_DATE        Y    DATE        Tentative start date from which the civil servant will be placed
--                                                   on the situation.
--  P_PROVISIONAL_END_DATE          Y    DATE        Tentative end date for the situation. There cannot be an overlap with
--                                                   other situations recorded for the employee.
--  P_ACTUAL_START_DATE             N    DATE        Actual start date for the employee on the situation.
--  P_ACTUAL_END_DATE               N    DATE        Actual End date for the employee on the situation.
--  P_APPROVAL_FLAG                 N    VARCHAR2    Flag to indicate whether the civil servant's placement
--                                                   on the situation is approved or not. Valid values are Y/N.
--  P_COMMENTS                      N    VARCHAR2    Any generic comments for the situation.
--  P_CONTACT_PERSON_ID             N    NUMBER      Contact person provided as supporiting details for
--                                                   the situation. Foreign key to PER_CONTACT_RELATIONSHIPS table.
--  P_CONTACT_RELATIONSHIP          N    VARCHAR2    Relationship type of the contact with the employee. Valid values
--                                                   are from the lookpup CONTACT.
--  P_EXTERNAL_ORGANIZATION_ID      N    NUMBER      External organization to which the civil servant is seconded.
--                                                   Required to be provided for External Secondment type situation.
--                                                   Foreign Key to HR_ALL_ORGANIZATION_UNITS table.
--  P_RENEWAL_FLAG                  N    VARCHAR2    Flag to indicate whether this record is renewal of employee's
--                                                   current situation. Valid values are Y/N.
--  P_RENEW_STAT_SITUATION_ID       N    NUMBER      Situation that is renewed. This is required to be provided when
--                                                   renewal_flag is Y.
--  P_SECONDED_CAREER_ID            N    NUMBER      Welcoming Career of the civil servant when recording the
--                                                   internal secondment situation. Foreign key to PER_ALL_ASSIGNMENTS_F.
--  P_ATTRIBUTE_CATEGORY            N    VARCHAR2    Descriptive flexfield context column.
--  P_ATTRIBUTE1                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE2                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE3                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE4                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE5                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE6                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE7                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE8                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE9                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE10                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE11                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE12                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE13                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE14                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE15                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE16                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE17                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE18                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE19                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE20                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE21                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE22                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE23                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE24                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE25                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE26                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE27                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE28                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE29                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE30                   N    VARCHAR2    Descriptive flexfield segment.
--
-- Post Success:
--
--
--   Name                                 Type       Description
--  P_EMP_STAT_SITUATION_ID              NUMBER     Sequence generated primary key for the situation.
--  P_OBJECT_VERSION_NUMBER              NUMBER     If, P_validate is false, the process returns the
--                                                   version number of the created  situation.
--                                                   If, P_validate is true, it returns null.
--
-- Post Failure:
-- Raises appropriate error message and the changes are not posted to the database.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure CREATE_EMP_STAT_SITUATION
  (p_validate                      IN     boolean  default false
  ,p_effective_date                IN     date
  ,P_STATUTORY_SITUATION_ID        IN     NUMBER
  ,P_PERSON_ID                     IN     NUMBER
  ,P_PROVISIONAL_START_DATE        IN     DATE
  ,P_PROVISIONAL_END_DATE          IN     DATE
  ,P_ACTUAL_START_DATE             IN     DATE     default null
  ,P_ACTUAL_END_DATE               IN     DATE     default null
  ,P_APPROVAL_FLAG                 IN     VARCHAR2 default null
  ,P_COMMENTS                      IN     VARCHAR2 default null
  ,P_CONTACT_PERSON_ID             IN     NUMBER   default null
  ,P_CONTACT_RELATIONSHIP          IN     VARCHAR2 default null
  ,P_EXTERNAL_ORGANIZATION_ID      IN     NUMBER   default null
  ,P_RENEWAL_FLAG                  IN     VARCHAR2 default null
  ,P_RENEW_STAT_SITUATION_ID       IN     NUMBER   default null
  ,P_SECONDED_CAREER_ID            IN     NUMBER   default null
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 default null
  ,P_ATTRIBUTE1                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE2                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE3                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE4                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE5                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE6                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE7                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE8                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE9                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE10                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE11                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE12                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE13                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE14                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE15                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE16                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE17                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE18                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE19                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE20                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE21                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE22                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE23                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE24                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE25                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE26                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE27                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE28                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE29                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE30                   IN     VARCHAR2 default null
  ,P_EMP_STAT_SITUATION_ID         OUT NOCOPY     NUMBER
  ,P_OBJECT_VERSION_NUMBER         OUT NOCOPY     NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< UPDATE_EMP_STAT_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure updates the statutory situation details for a French Civil
-- Servant. The employee passed must be of agent type Fonctionnaire. There
-- cannot be any overlap with other statutory situations recorded for the employee.
-- The Eligibility Conditions defined for the Situation are evaluated, when the
-- situation is marked as approved.
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd    Type       Description
--  P_VALIDATE                      N	  BOOLEAN    If passed as  TRUE,then changes are not applied. Otherwise
--                                                   changes are applied to the Database.
--  P_EFFECTIVE_DATE                Y 	  DATE       Specifies the reference date for validating lookup values,
--                                                   applicable within the active date range. This date does
--                                                   not determine when the changes take effect.
--  P_STATUTORY_SITUATION_ID        Y    NUMBER      Statutory situation to be recorded for the employee.
--                                                   Foreign Key to PQH_FR_STAT_SITUATIONS table.
--  P_PERSON_ID                     Y    NUMBER      Employee for which the statutory situation is recorded. This
--                                                   is a foreign key to PER_ALL_PEOPLE_F table. Valid employees
--                                                   are those having agent type defined as Fonctionnaire.
--  P_PROVISIONAL_START_DATE        Y    DATE        Tentative start date from which the civil servant will be placed
--                                                   on the situation.
--  P_PROVISIONAL_END_DATE          Y    DATE        Tentative end date for the situation. There cannot be an overlap with
--                                                   other situations recorded for the employee.
--  P_ACTUAL_START_DATE             N    DATE        Actual start date for the employee on the situation.
--  P_ACTUAL_END_DATE               N    DATE        Actual End date for the employee on the situation.
--  P_APPROVAL_FLAG                 N    VARCHAR2    Flag to indicate whether the civil servant's placement
--                                                   on the situation is approved or not. Valid values are Y/N.
--  P_COMMENTS                      N    VARCHAR2    Any generic comments for the situation.
--  P_CONTACT_PERSON_ID             N    NUMBER      Contact person provided as supporiting details for
--                                                   the situation. Foreign key to PER_CONTACT_RELATIONSHIPS table.
--  P_CONTACT_RELATIONSHIP          N    VARCHAR2    Relationship type of the contact with the employee. Valid values
--                                                   are from the lookpup CONTACT.
--  P_EXTERNAL_ORGANIZATION_ID      N    NUMBER      External organization to which the civil servant is seconded.
--                                                   Required to be provided for External Secondment type situation.
--                                                   Foreign Key to HR_ALL_ORGANIZATION_UNITS table.
--  P_RENEWAL_FLAG                  N    VARCHAR2    Flag to indicate whether this record is renewal of employee's
--                                                   current situation. Valid values are Y/N.
--  P_RENEW_STAT_SITUATION_ID       N    NUMBER      Situation that is renewed. This is required to be provided when
--                                                   renewal_flag is Y.
--  P_SECONDED_CAREER_ID            N    NUMBER      Welcoming Career of the civil servant when recording the
--                                                   internal secondment situation. Foreign key to PER_ALL_ASSIGNMENTS_F.
--  P_ATTRIBUTE_CATEGORY            N    VARCHAR2    Descriptive flexfield context column.
--  P_ATTRIBUTE1                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE2                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE3                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE4                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE5                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE6                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE7                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE8                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE9                    N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE10                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE11                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE12                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE13                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE14                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE15                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE16                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE17                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE18                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE19                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE20                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE21                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE22                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE23                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE24                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE25                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE26                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE27                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE28                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE29                   N    VARCHAR2    Descriptive flexfield segment.
--  P_ATTRIBUTE30                   N    VARCHAR2    Descriptive flexfield segment.
--  P_EMP_STAT_SITUATION_ID         Y    NUMBER      ID of the employee's statutory situation to be udpated.
--
-- Post Success:
--
--
--   Name                                 Type       Description
--
--  P_OBJECT_VERSION_NUMBER              NUMBER      Passes the current version number of the Situation to be updated.
--                                                   When the API completes if p_validate is false, the process returns
--                                                   the new version number of the updated Length of Service Situation.
--                                                   If p_validate, it returns the same value which was passed in.
--
-- Post Failure:
-- Raises appropriate error message and the changes are not posted to the database.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure UPDATE_EMP_STAT_SITUATION
  (p_validate                      IN     boolean  default false
  ,p_effective_date                IN     date
  ,P_EMP_STAT_SITUATION_ID         IN     NUMBER
  ,P_STATUTORY_SITUATION_ID        IN     NUMBER   default hr_api.g_number
  ,P_PERSON_ID                     IN     NUMBER   default hr_api.g_number
  ,P_PROVISIONAL_START_DATE        IN     DATE     default hr_api.g_date
  ,P_PROVISIONAL_END_DATE          IN     DATE     default hr_api.g_date
  ,P_ACTUAL_START_DATE             IN     DATE     default hr_api.g_date
  ,P_ACTUAL_END_DATE               IN     DATE     default hr_api.g_date
  ,P_APPROVAL_FLAG                 IN     VARCHAR2 default hr_api.g_varchar2
  ,P_COMMENTS                      IN     VARCHAR2 default hr_api.g_varchar2
  ,P_CONTACT_PERSON_ID             IN     NUMBER   default hr_api.g_number
  ,P_CONTACT_RELATIONSHIP          IN     VARCHAR2 default hr_api.g_varchar2
  ,P_EXTERNAL_ORGANIZATION_ID      IN     NUMBER   default hr_api.g_number
  ,P_RENEWAL_FLAG                  IN     VARCHAR2 default hr_api.g_varchar2
  ,P_RENEW_STAT_SITUATION_ID       IN     NUMBER   default hr_api.g_number
  ,P_SECONDED_CAREER_ID            IN     NUMBER   default hr_api.g_number
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE1                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE2                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE3                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE4                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE5                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE6                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE7                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE8                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE9                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE10                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE11                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE12                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE13                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE14                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE15                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE16                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE17                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE18                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE19                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE20                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE21                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE22                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE23                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE24                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE25                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE26                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE27                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE28                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE29                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE30                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< DELETE_EMP_STAT_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure deletes the statutory situation details for a French Civil
-- Servant. A situation that is current or already passed cannot be deleted.
-- Only future dated situations can be deleted.
-- Prerequisites:
-- Employee Statutory situation must exist and should be of a future date.
--
-- In Parameters:
-- Name                           Reqd    Type       Description
-- P_VALIDATE                      N	  BOOLEAN    If passed as  TRUE,then changes are not applied. Otherwise
--                                                   changes are applied to the Database.
-- P_EMP_STAT_SITUATION_ID         Y    NUMBER       ID of the employee's statutory situation to be deleted.
-- P_OBJECT_VERSION_NUMBER         Y     NUMBER      Version Number of the situation that is to be deleted.
-- Post Success:
--   Deletes the employee's statutory situation. Reverts any assignment changes that were effected
--   while recording the situation.
-- Post Failure:
--   Raises appropriated error messages. Situation details are not deleted.
Procedure DELETE_EMP_STAT_SITUATION
( P_VALIDATE   IN BOOLEAN DEFAULT FALSE
 ,P_EMP_STAT_SITUATION_ID IN NUMBER
 ,P_OBJECT_VERSION_NUMBER IN NUMBER);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< RENEW_EMP_STAT_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure renews the current statutory situation for the civil servant.
-- By this, the renewed situation's duration is extended by the specified amount.
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd    Type       Description
-- P_VALIDATE                      N	  BOOLEAN    If passed as  TRUE,then changes are not applied. Otherwise
--                                                   changes are applied to the Database.
-- P_EMP_STAT_SITUATION_ID         Y      NUMBER     ID of the renewal statutory situation for the employee.
-- P_RENEW_STAT_SITUATION_ID       Y      NUMBER     ID of the employee's statutory situation to be renewed.
-- P_OBJECT_VERSION_NUMBER         Y      NUMBER     Version Number of the situation that is to be renewed.
-- P_RENEWAL_DURATION              Y      NUMBER     Duration by which the situation is to be extended.
-- P_DURATION_UNITS                Y      VARCHAR2   Units for the duration. Valid values are from lookup type QUALIFYING_UNITS.
-- Post Success:
--   Renews employee's statutory situation. If the renewal is approved then, updates
--   the original situation to extend the provisional and actual end dates. Also
--   extends the assignment changes (if any) by this duration. Returns the updated
-- Post Failure:
--   Raises appropriate error messages. Situation is not renewed.
Procedure RENEW_EMP_STAT_SITUATION
( P_VALIDATE   IN BOOLEAN DEFAULT FALSE
 ,P_EMP_STAT_SITUATION_ID IN OUT NOCOPY NUMBER
 ,P_RENEW_STAT_SITUATION_ID IN NUMBER
 ,P_RENEWAL_DURATION  IN NUMBER
 ,P_DURATION_UNITS    IN VARCHAR2
 ,P_APPROVAL_FLAG     IN VARCHAR2
 ,P_COMMENTS        IN VARCHAR2
 ,P_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< REINSTATE_EMP_STAT_SITUATION >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure reinstates the civil servant from the current statutory situation.
-- By this, the current situation is end dated and a new situation with default
-- In Activity type is created starting from the re-instatement date.
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd    Type       Description
-- P_VALIDATE                      N	  BOOLEAN    If passed as  TRUE,then changes are not applied. Otherwise
--                                                   changes are applied to the Database.
-- P_EMP_STAT_SITUATION_ID         Y      NUMBER     ID of the employee's statutory situation to be reinstated.
-- P_REINSTATE_DATE                Y      DATE       Date on which the civil servant is re-instated
-- Post Success:
--   Creates a new situation using the default "In Activity" type situation for the civil servant starting
--   with the reinstatement date. The current situation of the civil servant is end dated with a date as one day
--   prior to the reinstatement date. This also re-activates the career and affectations for the civil servant.
--   Returns the new "In Activity" situation id to P_NEW_EMP_STAT_SITUATION_ID.
-- Post Failure:
--   Raises appropriated error messages. Situation is not renewed.
procedure reinstate_emp_stat_situation
( P_VALIDATE   IN BOOLEAN DEFAULT FALSE
 ,P_PERSON_ID  IN NUMBER
 ,P_EMP_STAT_SITUATION_ID IN NUMBER
 ,P_REINSTATE_DATE   IN DATE
 ,P_COMMENTS        IN VARCHAR2
 ,P_NEW_EMP_STAT_SITUATION_ID OUT NOCOPY NUMBER) ;
--
  PROCEDURE update_assignments(p_person_id              IN NUMBER
                              ,p_emp_stat_situation_id  IN NUMBER DEFAULT NULL
                              ,p_statutory_situation_id IN NUMBER
                              ,p_start_date             IN DATE
                              ,p_end_date               IN DATE   DEFAULT NULL);
--
end PQH_FR_EMP_STAT_SITUATION_API;

 

/
