--------------------------------------------------------
--  DDL for Package BEN_CWB_STOCK_OPTN_DTLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_STOCK_OPTN_DTLS_API" AUTHID CURRENT_USER as
/* $Header: becsoapi.pkh 120.4 2006/10/17 10:30:58 steotia noship $ */
/*#
 * This package contains APIs to upload third party stock option data.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Compensation Workbench Stock Option
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cwb_stock_optn_dtls >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts a Compensation Workbench Stock Option Detail record.
 *
 * This new record is shown in the extended stock option region of the
 * Compensation Workbench history pages. The load process uses this API to load
 * the stock detail data obtained from an external source.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Self-Service Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Stock Option Detail record is successfully
 * inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Compensation Workbench Stock Option Detail
 * record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_grant_id {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_ID}
 * @param p_grant_number {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_NUMBER}
 * @param p_grant_name {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_NAME}
 * @param p_grant_type {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_TYPE}
 * @param p_grant_date {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_DATE}
 * @param p_grant_shares {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_SHARES}
 * @param p_grant_price {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_PRICE}
 * @param p_value_at_grant {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.VALUE_AT_GRANT}
 * @param p_current_share_price {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CURRENT_SHARE_PRICE}
 * @param p_current_shares_outstanding Number of current outstanding shares.
 * @param p_vested_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.VESTED_SHARES}
 * @param p_unvested_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.UNVESTED_SHARES}
 * @param p_exercisable_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EXERCISABLE_SHARES}
 * @param p_exercised_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EXERCISED_SHARES}
 * @param p_cancelled_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CANCELLED_SHARES}
 * @param p_trading_symbol {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.TRADING_SYMBOL}
 * @param p_expiration_date {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EXPIRATION_DATE}
 * @param p_reason_code {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.REASON_CODE}
 * @param p_class {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.CLASS}
 * @param p_misc {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.MISC}
 * @param p_employee_number Specifies the Employee Number of the person to whom
 * the stock option was granted. If the Person ID is not passed, then the
 * process requires this Employee Number.
 * @param p_person_id Specifies the Person ID of the person to whom the stock
 * option was granted. If passed, the person record must exist. If the Person
 * ID is not passed in, then the process requires the Business Group and
 * Employee Number.
 * @param p_business_group_id Specifies the Business Group ID of the person to
 * whom the stock option was granted. If passed, then the Business Group record
 * must exist. If the Person ID is not passed in, the process requires the
 * Business Group ID.
 * @param p_prtt_rt_val_id {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.PRTT_RT_VAL_ID}
 * @param p_cso_attribute_category {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE_CATEGORY}
 * @param p_cso_attribute1 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE1}
 * @param p_cso_attribute2 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE2}
 * @param p_cso_attribute3 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE3}
 * @param p_cso_attribute4 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE4}
 * @param p_cso_attribute5 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE5}
 * @param p_cso_attribute6 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE6}
 * @param p_cso_attribute7 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE7}
 * @param p_cso_attribute8 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE8}
 * @param p_cso_attribute9 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE9}
 * @param p_cso_attribute10 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE10}
 * @param p_cso_attribute11 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE11}
 * @param p_cso_attribute12 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE12}
 * @param p_cso_attribute13 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE13}
 * @param p_cso_attribute14 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE14}
 * @param p_cso_attribute15 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE15}
 * @param p_cso_attribute16 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE16}
 * @param p_cso_attribute17 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE17}
 * @param p_cso_attribute18 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE18}
 * @param p_cso_attribute19 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE19}
 * @param p_cso_attribute20 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE20}
 * @param p_cso_attribute21 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE21}
 * @param p_cso_attribute22 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE22}
 * @param p_cso_attribute23 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE23}
 * @param p_cso_attribute24 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE24}
 * @param p_cso_attribute25 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE25}
 * @param p_cso_attribute26 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE26}
 * @param p_cso_attribute27 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE27}
 * @param p_cso_attribute28 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE28}
 * @param p_cso_attribute29 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE29}
 * @param p_cso_attribute30 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE30}
 * @param p_cwb_stock_optn_dtls_id Identifier of the Compensation Workbench
 * Stock Option Detail record.
 * @param p_object_version_number Pass in the current version number of the
 * stock detail record to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated stock detail
 * record. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Create Compensation Workbench Stock Option
 * @rep:category BUSINESS_ENTITY BEN_CWB_3RD_PARTY_STOCK_OPTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cwb_stock_optn_dtls
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_grant_id                      in     number   default null
  ,p_grant_number                  in     varchar2 default null
  ,p_grant_name                    in     varchar2 default null
  ,p_grant_type			   in     varchar2 default null
  ,p_grant_date                    in     date     default null
  ,p_grant_shares                  in     number   default null
  ,p_grant_price                   in     number   default null
  ,p_value_at_grant                in     number   default null
  ,p_current_share_price	   in     number   default null
  ,p_current_shares_outstanding    in     number   default null
  ,p_vested_shares                 in     number   default null
  ,p_unvested_shares		   in     number   default null
  ,p_exercisable_shares            in     number   default null
  ,p_exercised_shares              in     number   default null
  ,p_cancelled_shares              in     number   default null
  ,p_trading_symbol                in     varchar2 default null
  ,p_expiration_date 		   in     date     default null
  ,p_reason_code 		   in     varchar2 default null
  ,p_class			   in     varchar2 default null
  ,p_misc			   in     varchar2 default null
  ,p_employee_number               in     varchar2 default null
  ,p_person_id			   in     number   default null
  ,p_business_group_id             in     number   default null
  ,p_prtt_rt_val_id                in     number   default null
  ,p_cso_attribute_category        in     varchar2 default null
  ,p_cso_attribute1                in     varchar2 default null
  ,p_cso_attribute2                in     varchar2 default null
  ,p_cso_attribute3                in     varchar2 default null
  ,p_cso_attribute4                in     varchar2 default null
  ,p_cso_attribute5                in     varchar2 default null
  ,p_cso_attribute6                in     varchar2 default null
  ,p_cso_attribute7                in     varchar2 default null
  ,p_cso_attribute8                in     varchar2 default null
  ,p_cso_attribute9                in     varchar2 default null
  ,p_cso_attribute10               in     varchar2 default null
  ,p_cso_attribute11               in     varchar2 default null
  ,p_cso_attribute12               in     varchar2 default null
  ,p_cso_attribute13               in     varchar2 default null
  ,p_cso_attribute14               in     varchar2 default null
  ,p_cso_attribute15               in     varchar2 default null
  ,p_cso_attribute16               in     varchar2 default null
  ,p_cso_attribute17               in     varchar2 default null
  ,p_cso_attribute18               in     varchar2 default null
  ,p_cso_attribute19               in     varchar2 default null
  ,p_cso_attribute20               in     varchar2 default null
  ,p_cso_attribute21               in     varchar2 default null
  ,p_cso_attribute22               in     varchar2 default null
  ,p_cso_attribute23               in     varchar2 default null
  ,p_cso_attribute24               in     varchar2 default null
  ,p_cso_attribute25               in     varchar2 default null
  ,p_cso_attribute26               in     varchar2 default null
  ,p_cso_attribute27               in     varchar2 default null
  ,p_cso_attribute28               in     varchar2 default null
  ,p_cso_attribute29               in     varchar2 default null
  ,p_cso_attribute30               in     varchar2 default null
  ,p_cwb_stock_optn_dtls_id           out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_cwb_stock_optn_dtls >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Compensation Workbench Stock Option Detail record.
 *
 * This updated record is shown in the extended stock option region of the
 * Compensation Workbench history pages.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Self-Service Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The stock option detail record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Stock Option Detail record is successfully
 * updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Compensation Workbench Stock Option Detail
 * record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cwb_stock_optn_dtls_id The identifier of the Compensation Workbench
 * Stock Option Detail record to update.
 * @param p_grant_id {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_ID}
 * @param p_grant_number {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_NUMBER}
 * @param p_grant_name {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_NAME}
 * @param p_grant_type {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_TYPE}
 * @param p_grant_date {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_DATE}
 * @param p_grant_shares {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_SHARES}
 * @param p_grant_price {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.GRANT_PRICE}
 * @param p_value_at_grant {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.VALUE_AT_GRANT}
 * @param p_current_share_price {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CURRENT_SHARE_PRICE}
 * @param p_current_shares_outstanding Number of current outstanding shares.
 * @param p_vested_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.VESTED_SHARES}
 * @param p_unvested_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.UNVESTED_SHARES}
 * @param p_exercisable_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EXERCISABLE_SHARES}
 * @param p_exercised_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EXERCISED_SHARES}
 * @param p_cancelled_shares {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CANCELLED_SHARES}
 * @param p_trading_symbol {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.TRADING_SYMBOL}
 * @param p_expiration_date {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EXPIRATION_DATE}
 * @param p_reason_code {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.REASON_CODE}
 * @param p_class {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.CLASS}
 * @param p_misc {@rep:casecolumn BEN_CWB_STOCK_OPTN_DTLS.MISC}
 * @param p_employee_number {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.EMPLOYEE_NUMBER}
 * @param p_person_id Specifies the person to whom the stock has been granted.
 * @param p_business_group_id Specifies the Business Group of the person.
 * @param p_prtt_rt_val_id {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.PRTT_RT_VAL_ID}
 * @param p_cso_attribute_category {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE_CATEGORY}
 * @param p_cso_attribute1 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE1}
 * @param p_cso_attribute2 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE2}
 * @param p_cso_attribute3 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE3}
 * @param p_cso_attribute4 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE4}
 * @param p_cso_attribute5 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE5}
 * @param p_cso_attribute6 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE6}
 * @param p_cso_attribute7 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE7}
 * @param p_cso_attribute8 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE8}
 * @param p_cso_attribute9 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE9}
 * @param p_cso_attribute10 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE10}
 * @param p_cso_attribute11 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE11}
 * @param p_cso_attribute12 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE12}
 * @param p_cso_attribute13 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE13}
 * @param p_cso_attribute14 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE14}
 * @param p_cso_attribute15 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE15}
 * @param p_cso_attribute16 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE16}
 * @param p_cso_attribute17 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE17}
 * @param p_cso_attribute18 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE18}
 * @param p_cso_attribute19 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE19}
 * @param p_cso_attribute20 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE20}
 * @param p_cso_attribute21 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE21}
 * @param p_cso_attribute22 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE22}
 * @param p_cso_attribute23 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE23}
 * @param p_cso_attribute24 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE24}
 * @param p_cso_attribute25 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE25}
 * @param p_cso_attribute26 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE26}
 * @param p_cso_attribute27 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE27}
 * @param p_cso_attribute28 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE28}
 * @param p_cso_attribute29 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE29}
 * @param p_cso_attribute30 {@rep:casecolumn
 * BEN_CWB_STOCK_OPTN_DTLS.CSO_ATTRIBUTE30}
 * @param p_object_version_number Pass in the current version number of the
 * stock detail record to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated stock detail
 * record. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Compensation Workbench Stock Option
 * @rep:category BUSINESS_ENTITY BEN_CWB_3RD_PARTY_STOCK_OPTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cwb_stock_optn_dtls
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_grant_id                      in     number   default hr_api.g_number
  ,p_grant_number                  in     varchar2 default hr_api.g_varchar2
  ,p_grant_name                    in     varchar2 default hr_api.g_varchar2
  ,p_grant_type			   in     varchar2 default hr_api.g_varchar2
  ,p_grant_date                    in     date     default hr_api.g_date
  ,p_grant_shares                  in     number   default hr_api.g_number
  ,p_grant_price                   in     number   default hr_api.g_number
  ,p_value_at_grant                in     number   default hr_api.g_number
  ,p_current_share_price	   in     number   default hr_api.g_number
  ,p_current_shares_outstanding    in     number   default hr_api.g_number
  ,p_vested_shares                 in     number   default hr_api.g_number
  ,p_unvested_shares		   in     number   default hr_api.g_number
  ,p_exercisable_shares            in     number   default hr_api.g_number
  ,p_exercised_shares              in     number   default hr_api.g_number
  ,p_cancelled_shares              in     number   default hr_api.g_number
  ,p_trading_symbol                in     varchar2 default hr_api.g_varchar2
  ,p_expiration_date 		   in     date     default hr_api.g_date
  ,p_reason_code 		   in     varchar2 default hr_api.g_varchar2
  ,p_class			   in     varchar2 default hr_api.g_varchar2
  ,p_misc			   in     varchar2 default hr_api.g_varchar2
  ,p_employee_number               in     varchar2 default hr_api.g_varchar2
  ,p_person_id			   in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_prtt_rt_val_id                in     number   default hr_api.g_number
  ,p_cso_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in  out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cwb_stock_optn_dtls >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Compensation Workbench Stock Option Detail record.
 *
 * This deleted record will not display in the extended stock option region of
 * Compensation Workbench History pages.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Self-Service Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The stock option detail record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Stock Option Detail record is successfully
 * deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Compensation Workbench Stock Option Detail
 * record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cwb_stock_optn_dtls_id Identifier of the Stock Option Detail record
 * to delete.
 * @param p_object_version_number Current version number of the stock detail
 * record to be deleted.
 * @rep:displayname Delete Compensation Workbench Stock Option
 * @rep:category BUSINESS_ENTITY BEN_CWB_3RD_PARTY_STOCK_OPTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cwb_stock_optn_dtls
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_cwb_stock_optn_dtls_id       Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_cwb_stock_optn_dtls_id       in number
   ,p_object_version_number        in number
  );
--
end BEN_CWB_STOCK_OPTN_DTLS_API;

 

/
