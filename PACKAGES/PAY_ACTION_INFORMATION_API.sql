--------------------------------------------------------
--  DDL for Package PAY_ACTION_INFORMATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACTION_INFORMATION_API" AUTHID CURRENT_USER as
/* $Header: pyaifapi.pkh 120.1 2005/10/02 02:29:11 aroussel $ */
/*#
 * This package contains action information APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Action Information
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_action_information >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates action information records.
 *
 * The records are created when the archive process calls this API to archive
 * assignment actions. The actions archived usually are prepayment actions,
 * quick pay prepayment actions, reversals or those balance adjustment actions
 * that get prepaid. The actions could be a subset of those mentioned above for
 * certain legislations.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Records are created only if the assignment has undergone either a
 * prepayment, a quick payprepayment, reversal or a balance adjustment that
 * subsequently was prepaid. Legislation specific rules might apply here.
 *
 * <p><b>Post Success</b><br>
 * The API creates action information records
 *
 * <p><b>Post Failure</b><br>
 * The API does not insert the action information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_action_context_id payroll_action_id or assignment_action_id
 * depending upon context type.
 * @param p_action_context_type context type of PA, AAC and AAP indicate
 * Payroll Action, Assignment Action Creation and Assignment Action Processing
 * respectively.
 * @param p_action_information_category The action information category maps to
 * a context code in Action Information DF.
 * @param p_tax_unit_id {@rep:casecolumn PAY_ASSIGNMENT_ACTIONS.TAX_UNIT_ID}
 * @param p_jurisdiction_code This is defined as a context in FF_CONTEXTS. The
 * value of this context for the assignment is stored here.
 * @param p_source_id This is defined as a context in FF_CONTEXTS. The value of
 * this context for the assignment is stored here.
 * @param p_source_text This is defined as a context in FF_CONTEXTS. The value
 * of this context for the assignment is stored here.
 * @param p_tax_group This is defined as a context in FF_CONTEXTS. The value of
 * this context for the assignment is stored here.
 * @param p_effective_date Effective date of the contributing action
 * @param p_assignment_id Identifies the assignment for which you create the
 * action information record.
 * @param p_action_information1 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information2 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information3 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information4 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information5 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information6 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information7 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information8 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information9 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information10 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information11 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information12 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information13 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information14 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information15 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information16 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information17 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information18 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information19 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information20 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information21 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information22 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information23 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information24 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information25 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information26 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information27 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information28 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information29 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information30 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information_id PK of record
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created action information record. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Action Information
 * @rep:category BUSINESS_ENTITY PAY_PAYMENT_ARCHIVE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_action_information
(
   p_validate                       in     boolean   default false
  ,p_action_context_id              in     number
  ,p_action_context_type            in     varchar2
  ,p_action_information_category    in     varchar2
  ,p_tax_unit_id                    in     number    default null
  ,p_jurisdiction_code              in     varchar2  default null
  ,p_source_id                      in     number    default null
  ,p_source_text                    in     varchar2  default null
  ,p_tax_group                      in     varchar2  default null
  ,p_effective_date                 in     date      default null
  ,p_assignment_id                  in     number    default null
  ,p_action_information1            in     varchar2  default null
  ,p_action_information2            in     varchar2  default null
  ,p_action_information3            in     varchar2  default null
  ,p_action_information4            in     varchar2  default null
  ,p_action_information5            in     varchar2  default null
  ,p_action_information6            in     varchar2  default null
  ,p_action_information7            in     varchar2  default null
  ,p_action_information8            in     varchar2  default null
  ,p_action_information9            in     varchar2  default null
  ,p_action_information10           in     varchar2  default null
  ,p_action_information11           in     varchar2  default null
  ,p_action_information12           in     varchar2  default null
  ,p_action_information13           in     varchar2  default null
  ,p_action_information14           in     varchar2  default null
  ,p_action_information15           in     varchar2  default null
  ,p_action_information16           in     varchar2  default null
  ,p_action_information17           in     varchar2  default null
  ,p_action_information18           in     varchar2  default null
  ,p_action_information19           in     varchar2  default null
  ,p_action_information20           in     varchar2  default null
  ,p_action_information21           in     varchar2  default null
  ,p_action_information22           in     varchar2  default null
  ,p_action_information23           in     varchar2  default null
  ,p_action_information24           in     varchar2  default null
  ,p_action_information25           in     varchar2  default null
  ,p_action_information26           in     varchar2  default null
  ,p_action_information27           in     varchar2  default null
  ,p_action_information28           in     varchar2  default null
  ,p_action_information29           in     varchar2  default null
  ,p_action_information30           in     varchar2  default null
  ,p_action_information_id             out nocopy number
  ,p_object_version_number             out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_action_information >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates action information records.
 *
 * API to update action information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Record can only be updated if they exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the action information records.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the action information records and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_action_information_id PK of record
 * @param p_object_version_number Pass in the current version number of the
 * action information to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated
 * action_information. If p_validate is true will be set to the same value
 * which was passed in.
 * @param p_action_information1 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information2 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information3 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information4 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information5 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information6 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information7 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information8 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information9 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information10 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information11 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information12 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information13 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information14 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information15 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information16 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information17 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information18 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information19 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information20 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information21 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information22 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information23 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information24 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information25 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information26 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information27 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information28 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information29 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @param p_action_information30 This column maps to a segment on Action
 * Information DF for a given action information category.
 * @rep:displayname Update Action Information
 * @rep:category BUSINESS_ENTITY PAY_PAYMENT_ARCHIVE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_action_information
  (
   p_validate                       in     boolean    default false
  ,p_action_information_id          in     number
  ,p_object_version_number          in out nocopy number
  ,p_action_information1            in     varchar2  default hr_api.g_varchar2
  ,p_action_information2            in     varchar2  default hr_api.g_varchar2
  ,p_action_information3            in     varchar2  default hr_api.g_varchar2
  ,p_action_information4            in     varchar2  default hr_api.g_varchar2
  ,p_action_information5            in     varchar2  default hr_api.g_varchar2
  ,p_action_information6            in     varchar2  default hr_api.g_varchar2
  ,p_action_information7            in     varchar2  default hr_api.g_varchar2
  ,p_action_information8            in     varchar2  default hr_api.g_varchar2
  ,p_action_information9            in     varchar2  default hr_api.g_varchar2
  ,p_action_information10           in     varchar2  default hr_api.g_varchar2
  ,p_action_information11           in     varchar2  default hr_api.g_varchar2
  ,p_action_information12           in     varchar2  default hr_api.g_varchar2
  ,p_action_information13           in     varchar2  default hr_api.g_varchar2
  ,p_action_information14           in     varchar2  default hr_api.g_varchar2
  ,p_action_information15           in     varchar2  default hr_api.g_varchar2
  ,p_action_information16           in     varchar2  default hr_api.g_varchar2
  ,p_action_information17           in     varchar2  default hr_api.g_varchar2
  ,p_action_information18           in     varchar2  default hr_api.g_varchar2
  ,p_action_information19           in     varchar2  default hr_api.g_varchar2
  ,p_action_information20           in     varchar2  default hr_api.g_varchar2
  ,p_action_information21           in     varchar2  default hr_api.g_varchar2
  ,p_action_information22           in     varchar2  default hr_api.g_varchar2
  ,p_action_information23           in     varchar2  default hr_api.g_varchar2
  ,p_action_information24           in     varchar2  default hr_api.g_varchar2
  ,p_action_information25           in     varchar2  default hr_api.g_varchar2
  ,p_action_information26           in     varchar2  default hr_api.g_varchar2
  ,p_action_information27           in     varchar2  default hr_api.g_varchar2
  ,p_action_information28           in     varchar2  default hr_api.g_varchar2
  ,p_action_information29           in     varchar2  default hr_api.g_varchar2
  ,p_action_information30           in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_action_information >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes action information records.
 *
 * API to delete action information records.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The action information records must exist for the API to delete them.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the action information records.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the action information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_action_information_id Primary key of record which uniquely
 * identifies it.
 * @param p_object_version_number Current version number of the action
 * information to be deleted.
 * @rep:displayname Delete Action Information
 * @rep:category BUSINESS_ENTITY PAY_PAYMENT_ARCHIVE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_action_information
  (
   p_validate                       in     boolean  default false
  ,p_action_information_id          in     number
  ,p_object_version_number          in out nocopy number
  );
--
end pay_action_information_api;

 

/
