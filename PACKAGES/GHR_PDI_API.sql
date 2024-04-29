--------------------------------------------------------
--  DDL for Package GHR_PDI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDI_API" AUTHID CURRENT_USER AS
/*$Header: ghpdiapi.pkh 120.1 2005/10/02 01:58:16 aroussel $*/
/*#
 * This package contains the Position Description APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position Description
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_pdi >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Federal Position Description.
 *
 * This API creates the Position Description record in the
 * GHR_POSITION_DESCRIPTIONS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Routing Group ID is passed to the API.
 *
 * <p><b>Post Success</b><br>
 * Position Description record is created
 *
 * <p><b>Post Failure</b><br>
 * An application error is raised and processing is terminated
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_description_id If p_validate is false, then this uniquely
 * identifies the Position Description created. If p_validate is true, then set
 * to null.
 * @param p_date_from The date on which the Position Description becomes
 * effective
 * @param p_routing_grp_id {@rep:casecolumn
 * GHR_ROUTING_GROUPS.ROUTING_GROUP_ID}
 * @param p_date_to The date after which the Position Description no longer
 * effective
 * @param p_opm_cert_num Office of Personnel Management certification number
 * @param p_flsa FLSA Category. Valid Values are defined by
 * 'GHR_US_FLSA_CATEGORY' Lookup Type
 * @param p_financial_statement Financial Statement Required. Valid Values are
 * defined by 'GHR_US_FINANCIAL_STATEMENT' Lookup Type.
 * @param p_subject_to_ia_action Indicates whether the position is subject to
 * IA action. Valid Values are Y - Yes, N - No
 * @param p_position_status Position Status. Valid Values are defined by
 * 'GHR_US_POSITION_OCCUPIED' Lookup Type.
 * @param p_position_is Supervisory Status. Valid Values are defined by
 * 'GHR_US_SUPERVISORY_STATUS' Lookup Type.
 * @param p_position_sensitivity Position Sensitivity. Valid Values are defined
 * by 'GHR_US_POSN_SENSITIVITY' Lookup Type.
 * @param p_competitive_level {@rep:casecolumn
 * GHR_POSITION_DESCRIPTIONS.COMPETITIVE_LEVEL}
 * @param p_pd_remarks Remarks
 * @param p_position_class_std Position classification standards
 * @param p_category Category Code. Valid Values are A - Active, I - Inactive,
 * S - Standard, C - Cancelled
 * @param p_career_ladder Indicates whether the position is part of a career
 * ladder. Valid Values are Y - Yes, N - No.
 * @param p_supervisor_name Supervisor's name
 * @param p_supervisor_title Supervisor's title
 * @param p_supervisor_date Date of Supervisor's authorization
 * @param p_manager_name Manager's name
 * @param p_manager_title Manager's title
 * @param p_manager_date Date of Manager's authorization
 * @param p_classifier_name Classifier's name
 * @param p_classifier_title Classifier's title
 * @param p_classifier_date Date on Classifier's authorization
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_business_group_id Business Group of Record
 * @param p_1_approved_flag Position Description approved flag.
 * @param p_1_user_name_acted_on Application User Name
 * @param p_1_action_taken Action taken. Valid Values are AUTHORIZED, CANCELED,
 * CLASSIFIED, INITIATED, NOT_ROUTED, NO_ACTION, RECLASSIFIED, REOPENED,
 * REQUESTED, REVIEWED
 * @param p_2_user_name_routed_to Application User Name
 * @param p_2_groupbox_id {@rep:casecolumn GHR_GROUPBOXES.GROUPBOX_ID}
 * @param p_2_routing_list_id {@rep:casecolumn
 * GHR_ROUTING_LISTS.ROUTING_LIST_ID}
 * @param p_2_routing_seq_number {@rep:casecolumn
 * GHR_ROUTING_LIST_MEMBERS.SEQ_NUMBER}
 * @param p_1_pd_routing_history_id {@rep:casecolumn
 * GHR_PD_ROUTING_HISTORY.PD_ROUTING_HISTORY_ID}
 * @param p_1_pdh_object_version_number If p_validate is false, then sets the
 * version number of the created Position Description history. If p_validate is
 * true, then the value is null.
 * @param p_2_pdh_object_version_number If p_validate is false, then sets the
 * version number of the created Position Description history. If p_validate is
 * true, then the value is null.
 * @param p_2_pd_routing_history_id If p_validate is false, then this uniquely
 * identifies the Position Description Routing History created. If p_validate
 * is true, then set to null.
 * @param p_pdi_object_version_number If p_validate is false, then sets the
 * version number of the created Position Description. If p_validate is true,
 * then the value is null.
 * @rep:displayname Create Federal Position Description
 * @rep:category BUSINESS_ENTITY GHR_POSITION_DESCRIPTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_pdi(
	p_validate IN BOOLEAN default false,
	p_position_description_id OUT NOCOPY number,
	p_date_from IN date,
	p_routing_grp_id	   IN   number default null,
	p_date_to IN date default null,
	p_opm_cert_num IN ghr_position_descriptions.opm_cert_num%TYPE default null,
	p_flsa	IN	ghr_position_descriptions.flsa%TYPE default null,
	p_financial_statement IN ghr_position_descriptions.financial_statement%TYPE default null,
	p_subject_to_ia_action	IN  ghr_position_descriptions.subject_to_ia_action%TYPE default null,
	p_position_status IN ghr_position_descriptions.position_status%TYPE default null,
	p_position_is	IN ghr_position_descriptions.position_is%TYPE default null,
	p_position_sensitivity IN ghr_position_descriptions.position_sensitivity%TYPE default null,
	p_competitive_level IN ghr_position_descriptions.competitive_level%TYPE default null,
	p_pd_remarks	IN  ghr_position_descriptions.pd_remarks%TYPE default null,
	p_position_class_std IN ghr_position_descriptions.position_class_std%TYPE default null,
	p_category	IN ghr_position_descriptions.category%TYPE default null,
	p_career_ladder	IN ghr_position_descriptions.career_ladder%TYPE default null,
        p_supervisor_name         in varchar2       default hr_api.g_varchar2,
        p_supervisor_title        in varchar2       default hr_api.g_varchar2,
        p_supervisor_date         in date           default hr_api.g_date,
        p_manager_name		  in varchar2       default hr_api.g_varchar2,
        p_manager_title 	  in varchar2       default hr_api.g_varchar2,
        p_manager_date            in date           default hr_api.g_date,
        p_classifier_name	  in varchar2       default hr_api.g_varchar2,
        p_classifier_title 	  in varchar2       default hr_api.g_varchar2,
        p_classifier_date         in date           default hr_api.g_date,
	p_attribute_category      in      varchar2  default null,
	p_attribute1              in      varchar2  default null,
 	p_attribute2              in      varchar2  default null,
	p_attribute3              in      varchar2  default null,
 	p_attribute4              in      varchar2  default null,
 	p_attribute5              in      varchar2  default null,
 	p_attribute6              in      varchar2  default null,
 	p_attribute7              in      varchar2  default null,
 	p_attribute8              in      varchar2  default null,
 	p_attribute9              in      varchar2  default null,
 	p_attribute10             in      varchar2  default null,
 	p_attribute11             in      varchar2  default null,
 	p_attribute12             in      varchar2  default null,
 	p_attribute13             in      varchar2  default null,
 	p_attribute14             in      varchar2  default null,
 	p_attribute15             in      varchar2  default null,
 	p_attribute16             in      varchar2  default null,
 	p_attribute17             in      varchar2  default null,
 	p_attribute18             in      varchar2  default null,
 	p_attribute19             in      varchar2  default null,
 	p_attribute20             in      varchar2  default null,
 	p_business_group_id             in      number  default null,
        p_1_approved_flag		  in      varchar2  default null,
        p_1_user_name_acted_on	          in      varchar2  default null,
        p_1_action_taken                  in      varchar2  default null,
        p_2_user_name_routed_to           in      varchar2  default null,
        p_2_groupbox_id                   in      number    default null,
        p_2_routing_list_id               in      number    default null,
        p_2_routing_seq_number            in      number    default null,
        p_1_pd_routing_history_id         out nocopy     number,
        p_1_pdh_object_version_number     out nocopy     number,
        p_2_pdh_object_version_number     out nocopy     number,
        p_2_pd_routing_history_id         out nocopy     number,
	p_pdi_object_version_number out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< update_pdi >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Position Description.
 *
 * This API updates the Position Description record in the
 * GHR_POSITION_DESCRIPTIONS
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Position Description id needs to be passed.
 *
 * <p><b>Post Success</b><br>
 * Position Description record is updated.
 *
 * <p><b>Post Failure</b><br>
 * An application error is raised and processing is terminated
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_description_id Identifies the Position Description record
 * to be modified.
 * @param p_routing_grp_id {@rep:casecolumn
 * GHR_ROUTING_GROUPS.ROUTING_GROUP_ID}
 * @param p_date_from The date on which the Position Description becomes
 * effective.
 * @param p_date_to The date after which the Position Description is no longer
 * effective.
 * @param p_opm_cert_num Office of Personnel Management certification number.
 * @param p_flsa FLSA Category. Valid Values are defined by
 * 'GHR_US_FLSA_CATEGORY' Lookup Type
 * @param p_financial_statement Financial Statement Required. Valid Values are
 * defined by 'GHR_US_FINANCIAL_STATEMENT' Lookup Type.
 * @param p_subject_to_ia_action Indicates whether the position is subject to
 * IA action. Valid Values are Y - Yes, N - No.
 * @param p_position_status Position Status. Valid Values are defined by
 * 'GHR_US_POSITION_OCCUPIED' Lookup Type.
 * @param p_position_is Supervisory Status. Valid Values are defined by
 * 'GHR_US_SUPERVISORY_STATUS' Lookup Type.
 * @param p_position_sensitivity Position Sensitivity. Valid Values are defined
 * by 'GHR_US_POSN_SENSITIVITY' Lookup Type.
 * @param p_competitive_level {@rep:casecolumn
 * GHR_POSITION_DESCRIPTIONS.COMPETITIVE_LEVEL}
 * @param p_pd_remarks Remarks
 * @param p_position_class_std Position classification standards
 * @param p_category Category Code. Valid Values are A - Active, I - Inactive,
 * S - Standard, C - Cancelled
 * @param p_career_ladder Indicates whether the position is part of a career
 * ladder. Valid Values are Y - Yes, N - No
 * @param p_supervisor_name Supervisor's name
 * @param p_supervisor_title Supervisor's title
 * @param p_supervisor_date Date of Supervisor's authorization
 * @param p_manager_name Manager's name
 * @param p_manager_title Manager's title
 * @param p_manager_date Date of Manager's authorization
 * @param p_classifier_name Classifier's name
 * @param p_classifier_title Classifier's title
 * @param p_classifier_date Date on Classifier's authorization
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_business_group_id Business Group of Record
 * @param p_u_approved_flag Position Description approved flag.
 * @param p_u_user_name_acted_on Application User Name
 * @param p_u_action_taken Action taken. Valid Values are AUTHORIZED, CANCELED,
 * CLASSIFIED, INITIATED, NOT_ROUTED, NO_ACTION, RECLASSIFIED, REOPENED,
 * REQUESTED, REVIEWED
 * @param p_i_user_name_routed_to Application User Name
 * @param p_i_groupbox_id {@rep:casecolumn GHR_GROUPBOXES.GROUPBOX_ID}
 * @param p_i_routing_list_id {@rep:casecolumn
 * GHR_ROUTING_LISTS.ROUTING_LIST_ID}
 * @param p_i_routing_seq_number {@rep:casecolumn
 * GHR_ROUTING_LIST_MEMBERS.SEQ_NUMBER}
 * @param p_u_pdh_object_version_number Pass in the current version number of
 * the Position Description History that you are updating. When the API
 * completes, if p_validate is false, sets the new version number of the
 * updated Position Description History. If p_validate is true, sets the same
 * value passed in.
 * @param p_i_pd_routing_history_id {@rep:casecolumn
 * GHR_PD_ROUTING_HISTORY.PD_ROUTING_HISTORY_ID}
 * @param p_i_pdh_object_version_number If p_validate is false, then sets the
 * version number of the created Position Description History. If p_validate is
 * true, then the value is null.
 * @param p_o_pd_routing_history_id If p_validate is false, then this uniquely
 * identifies the Position Description Routing History created. If p_validate
 * is true, then set to null.
 * @param p_o_pdh_object_version_number If p_validate is false, then sets the
 * version number of the created Position Description History. If p_validate is
 * true, then the value is null.
 * @param p_pdi_object_version_number Pass in the current version number of the
 * Position Description that you are updating. When the API completes, if
 * p_validate is false, sets the new version number of the updated Position
 * Description. If p_validate is true, sets the same value passed in.
 * @rep:displayname Update Federal Position Description
 * @rep:category BUSINESS_ENTITY GHR_POSITION_DESCRIPTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_pdi
(
	p_validate IN BOOLEAN default false,
	p_position_description_id IN number,
	p_routing_grp_id	  IN   number default hr_api.g_number,
	p_date_from IN date,
	p_date_to IN date default hr_api.g_date,
	p_opm_cert_num IN ghr_position_descriptions.opm_cert_num%TYPE default hr_api.g_varchar2,
	p_flsa	IN	ghr_position_descriptions.flsa%TYPE default hr_api.g_varchar2,
	p_financial_statement IN ghr_position_descriptions.financial_statement%TYPE default hr_api.g_varchar2,
	p_subject_to_ia_action	IN  ghr_position_descriptions.subject_to_ia_action%TYPE default hr_api.g_varchar2,
	p_position_status IN ghr_position_descriptions.position_status%TYPE default hr_api.g_number,
	p_position_is	IN ghr_position_descriptions.position_is%TYPE default hr_api.g_varchar2,
	p_position_sensitivity IN ghr_position_descriptions.position_sensitivity%TYPE default hr_api.g_varchar2,
	p_competitive_level IN ghr_position_descriptions.competitive_level%TYPE default hr_api.g_varchar2,
	p_pd_remarks	IN  ghr_position_descriptions.pd_remarks%TYPE default hr_api.g_varchar2,
	p_position_class_std IN ghr_position_descriptions.position_class_std%TYPE default hr_api.g_varchar2,
	p_category	IN ghr_position_descriptions.category%TYPE default hr_api.g_varchar2,
	p_career_ladder	IN ghr_position_descriptions.career_ladder%TYPE default hr_api.g_varchar2,
        p_supervisor_name         in varchar2       default hr_api.g_varchar2,
        p_supervisor_title        in varchar2       default hr_api.g_varchar2,
        p_supervisor_date         in date           default hr_api.g_date,
        p_manager_name		  in varchar2       default hr_api.g_varchar2,
        p_manager_title 	  in varchar2       default hr_api.g_varchar2,
        p_manager_date            in date           default hr_api.g_date,
        p_classifier_name	  in varchar2       default hr_api.g_varchar2,
        p_classifier_title 	  in varchar2       default hr_api.g_varchar2,
        p_classifier_date         in date           default hr_api.g_date,
	p_attribute_category              in      varchar2  default hr_api.g_varchar2,
	p_attribute1                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute2                      in      varchar2  default hr_api.g_varchar2,
	p_attribute3                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute4                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute5                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute6                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute7                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute8                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute9                      in      varchar2  default hr_api.g_varchar2,
 	p_attribute10                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute11                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute12                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute13                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute14                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute15                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute16                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute17                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute18                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute19                     in      varchar2  default hr_api.g_varchar2,
 	p_attribute20                     in      varchar2  default hr_api.g_varchar2,
 	p_business_group_id               in      number    default hr_api.g_number,
      p_u_approved_flag                 in      varchar2  default hr_api.g_varchar2,
 	p_u_user_name_acted_on            in      varchar2  default hr_api.g_varchar2,
  	p_u_action_taken                  in      varchar2  default null,
  	p_i_user_name_routed_to           in      varchar2  default null,
  	p_i_groupbox_id                   in      number    default null,
  	p_i_routing_list_id               in      number    default null,
  	p_i_routing_seq_number            in      number    default null,
  	p_u_pdh_object_version_number     in out nocopy     number,
  	p_i_pd_routing_history_id         out nocopy     number,
  	p_i_pdh_object_version_number     out nocopy     number,
	p_o_pd_routing_history_id         out nocopy     number,

        p_o_pdh_object_version_number     out nocopy     number,

	p_pdi_object_version_number in out nocopy number);

procedure call_workflow
(
p_position_description_id IN ghr_position_descriptions.position_description_id%TYPE,
p_action_taken            IN ghr_pd_routing_history.action_taken%TYPE
);
end ghr_pdi_api;

 

/
