--------------------------------------------------------
--  DDL for Package GHR_COMPLAINTS_CA_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINTS_CA_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: ghcdtapi.pkh 120.1 2005/10/02 01:57:27 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * GHR Complaint Tracking Corrective Action Detail records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Corrective Action Detail
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_ca_detail >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaint Tracking Corrective Action Detail record.
 *
 * This API creates a child Corrective Action Detail record in table
 * ghr_compl_ca_details for an existing parent Corrective Action Header.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint Corrective Action Header record must exist in
 * ghr_compl_headers.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Corrective Action Detail record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Corrective Action Detail record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_ca_header_id Uniquely identifies the Parent Complaint
 * Corrective Action Header record.
 * @param p_amount {@rep:casecolumn GHR_COMPL_CA_DETAILS.AMOUNT}
 * @param p_order_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.ORDER_DATE}
 * @param p_due_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.DUE_DATE}
 * @param p_request_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.REQUEST_DATE}
 * @param p_complete_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.COMPLETE_DATE}
 * @param p_category Complaint Corrective Action Detail Category. Valid values
 * are defined by 'GHR_US_CA_CATEGORIES' lookup type.
 * @param p_phase Complaint Corrective Action Detail Phase. Valid values are
 * defined by 'GHR_US_CA_PHASES' lookup type.
 * @param p_action_type Complaint Corrective Action Detail Type. Valid values
 * are defined by 'GHR_US_CA_ACTION_TYPE' lookup type.
 * @param p_payment_type Complaint Corrective Action Detail Payment Type. Valid
 * values are defined by 'GHR_US_CA_PAYMENT_TYPE' lookup type.
 * @param p_description {@rep:casecolumn GHR_COMPL_CA_DETAILS.DESCRIPTION}
 * @param p_compl_ca_detail_id If p_validate is false, then this uniquely
 * identifies the Corrective Action Detail created. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Corrective Action Detail. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Corrective Action Detail
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_detail
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_compl_ca_header_id             in     number   default null
  --,p_action                         in     varchar2 default null
  ,p_amount                         in     number   default null
  ,p_order_date                     in     date     default null
  ,p_due_date                       in     date     default null
  ,p_request_date                   in     date     default null
  ,p_complete_date                  in     date     default null
  ,p_category                       in     varchar2 default null
  --,p_type                           in     varchar2 default null
  ,p_phase                          in     varchar2 default null
  ,p_action_type                    in     varchar2 default null
  ,p_payment_type                   in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_compl_ca_detail_id             out nocopy    number
  ,p_object_version_number          out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_ca_detail >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Complaint Tracking Corrective Action Detail records.
 *
 * This API updates a child Corrective Action Detail record in table
 * ghr_compl_ca_details for an existing parent Corrective Action Header.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint Header record must exist in ghr_compl_headers.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Corrective Action Detail record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Corrective Action Detail record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_ca_detail_id Uniquely identifies the Complaint Detail record
 * to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * Corrective Action Detail to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated Corrective
 * Action Detail. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_compl_ca_header_id Uniquely identifies the Parent Complaint Header
 * record.
 * @param p_amount {@rep:casecolumn GHR_COMPL_CA_DETAILS.AMOUNT}
 * @param p_order_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.ORDER_DATE}
 * @param p_due_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.DUE_DATE}
 * @param p_request_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.REQUEST_DATE}
 * @param p_complete_date {@rep:casecolumn GHR_COMPL_CA_DETAILS.COMPLETE_DATE}
 * @param p_category Complaint Corrective Action Detail Category. Valid values
 * are defined by 'GHR_US_CA_CATEGORIES' lookup type.
 * @param p_phase Complaint Corrective Action Detail Phase. Valid values are
 * defined by 'GHR_US_CA_PHASES' lookup type.
 * @param p_action_type Complaint Corrective Action Detail Action Type. Valid
 * values are defined by 'GHR_US_CA_ACTION_TYPE' lookup type.
 * @param p_payment_type Complaint Corrective Action Detail Payment Type. Valid
 * values are defined by 'GHR_US_CA_PAYMENT_TYPE' lookup type.
 * @param p_description {@rep:casecolumn GHR_COMPL_CA_DETAILS.DESCRIPTION}
 * @rep:displayname Update Corrective Action Detail
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_detail
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_ca_detail_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_compl_ca_header_id           in     number   default hr_api.g_number
  --,p_action                       in     varchar2 default hr_api.g_varchar2
  ,p_amount                       in     number   default hr_api.g_number
  ,p_order_date                   in     date     default hr_api.g_date
  ,p_due_date                     in     date     default hr_api.g_date
  ,p_request_date                 in     date     default hr_api.g_date
  ,p_complete_date                in     date     default hr_api.g_date
  ,p_category                     in     varchar2 default hr_api.g_varchar2
  --,p_type                         in     varchar2 default hr_api.g_varchar2
  ,p_phase                        in     varchar2 default hr_api.g_varchar2
  ,p_action_type                  in     varchar2 default hr_api.g_varchar2
  ,p_payment_type                 in     varchar2 default hr_api.g_varchar2
  ,p_description                  in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_ca_detail >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Complaint Tracking Corrective Action Detail records.
 *
 * This API deletes a child Corrective Action Detail record from table
 * ghr_compl_ca_details for an existing parent Corrective Action Header.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Corrective Action Detail record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Corrective Action Detail record from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Corrective Action Detail record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_ca_detail_id Uniquely identifies the Complaint Corrective
 * Action Detail record to be deleted.
 * @param p_object_version_number Current version number of the Corrective
 * Action Detail to be deleted.
 * @rep:displayname Delete Corrective Action Detail
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ca_detail
  (p_validate                      in     boolean  default false
  ,p_compl_ca_detail_id            in     number
  ,p_object_version_number         in     number
  );

end ghr_complaints_ca_details_api;

 

/
