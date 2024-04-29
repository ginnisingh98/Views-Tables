--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: becpgapi.pkh 120.2.12000000.1 2007/01/19 02:23:44 appldev noship $ */
/*#
 * This package contains Compensation Workbench Budget APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Compensation Workbench Budget Detail
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_group_budget >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates budgeting details for compensation workbench processing.
 *
 * This API creates budgeting records (budget details) and refers to budget
 * plan. Each record here refers to a budget plan. There will a plan record and
 * multiple option records. Rate values stored here are in budget plan
 * currency. Compensation Workbench self-service pages refer and update budget
 * information using this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A budget rate should be defined for the Compensation Workbench Plan.
 *
 * <p><b>Post Success</b><br>
 * The budget detail will be inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The budget detail will not be inserted in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Life Event Reason
 * ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER..
 * @param p_group_pl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_PL_ID}
 * @param p_group_oipl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_OIPL_ID}
 * @param p_lf_evt_ocrd_dt This parameter specifies the date on which the life
 * event occurred.
 * @param p_bdgt_pop_cd This parameter specifies the budget population code.
 * Valid values are defined by the 'BEN_CWB_EMP_POP' lookup type.
 * @param p_due_dt This parameter specifies the due date.
 * @param p_access_cd This parameter specifies the access code for manager.
 * Valid values are defined by 'BEN_CWB_TASK_ACCESS' lookup type.
 * @param p_approval_cd This parameter specifies the approval code. Valid
 * values are defined by 'BEN_APPR_STAT' lookup type.
 * @param p_approval_date This parameter specifies the date of approval.
 * @param p_approval_comments This parameter specifies the manager comments on
 * approval.
 * @param p_dist_bdgt_val This parameter specifies the value of budget to be
 * distributed.
 * @param p_ws_bdgt_val This parameter specifies the budget value on worksheet.
 * @param p_rsrv_val This parameter specifies the budget reserve value.
 * @param p_dist_bdgt_mn_val This parameter specifies the distribution budget
 * minimum value.
 * @param p_dist_bdgt_mx_val This parameter specifies the distribution budget
 * maximum value.
 * @param p_dist_bdgt_incr_val This parameter specifies the distribution budget
 * increment value.
 * @param p_ws_bdgt_mn_val This parameter specifies the worksheet budget
 * minimum value.
 * @param p_ws_bdgt_mx_val This parameter specifies the worksheet budget
 * maximum value.
 * @param p_ws_bdgt_incr_val This parameter specifies the worksheet budget
 * increment value.
 * @param p_rsrv_mn_val This parameter specifies the reserve minimum value.
 * @param p_rsrv_mx_val This parameter specifies the reserve maximum value.
 * @param p_rsrv_incr_val This parameter specifies the reserve increment value.
 * @param p_dist_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_VAL}
 * @param p_ws_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_VAL}
 * @param p_dist_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_DATE}
 * @param p_ws_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_DATE}
 * @param p_ws_bdgt_val_last_upd_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_VAL_LAST_UPD_DATE}
 * @param p_dist_bdgt_val_last_upd_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_VAL_LAST_UPD_DATE}
 * @param p_rsrv_val_last_upd_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.RSRV_VAL_LAST_UPD_DATE}
 * @param p_ws_bdgt_val_last_upd_by {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_VAL_LAST_UPD_BY}
 * @param p_dist_bdgt_val_last_upd_by {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_VAL_LAST_UPD_BY}
 * @param p_rsrv_val_last_upd_by {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.RSRV_VAL_LAST_UPD_BY}
 * @param p_submit_cd This parameter specifies the allocation submission code
 * to indicate if the manager has submitted work for approval. Valid values are
 * defined from the 'BEN_SUBMIT_STAT' lookup type.
 * @param p_submit_date This parameter specifies the allocation submission
 * date.
 * @param p_submit_comments This parameter specifies the submission comments.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Compensation Workbench Budget. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Group Budget
 * @rep:category BUSINESS_ENTITY BEN_CWB_BUDGET
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_group_budget
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_bdgt_pop_cd                   in     varchar2   default null
  ,p_due_dt                        in     date       default null
  ,p_access_cd                     in     varchar2   default null
  ,p_approval_cd                   in     varchar2   default null
  ,p_approval_date                 in     date       default null
  ,p_approval_comments             in     varchar2   default null
  ,p_dist_bdgt_val                 in     number     default null
  ,p_ws_bdgt_val                   in     number     default null
  ,p_rsrv_val                      in     number     default null
  ,p_dist_bdgt_mn_val              in     number     default null
  ,p_dist_bdgt_mx_val              in     number     default null
  ,p_dist_bdgt_incr_val            in     number     default null
  ,p_ws_bdgt_mn_val                in     number     default null
  ,p_ws_bdgt_mx_val                in     number     default null
  ,p_ws_bdgt_incr_val              in     number     default null
  ,p_rsrv_mn_val                   in     number     default null
  ,p_rsrv_mx_val                   in     number     default null
  ,p_rsrv_incr_val                 in     number     default null
  ,p_dist_bdgt_iss_val             in     number     default null
  ,p_ws_bdgt_iss_val               in     number     default null
  ,p_dist_bdgt_iss_date            in     date       default null
  ,p_ws_bdgt_iss_date              in     date       default null
  ,p_ws_bdgt_val_last_upd_date     in     date       default null
  ,p_dist_bdgt_val_last_upd_date   in     date       default null
  ,p_rsrv_val_last_upd_date        in     date       default null
  ,p_ws_bdgt_val_last_upd_by       in     number     default null
  ,p_dist_bdgt_val_last_upd_by     in     number     default null
  ,p_rsrv_val_last_upd_by          in     number     default null
  ,p_submit_cd                     in     varchar2   default null
  ,p_submit_date                   in     date       default null
  ,p_submit_comments               in     varchar2   default null
  ,p_object_version_number            out nocopy     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_group_budget >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates budgeting details for compensation workbench processing.
 *
 * This API updates budgeting records (budget details) and refers to budget
 * plan. Each record here refers to a budget plan. There will be a plan record
 * and multiple option records. Rate values stored here are in budget plan
 * currency. Compensation Workbench self-service pages refer and update budget
 * information using this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Budget to update in the database must exist.
 *
 * <p><b>Post Success</b><br>
 * The budget detail will be updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The budget detail will not be updated in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Life Event Reason
 * ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_group_pl_id This parameter specifies the Compensation Workbench
 * Group Plan ID.
 * @param p_group_oipl_id This parameter specifies the Compensation Workbench
 * Group Options ID.
 * @param p_lf_evt_ocrd_dt This parameter specifies the date on which the life
 * event occurred.
 * @param p_bdgt_pop_cd This parameter specifies the Budget Population Code.
 * Valid values are defined from 'BEN_CWB_EMP_POP' lookup.
 * @param p_due_dt This parameter specifies the Due Date.
 * @param p_access_cd This parameter specifies the access code for manager.
 * Valid values are defined by 'BEN_CWB_TASK_ACCESS' lookup type.
 * @param p_approval_cd This parameter specifies the approval code. Valid
 * values are defined by 'BEN_APPR_STAT' lookup type.
 * @param p_approval_date This parameter specifies the date of approval of
 * allocations.
 * @param p_approval_comments This parameter specifies the manager's comments
 * on the approval.
 * @param p_dist_bdgt_val This parameter specifies the value of budget to be
 * distributed.
 * @param p_ws_bdgt_val This parameter specifies the budget value on worksheet.
 * @param p_rsrv_val This parameter specifies the budget reserve value.
 * @param p_dist_bdgt_mn_val This parameter specifies the distribution budget
 * minimum value.
 * @param p_dist_bdgt_mx_val This parameter specifies the sistribution budget
 * maximum value.
 * @param p_dist_bdgt_incr_val This parameter specifies the distribution budget
 * increment value.
 * @param p_ws_bdgt_mn_val This parameter specifies the worksheet budget
 * minimum value.
 * @param p_ws_bdgt_mx_val This parameter specifies the worksheet budget
 * maximum value.
 * @param p_ws_bdgt_incr_val This parameter specifies the worksheet budget
 * increment value.
 * @param p_rsrv_mn_val This parameter specifies the reserve budget minimum
 * value.
 * @param p_rsrv_mx_val This parameter specifies the reserve budget maximum
 * value.
 * @param p_rsrv_incr_val This parameter specifies the reserve budget increment
 * value.
 * @param p_dist_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_VAL}
 * @param p_ws_bdgt_iss_val {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_VAL}
 * @param p_dist_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_ISS_DATE}
 * @param p_ws_bdgt_iss_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_ISS_DATE}
 * @param p_ws_bdgt_val_last_upd_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_VAL_LAST_UPD_DATE}
 * @param p_dist_bdgt_val_last_upd_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_VAL_LAST_UPD_DATE}
 * @param p_rsrv_val_last_upd_date {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.RSRV_VAL_LAST_UPD_DATE}
 * @param p_ws_bdgt_val_last_upd_by {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.WS_BDGT_VAL_LAST_UPD_BY}
 * @param p_dist_bdgt_val_last_upd_by {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.DIST_BDGT_VAL_LAST_UPD_BY}
 * @param p_rsrv_val_last_upd_by {@rep:casecolumn
 * BEN_CWB_PERSON_GROUPS.RSRV_VAL_LAST_UPD_BY}
 * @param p_submit_cd This parameter specifies the allocation submission code
 * to indicate if the manager has submitted work for approval. Valid values are
 * defined from 'BEN_SUBMIT_STAT' lookup type.
 * @param p_submit_date This parameter specifies the allocation submission
 * date.
 * @param p_submit_comments This parameter specifies the submission comments.
 * @param p_perf_min_max_edit This parameter specifies the flag to check edits
 * for value between minimum and maximum.
 * @param p_object_version_number Pass in the current version number of the
 * Compensation Workbench Budget to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Compensation Workbench Budget. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Group Budget
 * @rep:category BUSINESS_ENTITY BEN_CWB_BUDGET
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_group_budget
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_lf_evt_ocrd_dt                in     date       default hr_api.g_date
  ,p_bdgt_pop_cd                   in     varchar2   default hr_api.g_varchar2
  ,p_due_dt                        in     date       default hr_api.g_date
  ,p_access_cd                     in     varchar2   default hr_api.g_varchar2
  ,p_approval_cd                   in     varchar2   default hr_api.g_varchar2
  ,p_approval_date                 in     date       default hr_api.g_date
  ,p_approval_comments             in     varchar2   default hr_api.g_varchar2
  ,p_dist_bdgt_val                 in     number     default hr_api.g_number
  ,p_ws_bdgt_val                   in     number     default hr_api.g_number
  ,p_rsrv_val                      in     number     default hr_api.g_number
  ,p_dist_bdgt_mn_val              in     number     default hr_api.g_number
  ,p_dist_bdgt_mx_val              in     number     default hr_api.g_number
  ,p_dist_bdgt_incr_val            in     number     default hr_api.g_number
  ,p_ws_bdgt_mn_val                in     number     default hr_api.g_number
  ,p_ws_bdgt_mx_val                in     number     default hr_api.g_number
  ,p_ws_bdgt_incr_val              in     number     default hr_api.g_number
  ,p_rsrv_mn_val                   in     number     default hr_api.g_number
  ,p_rsrv_mx_val                   in     number     default hr_api.g_number
  ,p_rsrv_incr_val                 in     number     default hr_api.g_number
  ,p_dist_bdgt_iss_val             in     number     default hr_api.g_number
  ,p_ws_bdgt_iss_val               in     number     default hr_api.g_number
  ,p_dist_bdgt_iss_date            in     date       default hr_api.g_date
  ,p_ws_bdgt_iss_date              in     date       default hr_api.g_date
  ,p_ws_bdgt_val_last_upd_date     in     date       default hr_api.g_date
  ,p_dist_bdgt_val_last_upd_date   in     date       default hr_api.g_date
  ,p_rsrv_val_last_upd_date        in     date       default hr_api.g_date
  ,p_ws_bdgt_val_last_upd_by       in     number     default hr_api.g_number
  ,p_dist_bdgt_val_last_upd_by     in     number     default hr_api.g_number
  ,p_rsrv_val_last_upd_by          in     number     default hr_api.g_number
  ,p_submit_cd                     in     varchar2   default hr_api.g_varchar2
  ,p_submit_date                   in     date       default hr_api.g_date
  ,p_submit_comments               in     varchar2   default hr_api.g_varchar2
  ,p_perf_min_max_edit             in     varchar2   default 'Y'
  ,p_object_version_number         in out nocopy     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_group_budget >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes budgeting details for compensation workbench processing.
 *
 * This API deletes budgeting records (budget details). Each record here refers
 * to a budget plan. Compensation Workbench self-service pages refer and delete
 * budget information using this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Budget to delete exists in the database.
 *
 * <p><b>Post Success</b><br>
 * The budget detail will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The budget detail will not be deleted from the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Life Event Reason
 * ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_group_pl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_PL_ID}
 * @param p_group_oipl_id {@rep:casecolumn BEN_CWB_PL_DSGN.GROUP_OIPL_ID}
 * @param p_object_version_number Pass in the current version number of the
 * @param p_update_summary Pass true to update summary reflecting the delete.
 * Compensation Workbench Budget to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Compensation Workbench Budget. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Delete Group Budget
 * @rep:category BUSINESS_ENTITY BEN_CWB_BUDGET
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_group_budget
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_object_version_number         in out nocopy   number
  ,p_update_summary                in     boolean default false
  );
end BEN_CWB_PERSON_GROUPS_API;

 

/