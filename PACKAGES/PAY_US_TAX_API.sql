--------------------------------------------------------
--  DDL for Package PAY_US_TAX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_API" AUTHID CURRENT_USER AS
/* $Header: pytaxapi.pkh 120.1 2005/10/02 02:34:32 aroussel $ */
/*#
 * This package contains United States tax details maintenance APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Tax for United States
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< correct_tax_percentage >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process is a public interface to allow correcting
--   of individual jurisdiction percentages.  This calls the internal process
--   maintain_tax_percentage with a datetrack mode of 'CORRECTION'.
--
-- Prerequisites:
--   Jurisdiction being corrected must already exist.
--
-- In Parameters:
--   Name              Reqd Type     Description
--   p_validate        Yes  boolean  Commit or Rollback
--                                   FALSE(default) or TRUE
--   p_assignment_id   Yes  number   current assignment id
--   p_effective_date  Yes  date     Session Date.
--   p_state_code      Yes  varchar2 Two digit state code
--   p_county_code     Yes  varchar2 Three digit county code
--   p_city_code       Yes  varchar2 Four digit city code
--   p_percentage      Yes  number   New percentage for jurisdiction
--
-- Post Success:
--   There are no output parameters.
--
-- Post Failure:
--   If an error occurs the percentage rate will not be updated and an error
--   message will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
   procedure correct_tax_percentage
                (
                 p_validate                  boolean default false
                ,p_assignment_id             number
                ,p_effective_date            date
                ,p_state_code                varchar2
                ,p_county_code               varchar2
                ,p_city_code                 varchar2
                ,p_percentage                number
               );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_tax_rule >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a tax rule record for a state, city, or county for an
 * employee assignment.
 *
 * The associated element entries for an employee assignment are also deleted.
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid tax rule record must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The state, city, or county tax rule records will be successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The state, city, or county tax rule record will not be deleted and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which the tax rule
 * record is deleted.
 * @param p_state_code Two digit state code.
 * @param p_county_code Three digit county code.
 * @param p_city_code Four digit city code.
 * @param p_effective_start_date If P_VALIDATE is false, then set to the
 * effective start date for the deleted tax rule row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_effective_end_date If P_VALIDATE is false, then set to the
 * effective end date for the deleted tax rule row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_object_version_number Current version number of the tax rule to be
 * deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP or DELETE. Modes available for use
 * with a particular record depend on the dates of previous record changes and
 * the effective date of this change.
 * @param p_delete_routine Default Null, Not to be used via the API's
 * @rep:displayname Delete Tax Rule
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_tax_rule
  (
   p_validate                       in  boolean  default false
  ,p_assignment_id                  in  number
  ,p_state_code                     in  varchar2
  ,p_county_code                    in  varchar2 default '000'
  ,p_city_code                      in  varchar2 default '0000'
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2 default 'ZAP'
  ,p_delete_routine                 in  varchar2 default null
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< submit_fed_w4 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure will process a federal W-4 form submission and update the tax tables,
--  store the transaciton in the statutory transaction tables, and create a workflow
--  process to notify all the parties involved.
--
-- Prerequisites:
--   Tax defaulting must have taken place.
--
-- In Parameters:
--   Name                       Reqd Type      Description/Valid Values
--   p_validate                 No   boolean   Rollback or Commit.
--                                             TRUE or FALSE.
--   p_person_id		Yes  number    if of person for whom form is being filed
--   p_effective_date           Yes  date      Session Date.
--   p_source_name	        Yes  varchar2  Source name i.e. "SELF_SERVICE","WINSTAR"
--
--   p_filing_status_code       Yes  varchar2  '01' - Single
--                                             '02' - Married
--                                             '03' - Married, w/hold at higher rate
--   p_withholding_allowances   Yes  number    0 to 999
--   p_fit_additional_tax       Yes  number    >=0
--   p_fit_exempt               Yes  varchar2  'Y' or 'N'
--
-- Post Success:
--   The tax record will be created.  Any states that should be defaulted
--   will be defaulted.  A workflow process will be created to notify the employee
--   that the form has been processed and a notification will be sent to the payroll
--   representative if the form requires reporting to the IRS.
--
--   If p_fit_exempt is set to yes, then the additional_tax and withholding_allowances
--   field are set to zero.
--
--   The following OUT parameters will be set, identifying the new federal tax row:
--
--   Name                       Type     Description
--   p_stat_trans_audit_id      number   PK of stat_trans_audit record
--
-- Post Failure:
--   The tax rules are not updated and an error will be raised.  If there is a workflow
--   error it gets handled through the workflow error mechanisms and is not raised by the api.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure submit_fed_w4
(
   p_validate                    IN     boolean    default false
  ,p_person_id			 IN 	   number
  ,p_effective_date              IN     date
  ,p_source_name		 IN 	   varchar2
  ,p_filing_status_code          IN     varchar2
  ,p_withholding_allowances      IN     number
  ,p_fit_additional_tax          IN     number
  ,p_fit_exempt                  IN     varchar2
  ,p_stat_trans_audit_id         OUT nocopy pay_stat_trans_audit.stat_trans_audit_id%TYPE
 );

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_w4_allowed >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function will verify that the employee can file a w4 electronically.
--  It ensures that the following are true:
--    The primary assignment is not a retiree assignment.
--    No assignments whose tax records will be updated have future dated changes.
--    Tax defaulting has occured for the primary assignment.
--    No tax records that will be updated have future dated changes.
--    No tax records that will be updated have a wa_reject_date set.
--    No tax records that will be updated have a override value set.
--    If a state w4, that the state is currently supported for w4 submissions.
--    If the transaction subtype = ONLINE_TAX_FORMS, that the update method profile
--    is not set to 'NONE'.
--
--  This procedure is called by submit_* procedures before they do any updating,
--  but is exposed so that the ability to submit can be tested independantly of
--  submission(useful for web pages to disable buttons, etc).
--
-- Prerequisites:
--
-- In Parameters:
--   Name                       Reqd Type      Description/Valid Values
--   p_person_id		Yes  number    person for whom form is being filed
--   p_effective_date           Yes  date      Session Date.
--   p_source_name      	Yes  varchar2  Source name (e.g. "WINSTAR")
--   p_state_code		No   varchar2  State code of submission
--						(default is federal)
--
-- Post Success:
--   null will be returned.
--
-- Post Failure:
--   the name of the message explaining the reason why updating can't occur will
--   be returned.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function chk_w4_allowed
(
   p_person_id			    IN 	   number
  ,p_effective_date                 IN     date
  ,p_source_name		    IN 	   varchar2
  ,p_state_code			    IN     varchar2 DEFAULT null
 ) return fnd_new_messages.message_name%TYPE;
--

--
end pay_us_tax_api;

 

/
