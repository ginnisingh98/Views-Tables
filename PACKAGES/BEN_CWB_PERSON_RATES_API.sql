--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_RATES_API" AUTHID CURRENT_USER as
/* $Header: bertsapi.pkh 120.3.12000000.1 2007/01/19 23:09:27 appldev noship $ */
/*#
 * This package contains Compensation Workbench Person Award APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Compensation Workbench Person Award
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_person_rate >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates award details for eligible persons for compensation
 * workbench processing.
 *
 * Award records are created for all eligible persons in a plan. Monetary
 * amounts are stored in plan currency. All compensation workbench self-service
 * pages, which refer to individual rates, use this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person with a compensation life event reason in a Compensation Workbench
 * Plan must exist.
 *
 * <p><b>Post Success</b><br>
 * A Compensation Workbench Award for a person is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A Compensation Workbench Award for a person is not created in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id Identifies the Group Life Event Reason ID of
 * Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_pl_id Specifies the Compensation Workbench Plan.
 * @param p_oipl_id Specifies options for Compensation Workbench Plan.
 * @param p_group_pl_id Specifies Compensation Workbench Group Plan.
 * @param p_group_oipl_id Specifies options for a Compensation Workbench Group
 * Plan.
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_CWB_PL_DSGN.LF_EVT_OCRD_DT}
 * @param p_person_id Identifies the person for whom you create the
 * Compensation Workbench Award record.
 * @param p_assignment_id Identifies the assignment for which is the
 * Compensation Workbench Award
 * @param p_elig_flag Eligibility flag for person. A person can be made
 * ineligible for award from self-service pages.
 * @param p_ws_val Compensation amount.
 * @param p_ws_mn_val Worksheet minimum value for minimum maximum edits.
 * @param p_ws_mx_val Worksheet maximum value for minimum maximum edits.
 * @param p_ws_incr_val Worksheet increment value for compensation.
 * @param p_elig_sal_val Eligible salary.
 * @param p_stat_sal_val Stated salary.
 * @param p_oth_comp_val Other compensation amount.
 * @param p_tot_comp_val Total compensation.
 * @param p_misc1_val Miscellaneous compensation 1 value.
 * @param p_misc2_val Miscellaneous compensation 2 value.
 * @param p_misc3_val Miscellaneous compensation 3 value.
 * @param p_rec_val Recommended Value.
 * @param p_rec_mn_val Recommended minimum value.
 * @param p_rec_mx_val Recommended maximum value.
 * @param p_rec_incr_val Recommended value increment.
 * @param p_ws_val_last_upd_date Last update date of worksheet amount.
 * @param p_ws_val_last_upd_by Specifies the person who made the last update of
 * worksheet amount.
 * @param p_pay_proposal_id Pay proposal. Foreign key to PER_PAY_PROPOSALS.
 * @param p_element_entry_value_id Element entry value. Foreign key to
 * PAY_ELEMENT_ENTRY_VALUES_F.
 * @param p_inelig_rsn_cd Ineligibility reason code. Valid values are defined
 * in 'BEN_INELG_RSN' lookup type.
 * @param p_elig_ovrid_dt Eligibility override date.
 * @param p_elig_ovrid_person_id Specifies person making eligibility override.
 * @param p_copy_dist_bdgt_val Value of budget to be distributed.
 * @param p_copy_ws_bdgt_val Budget value on worksheet.
 * @param p_copy_rsrv_val Budget reserve value.
 * @param p_copy_dist_bdgt_mn_val Distribution budget minimum value.
 * @param p_copy_dist_bdgt_mx_val Distribution budget maximum value.
 * @param p_copy_dist_bdgt_incr_val Distribution budget increment value.
 * @param p_copy_ws_bdgt_mn_val Worksheet budget minimum value.
 * @param p_copy_ws_bdgt_mx_val Worksheet budget maximum value.
 * @param p_copy_ws_bdgt_incr_val Worksheet budget increment value.
 * @param p_copy_rsrv_mn_val Reserve minimum value.
 * @param p_copy_rsrv_mx_val Reserve maximum value.
 * @param p_copy_rsrv_incr_val Reserve increment value.
 * @param p_copy_dist_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_VAL}
 * @param p_copy_ws_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_VAL}
 * @param p_copy_dist_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_DATE}
 * @param p_copy_ws_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_DATE}
 * @param p_comp_posting_date Date when Compensation Workbench Award was
 * posted.
 * @param p_ws_rt_start_date Worksheet rate start date.
 * @param p_currency Currency of monetary items.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Compensation Workbench Award. If p_validate is
 * true, then the value will be null.
 * @param p_person_rate_id If p_validate is false, then this uniquely
 * identifies the award created. If p_validate is true, then set to null.
 * @rep:displayname Create Person Award
 * @rep:category BUSINESS_ENTITY BEN_CWB_AWARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_rate
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_person_id                     in     number   default null
  ,p_assignment_id                 in     number   default null
  ,p_elig_flag                     in     varchar2 default null
  ,p_ws_val                        in     number   default null
  ,p_ws_mn_val                     in     number   default null
  ,p_ws_mx_val                     in     number   default null
  ,p_ws_incr_val                   in     number   default null
  ,p_elig_sal_val                  in     number   default null
  ,p_stat_sal_val                  in     number   default null
  ,p_oth_comp_val                  in     number   default null
  ,p_tot_comp_val                  in     number   default null
  ,p_misc1_val                     in     number   default null
  ,p_misc2_val                     in     number   default null
  ,p_misc3_val                     in     number   default null
  ,p_rec_val                       in     number   default null
  ,p_rec_mn_val                    in     number   default null
  ,p_rec_mx_val                    in     number   default null
  ,p_rec_incr_val                  in     number   default null
  ,p_ws_val_last_upd_date          in     date     default null
  ,p_ws_val_last_upd_by            in     number   default null
  ,p_pay_proposal_id               in     number   default null
  ,p_element_entry_value_id        in     number   default null
  ,p_inelig_rsn_cd                 in     varchar2 default null
  ,p_elig_ovrid_dt                 in     date     default null
  ,p_elig_ovrid_person_id          in     number   default null
  ,p_copy_dist_bdgt_val            in     number   default null
  ,p_copy_ws_bdgt_val              in     number   default null
  ,p_copy_rsrv_val                 in     number   default null
  ,p_copy_dist_bdgt_mn_val         in     number   default null
  ,p_copy_dist_bdgt_mx_val         in     number   default null
  ,p_copy_dist_bdgt_incr_val       in     number   default null
  ,p_copy_ws_bdgt_mn_val           in     number   default null
  ,p_copy_ws_bdgt_mx_val           in     number   default null
  ,p_copy_ws_bdgt_incr_val         in     number   default null
  ,p_copy_rsrv_mn_val              in     number   default null
  ,p_copy_rsrv_mx_val              in     number   default null
  ,p_copy_rsrv_incr_val            in     number   default null
  ,p_copy_dist_bdgt_iss_val        in     number   default null
  ,p_copy_ws_bdgt_iss_val          in     number   default null
  ,p_copy_dist_bdgt_iss_date       in     date     default null
  ,p_copy_ws_bdgt_iss_date         in     date     default null
  ,p_comp_posting_date             in     date     default null
  ,p_ws_rt_start_date              in     date     default null
  ,p_currency                      in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_person_rate_id                   out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_person_rate >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates award details for eligible persons for compensation
 * workbench processing.
 *
 * Award records is updated for all eligible persons in a plan. Monetary
 * amounts are stored in plan currency. All compensation workbench self-service
 * pages, which refer to individual rates, use this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Award to update must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Award for a person will be updated in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The Compensation Workbench Award for a person will not be updated in the
 * database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id Identifies the Group Life Event Reason ID of
 * Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_pl_id Specifies the Compensation Workbench Plan.
 * @param p_oipl_id Specifies options for Compensation Workbench Plan.
 * @param p_group_pl_id Specifies Compensation Workbench Group Plan.
 * @param p_group_oipl_id Specifies options for a Compensation Workbench Group
 * Plan.
 * @param p_lf_evt_ocrd_dt {@rep:casecolumn BEN_CWB_PL_DSGN.LF_EVT_OCRD_DT}
 * @param p_person_id Identifies the person for whom you create the
 * Compensation Workbench Award record.
 * @param p_assignment_id Identifies the assignment for which you create the
 * Compensation Workbench Award.
 * @param p_elig_flag Eligibility flag for person. A person can be made
 * ineligible for award from self-service pages.
 * @param p_ws_val Compensation amount.
 * @param p_ws_mn_val Worksheet minimum value for minimum maximum edits.
 * @param p_ws_mx_val Worksheet maximum value for minimum maximum edits.
 * @param p_ws_incr_val Worksheet increment value for compensation.
 * @param p_elig_sal_val Eligible salary.
 * @param p_stat_sal_val Stated salary.
 * @param p_oth_comp_val Other compensation amount.
 * @param p_tot_comp_val Total compensation.
 * @param p_misc1_val Miscellaneous compensation 1 value.
 * @param p_misc2_val Miscellaneous compensation 2 value.
 * @param p_misc3_val Miscellaneous compensation 3 value.
 * @param p_rec_val Recommended Value.
 * @param p_rec_mn_val Recommended minimum value.
 * @param p_rec_mx_val Recommended maximum value.
 * @param p_rec_incr_val Recommended value increment.
 * @param p_ws_val_last_upd_date Last update date of worksheet amount.
 * @param p_ws_val_last_upd_by Specifies the person who made last update of the
 * worksheet amount.
 * @param p_pay_proposal_id Pay proposal. Foreign key to PER_PAY_PROPOSALS.
 * @param p_element_entry_value_id Element entry value. Foreign key to
 * PAY_ELEMENT_ENTRY_VALUES_F.
 * @param p_inelig_rsn_cd Ineligibility reason code. Valid values are defined
 * in 'BEN_INELG_RSN' lookup type.
 * @param p_elig_ovrid_dt Eligibility override date.
 * @param p_elig_ovrid_person_id Specifies person making eligibility override.
 * @param p_copy_dist_bdgt_val Value of budget to be distributed.
 * @param p_copy_ws_bdgt_val Budget value on worksheet.
 * @param p_copy_rsrv_val Budget reserve value.
 * @param p_copy_dist_bdgt_mn_val Distribution budget minimum value.
 * @param p_copy_dist_bdgt_mx_val Distribution budget maximum value.
 * @param p_copy_dist_bdgt_incr_val Distribution budget increment value.
 * @param p_copy_ws_bdgt_mn_val Worksheet budget minimum value.
 * @param p_copy_ws_bdgt_mx_val Worksheet budget maximum value.
 * @param p_copy_ws_bdgt_incr_val Worksheet budget increment value.
 * @param p_copy_rsrv_mn_val Reserve minimum value.
 * @param p_copy_rsrv_mx_val Reserve maximum value.
 * @param p_copy_rsrv_incr_val Reserve increment value.
 * @param p_copy_dist_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_VAL}
 * @param p_copy_ws_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_VAL}
 * @param p_copy_dist_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_DATE}
 * @param p_copy_ws_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_DATE}
 * @param p_comp_posting_date Date when Compensation Workbench Award posted.
 * @param p_ws_rt_start_date Worksheet rate start date.
 * @param p_currency Currency of monetary items.
 * @param p_perf_min_max_edit Flag to check edits for value between minimum and
 * maximum.
 * @param p_object_version_number Pass in the current version number of the
 * Compensation Workbench Award to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Compensation Workbench Award. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Person Award
 * @rep:category BUSINESS_ENTITY BEN_CWB_AWARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_rate
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_group_pl_id                   in     number   default hr_api.g_number
  ,p_group_oipl_id                 in     number   default hr_api.g_number
  ,p_lf_evt_ocrd_dt                in     date     default hr_api.g_date
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_elig_flag                     in     varchar2 default hr_api.g_varchar2
  ,p_ws_val                        in     number   default hr_api.g_number
  ,p_ws_mn_val                     in     number   default hr_api.g_number
  ,p_ws_mx_val                     in     number   default hr_api.g_number
  ,p_ws_incr_val                   in     number   default hr_api.g_number
  ,p_elig_sal_val                  in     number   default hr_api.g_number
  ,p_stat_sal_val                  in     number   default hr_api.g_number
  ,p_oth_comp_val                  in     number   default hr_api.g_number
  ,p_tot_comp_val                  in     number   default hr_api.g_number
  ,p_misc1_val                     in     number   default hr_api.g_number
  ,p_misc2_val                     in     number   default hr_api.g_number
  ,p_misc3_val                     in     number   default hr_api.g_number
  ,p_rec_val                       in     number   default hr_api.g_number
  ,p_rec_mn_val                    in     number   default hr_api.g_number
  ,p_rec_mx_val                    in     number   default hr_api.g_number
  ,p_rec_incr_val                  in     number   default hr_api.g_number
  ,p_ws_val_last_upd_date          in     date     default hr_api.g_date
  ,p_ws_val_last_upd_by            in     number   default hr_api.g_number
  ,p_pay_proposal_id               in     number   default hr_api.g_number
  ,p_element_entry_value_id        in     number   default hr_api.g_number
  ,p_inelig_rsn_cd                 in     varchar2 default hr_api.g_varchar2
  ,p_elig_ovrid_dt                 in     date     default hr_api.g_date
  ,p_elig_ovrid_person_id          in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_val            in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_val              in     number   default hr_api.g_number
  ,p_copy_rsrv_val                 in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_mn_val         in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_mx_val         in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_incr_val       in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_mn_val           in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_mx_val           in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_incr_val         in     number   default hr_api.g_number
  ,p_copy_rsrv_mn_val              in     number   default hr_api.g_number
  ,p_copy_rsrv_mx_val              in     number   default hr_api.g_number
  ,p_copy_rsrv_incr_val            in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_iss_val        in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_iss_val          in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_iss_date       in     date     default hr_api.g_date
  ,p_copy_ws_bdgt_iss_date         in     date     default hr_api.g_date
  ,p_comp_posting_date             in     date     default hr_api.g_date
  ,p_ws_rt_start_date              in     date     default hr_api.g_date
  ,p_currency                      in     varchar2 default hr_api.g_varchar2
  ,p_perf_min_max_edit             in     varchar2   default 'Y'
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_person_rate >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes award details for eligible persons for compensation
 * workbench processing.
 *
 * Award records is deleted for all eligible persons in a plan. All
 * compensation workbench self-service pages, which refer to individual rates
 * use this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Award to delete must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Award for a person will be deleted in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The Compensation Workbench Award for a person will not be deleted in the
 * database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id Identifies the Group Life Event Reason ID of
 * Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_pl_id Specifies the Compensation Workbench Plan.
 * @param p_oipl_id Specifies options for Compensation Workbench Plan.
 * @param p_object_version_number Current version number of the Compensation
 * @param p_update_summary Pass true to update summary reflecting the delete.
 * Workbench Award to be deleted.
 * @rep:displayname Delete Person Award
 * @rep:category BUSINESS_ENTITY BEN_CWB_AWARD
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_rate
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_object_version_number         in     number
  ,p_update_summary                in     boolean default false
  );
--
end BEN_CWB_PERSON_RATES_API;

 

/
