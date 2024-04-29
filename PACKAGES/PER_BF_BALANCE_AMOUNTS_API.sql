--------------------------------------------------------
--  DDL for Package PER_BF_BALANCE_AMOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_BALANCE_AMOUNTS_API" AUTHID CURRENT_USER AS
/* $Header: pebbaapi.pkh 120.1 2005/10/02 02:11:58 aroussel $ */
/*#
 * This package contains APIs that will maintain backfeed balance amounts.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Backfeed Balance Amount
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_balance_amount >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a set of balance amounts for a particular payroll run and
 * assignment.
 *
 * Initially, a check is made to see if a row exists in the table
 * PER_BF_PROCESSED_ASSIGNMENTS for the assignment and payroll run. If there
 * isn't a row, one is created otherwise the ID of the existing row is used for
 * the foreign key held in PER_BF_BALANCE_AMOUNTS.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Backfeed balance type must be created.
 *
 * <p><b>Post Success</b><br>
 * Information has successfully been inserted into the backfeed balance amount
 * table. A row will be added, if one doesn't already exist, in the backfeed
 * processed assignment.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed balance amount will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business Group for this balance amount.
 * @param p_balance_type_id {@rep:casecolumn
 * PER_BF_BALANCE_TYPES.BALANCE_TYPE_ID}
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_payroll_run_id {@rep:casecolumn PER_BF_PAYROLL_RUNS.PAYROLL_RUN_ID}
 * @param p_ytd_amount Year to Date balance.
 * @param p_fytd_amount Financial YTD balance.
 * @param p_ptd_amount Period To Date Amount
 * @param p_mtd_amount Month To Date Amount.
 * @param p_qtd_amount Quarter to Date Amount
 * @param p_run_amount Run Amount.
 * @param p_currency_code Currency code of the amounts if the balance type is
 * money.
 * @param p_bba_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bba_attribute1 Descriptive flexfield segment.
 * @param p_bba_attribute2 Descriptive flexfield segment.
 * @param p_bba_attribute3 Descriptive flexfield segment.
 * @param p_bba_attribute4 Descriptive flexfield segment.
 * @param p_bba_attribute5 Descriptive flexfield segment.
 * @param p_bba_attribute6 Descriptive flexfield segment.
 * @param p_bba_attribute7 Descriptive flexfield segment.
 * @param p_bba_attribute8 Descriptive flexfield segment.
 * @param p_bba_attribute9 Descriptive flexfield segment.
 * @param p_bba_attribute10 Descriptive flexfield segment.
 * @param p_bba_attribute11 Descriptive flexfield segment.
 * @param p_bba_attribute12 Descriptive flexfield segment.
 * @param p_bba_attribute13 Descriptive flexfield segment.
 * @param p_bba_attribute14 Descriptive flexfield segment.
 * @param p_bba_attribute15 Descriptive flexfield segment.
 * @param p_bba_attribute16 Descriptive flexfield segment.
 * @param p_bba_attribute17 Descriptive flexfield segment.
 * @param p_bba_attribute18 Descriptive flexfield segment.
 * @param p_bba_attribute19 Descriptive flexfield segment.
 * @param p_bba_attribute20 Descriptive flexfield segment.
 * @param p_bba_attribute21 Descriptive flexfield segment.
 * @param p_bba_attribute22 Descriptive flexfield segment.
 * @param p_bba_attribute23 Descriptive flexfield segment.
 * @param p_bba_attribute24 Descriptive flexfield segment.
 * @param p_bba_attribute25 Descriptive flexfield segment.
 * @param p_bba_attribute26 Descriptive flexfield segment.
 * @param p_bba_attribute27 Descriptive flexfield segment.
 * @param p_bba_attribute28 Descriptive flexfield segment.
 * @param p_bba_attribute29 Descriptive flexfield segment.
 * @param p_bba_attribute30 Descriptive flexfield segment.
 * @param p_processed_assignment_id {@rep:casecolumn
 * PER_BF_PROCESSED_ASSIGNMENTS.PROCESSED_ASSIGNMENT_ID}
 * @param p_processed_assignment_ovn {@rep:casecolumn
 * PER_BF_PROCESSED_ASSIGNMENTS.OBJECT_VERSION_NUMBER}
 * @param p_balance_amount_id If p_validate is false, then this uniquely
 * identifies the backfeed balance amount created. If p_validate is true, then
 * set to null.
 * @param p_balance_amount_ovn If p_validate is false, then set to the version
 * number of the backfeed balance amount. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Backfeed Balance Amount
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_balance_amount
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_business_group_id             in     number
,p_balance_type_id               in     number
,p_assignment_id                 in     number
,p_payroll_run_id                in     number
,p_ytd_amount                    in     number   default null
,p_fytd_amount                   in     number   default null
,p_ptd_amount                    in     number   default null
,p_mtd_amount                    in     number   default null
,p_qtd_amount                    in     number   default null
,p_run_amount                    in     number   default null
,p_currency_code                 in     varchar2 default null
,p_bba_attribute_category        in     varchar2 default null
,p_bba_attribute1                in     varchar2 default null
,p_bba_attribute2                in     varchar2 default null
,p_bba_attribute3                in     varchar2 default null
,p_bba_attribute4                in     varchar2 default null
,p_bba_attribute5                in     varchar2 default null
,p_bba_attribute6                in     varchar2 default null
,p_bba_attribute7                in     varchar2 default null
,p_bba_attribute8                in     varchar2 default null
,p_bba_attribute9                in     varchar2 default null
,p_bba_attribute10               in     varchar2 default null
,p_bba_attribute11               in     varchar2 default null
,p_bba_attribute12               in     varchar2 default null
,p_bba_attribute13               in     varchar2 default null
,p_bba_attribute14               in     varchar2 default null
,p_bba_attribute15               in     varchar2 default null
,p_bba_attribute16               in     varchar2 default null
,p_bba_attribute17               in     varchar2 default null
,p_bba_attribute18               in     varchar2 default null
,p_bba_attribute19               in     varchar2 default null
,p_bba_attribute20               in     varchar2 default null
,p_bba_attribute21               in     varchar2 default null
,p_bba_attribute22               in     varchar2 default null
,p_bba_attribute23               in     varchar2 default null
,p_bba_attribute24               in     varchar2 default null
,p_bba_attribute25               in     varchar2 default null
,p_bba_attribute26               in     varchar2 default null
,p_bba_attribute27               in     varchar2 default null
,p_bba_attribute28               in     varchar2 default null
,p_bba_attribute29               in     varchar2 default null
,p_bba_attribute30               in     varchar2 default null
,p_processed_assignment_id          out nocopy number
,p_processed_assignment_ovn         out nocopy number
,p_balance_amount_id                out nocopy number
,p_balance_amount_ovn               out nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_balance_amount >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a set of balance amounts for a particular payroll run and
 * assignment.
 *
 * This API updates balance amounts which have been processed in a third party
 * payroll application within the backfeed tables.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Balance amount been updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed balance amount will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed balance amount will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_ytd_amount Year to Date balance.
 * @param p_fytd_amount Financial YTD balance.
 * @param p_ptd_amount Period To Date Amount
 * @param p_mtd_amount Month To Date Amount.
 * @param p_qtd_amount Quarter to Date Amount
 * @param p_run_amount Run Amount.
 * @param p_currency_code Currency code of the amounts if the balance type is
 * money.
 * @param p_bba_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bba_attribute1 Descriptive flexfield segment.
 * @param p_bba_attribute2 Descriptive flexfield segment.
 * @param p_bba_attribute3 Descriptive flexfield segment.
 * @param p_bba_attribute4 Descriptive flexfield segment.
 * @param p_bba_attribute5 Descriptive flexfield segment.
 * @param p_bba_attribute6 Descriptive flexfield segment.
 * @param p_bba_attribute7 Descriptive flexfield segment.
 * @param p_bba_attribute8 Descriptive flexfield segment.
 * @param p_bba_attribute9 Descriptive flexfield segment.
 * @param p_bba_attribute10 Descriptive flexfield segment.
 * @param p_bba_attribute11 Descriptive flexfield segment.
 * @param p_bba_attribute12 Descriptive flexfield segment.
 * @param p_bba_attribute13 Descriptive flexfield segment.
 * @param p_bba_attribute14 Descriptive flexfield segment.
 * @param p_bba_attribute15 Descriptive flexfield segment.
 * @param p_bba_attribute16 Descriptive flexfield segment.
 * @param p_bba_attribute17 Descriptive flexfield segment.
 * @param p_bba_attribute18 Descriptive flexfield segment.
 * @param p_bba_attribute19 Descriptive flexfield segment.
 * @param p_bba_attribute20 Descriptive flexfield segment.
 * @param p_bba_attribute21 Descriptive flexfield segment.
 * @param p_bba_attribute22 Descriptive flexfield segment.
 * @param p_bba_attribute23 Descriptive flexfield segment.
 * @param p_bba_attribute24 Descriptive flexfield segment.
 * @param p_bba_attribute25 Descriptive flexfield segment.
 * @param p_bba_attribute26 Descriptive flexfield segment.
 * @param p_bba_attribute27 Descriptive flexfield segment.
 * @param p_bba_attribute28 Descriptive flexfield segment.
 * @param p_bba_attribute29 Descriptive flexfield segment.
 * @param p_bba_attribute30 Descriptive flexfield segment.
 * @param p_balance_amount_id Uniquely identifies the backfeed balance amount
 * to update.
 * @param p_balance_amount_ovn Pass in the current version number of the
 * backfeed balance amount to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated backfeed
 * balance amount. If p_validate is true will be set to the same value which
 * was passed in.
 * @rep:displayname Update Backfeed Balance Amount
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_balance_amount
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_ytd_amount                    in     number   default hr_api.g_number
,p_fytd_amount                   in     number   default hr_api.g_number
,p_ptd_amount                    in     number   default hr_api.g_number
,p_mtd_amount                    in     number   default hr_api.g_number
,p_qtd_amount                    in     number   default hr_api.g_number
,p_run_amount                    in     number   default hr_api.g_number
,p_currency_code                 in     varchar2 default hr_api.g_varchar2
,p_bba_attribute_category        in     varchar2 default hr_api.g_varchar2
,p_bba_attribute1                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute2                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute3                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute4                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute5                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute6                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute7                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute8                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute9                in     varchar2 default hr_api.g_varchar2
,p_bba_attribute10               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute11               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute12               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute13               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute14               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute15               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute16               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute17               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute18               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute19               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute20               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute21               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute22               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute23               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute24               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute25               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute26               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute27               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute28               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute29               in     varchar2 default hr_api.g_varchar2
,p_bba_attribute30               in     varchar2 default hr_api.g_varchar2
,p_balance_amount_id             in     number
,p_balance_amount_ovn            in out nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_balance_amount >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a set of balance amounts for a particular payroll run and
 * assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Balance amount been deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed balance amount will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed balance amount will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_amount_id Uniquely identifies the backfeed balance amount
 * to delete.
 * @param p_balance_amount_ovn Current version number of the backfeed balance
 * amount to be deleted.
 * @rep:displayname Delete Backfeed Balance Amount
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_balance_amount
(p_validate                      in     boolean  default false
,p_balance_amount_id             in number
,p_balance_amount_ovn            in number
);
--
end PER_BF_BALANCE_AMOUNTS_API;

 

/
