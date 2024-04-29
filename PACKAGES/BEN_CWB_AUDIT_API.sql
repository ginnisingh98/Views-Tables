--------------------------------------------------------
--  DDL for Package BEN_CWB_AUDIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_AUDIT_API" AUTHID CURRENT_USER as
/* $Header: beaudapi.pkh 120.4 2006/10/27 10:52:17 steotia noship $ */
/*#
 * This package contains API to generate audit log for data changes in
 * Compensation Workbench tables.
 * The Audit log table contains records of every change event that occurs
 * within a compensation Workbench user session, such as changing an amount,
 * changing eligibility, or reassigning an employee. The purpose of this
 * information is for audit reporting.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Compensation Workbench Audit Log
*/
TYPE code_flag IS RECORD (
  code   hr_lookups.lookup_code%type,
  flag   hr_lookups.enabled_flag%type
);
TYPE g_validity_table_type IS TABLE OF code_flag;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_per_record >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package contains API to create a record when a transaction occurs
 * within Compensation Workbench.
 *
 * Upon a Compensation Workbench action, the action and related information are
 * recorded for purposes of an audit reporting. This API creates audit log for
 * persons when a compensation event for them begins.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person in life event reason record should exist.
 *
 * <p><b>Post Success</b><br>
 * The audit record will be prepared for insertion.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be created.
 *
 * @param p_per_in_ler_id {@rep:casecolumn BEN_PER_IN_LER.PER_IN_LER_ID}
 * @rep:displayname Prepare Audit Record
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_per_record
  (p_per_in_ler_id       in number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_per_record >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package contains API to create a record when a transaction occurs
 * within Compensation Workbench.
 *
 * Upon a Compensation Workbench action, the action and related information are
 * recorded for purposes of an audit reporting. This API creates audit log for
 * a person when compensation event occurs such back out event or employee
 * reassignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person in life event reason record should exist.
 *
 * <p><b>Post Success</b><br>
 * The audit record will have been prepared for insertion.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be created.
 *
 * @param p_per_in_ler_id {@rep:casecolumn BEN_PER_IN_LER.PER_IN_LER_ID}
 * @param p_old_val The old value before updating data.
 * @param p_audit_type_cd The valid values defined by 'BEN_CWB_AUDIT_TYPE'
 * lookup type.
 * @rep:displayname Prepare Audit Record
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_per_record
  (p_per_in_ler_id      in number
  ,p_old_val            in varchar2
  ,p_audit_type_cd      in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_per_record >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_per_record
  (p_per_in_ler_id           in     ben_per_in_ler.per_in_ler_id%type
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_audit_entry >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package contains API to insert an audit record in the database.
 *
 * This created record is shown in the Audit Report page of the Compensation
 * Workbench pages. Upon a Compensation Workbench action, the action and
 * related information is recorded for purposes of an audit reporting.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person in life event reason record should exist.
 *
 * <p><b>Post Success</b><br>
 * The audit record will have been inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be inserted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id {@rep:casecolumn BEN_PER_IN_LER.PER_IN_LER_ID}
 * @param p_group_pl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_PL_ID}
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_PER_IN_LER.LF_EVT_OCRD_DT}
 * @param p_pl_id This parameter specifies the Compensation Workbench Plan for
 * which the audit record is generated.
 * @param p_group_oipl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_OIPL_ID}
 * @param p_audit_type_cd Audit type. Valid values defined by
 * 'BEN_CWB_AUDIT_TYPE' lookup.
 * @param p_old_val_varchar Old value(varchar).
 * @param p_new_val_varchar New value(varchar).
 * @param p_old_val_number Old value(number).
 * @param p_new_val_number New value(number).
 * @param p_old_val_date Old value(date).
 * @param p_new_val_date New value(date).
 * @param p_date_stamp Datestamp of record insertion.
 * @param p_change_made_by_person_id Person ID of the logged in person.
 * @param p_supporting_information Miscellaneous information for record.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_cwb_audit_id Sequence generated primary key.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created audit record. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Audit Record in the Database
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_audit_entry
  (p_validate                      in     boolean    default false
  ,p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_pl_id                         in     number
  ,p_group_oipl_id                 in     number     default null
  ,p_audit_type_cd                 in     varchar2
  ,p_old_val_varchar               in     varchar2   default null
  ,p_new_val_varchar               in     varchar2   default null
  ,p_old_val_number                in     number     default null
  ,p_new_val_number                in     number     default null
  ,p_old_val_date                  in     date       default null
  ,p_new_val_date                  in     date       default null
  ,p_date_stamp                    in     date       default null
  ,p_change_made_by_person_id      in     number     default null
  ,p_supporting_information        in     varchar2   default null
  ,p_request_id                    in     number     default null
  ,p_cwb_audit_id                  out nocopy     number
  ,p_object_version_number         out nocopy     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_audit_entry >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package contains API to update an audit record in the database.
 *
 * This updated record is shown in the Audit Report page of the Compensation
 * Workbench pages. Upon a Compensation Workbench action, the action and
 * related information is recorded for purposes of an audit reporting.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person in life event reason record should exist.
 *
 * <p><b>Post Success</b><br>
 * The audit record will have been updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cwb_audit_id Sequence generated primary key.
 * @param p_group_per_in_ler_id {@rep:casecolumn BEN_PER_IN_LER.PER_IN_LER_ID}
 * @param p_group_pl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_PL_ID}
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_PER_IN_LER.LF_EVT_OCRD_DT}
 * @param p_pl_id This parameter specifies the Compensation Workbench Plan for
 * which the audit record is generated.
 * @param p_group_oipl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_OIPL_ID}
 * @param p_audit_type_cd Audit type. Valid values defined by
 * 'BEN_CWB_AUDIT_TYPE' lookup type.
 * @param p_old_val_varchar Old value(varchar).
 * @param p_new_val_varchar New value(varchar).
 * @param p_old_val_number Old value(number).
 * @param p_new_val_number New value(number).
 * @param p_old_val_date Old value(date).
 * @param p_new_val_date New value(date).
 * @param p_date_stamp Datestamp of record insertion.
 * @param p_change_made_by_person_id Person ID of the logged in person.
 * @param p_supporting_information Miscellaneous information for record.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_object_version_number Pass in the current version number of the
 * audit record to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated audit record. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Audit Record in the Database
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_audit_entry
  (p_validate                      in     boolean  default false
  ,p_cwb_audit_id                  in     number
  ,p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_pl_id                         in     number
  ,p_group_oipl_id                 in     number   default hr_api.g_number
  ,p_audit_type_cd                 in     varchar2
  ,p_old_val_varchar               in     varchar2 default hr_api.g_varchar2
  ,p_new_val_varchar               in     varchar2 default hr_api.g_varchar2
  ,p_old_val_number                in     number   default hr_api.g_number
  ,p_new_val_number                in     number   default hr_api.g_number
  ,p_old_val_date                  in     date     default hr_api.g_date
  ,p_new_val_date                  in     date     default hr_api.g_date
  ,p_date_stamp                    in     date     default hr_api.g_date
  ,p_change_made_by_person_id      in     number   default hr_api.g_number
  ,p_supporting_information        in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_audit_entry >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package contains API to delete an audit record in the database.
 *
 * This deleted record will not display in the Audit Report pages of
 * Compensation Workbench pages.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The audit record must exist.
 *
 * <p><b>Post Success</b><br>
 * The audit record will have been deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cwb_audit_id Sequence generated primary key.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Delete Audit Record in the Database
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_audit_entry
  (p_validate                      in     boolean  default false
  ,p_cwb_audit_id                  in     number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< return_column_code >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The API returns 1 for char, 2 for number and 3 for date type.
 *
 * The return data type is used for mapping the audit type to the relevant
 * datatype of value modified. This information is used to pick the matching
 * attribute from the BEN_CWB_AUDIT table into the Audit Report in Compensation
 * Workbench pages.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The lookup code should be a valid audit type defined in the
 * 'BEN_CWB_AUDIT_TYPE' lookup.
 *
 * <p><b>Post Success</b><br>
 * A non null number will be returned.
 *
 * <p><b>Post Failure</b><br>
 * A Null number will be returned.
 *
 * @param p_lookup_code Audit type. Valid values defined by
 * 'BEN_CWB_AUDIT_TYPE' lookup type.
 * @return The API returns a code to identify the datatype of the attribute whose change triggered the audit event. The API returns 1 for character, 2 for number and 3 for date type.
 * @rep:displayname Return Datatype of Audited Value
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
function return_column_code
  (p_lookup_code                in     varchar2
  )return number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< return_lookup_validity >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Returns true if audit triggering event is not end dated or is disabled,
 * otherwise returns false.
 *
 * The validity of audit triggering events are controlled by the state of
 * lookup codes in 'BEN_CWB_AUDIT_TYPE' lookup. The API queries the database
 * and returns this state. Only on the return value being true is further
 * processing performed for insertion of audit record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Lookup code should be defined in 'BEN_CWB_AUDIT_TYPE' Lookup
 *
 * <p><b>Post Success</b><br>
 * Returns true if lookup_code is not end dated or disabled and false if
 * otherwise
 *
 * <p><b>Post Failure</b><br>
 * Returns false
 *
 * @param p_lookup_code lookup code.
 * @return The API returns the validity of triggered audit event. If valid it returns true otherwise false.
 * @rep:displayname Return Validity of Audit Event
 * @rep:category BUSINESS_ENTITY BEN_CWB_AUDIT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
function return_lookup_validity
  (p_lookup_code                in     varchar2
  )return boolean;
end BEN_CWB_AUDIT_API;

 

/
