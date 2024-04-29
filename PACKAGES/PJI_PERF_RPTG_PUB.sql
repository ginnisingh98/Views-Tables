--------------------------------------------------------
--  DDL for Package PJI_PERF_RPTG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PERF_RPTG_PUB" AUTHID CURRENT_USER as
/*$Header: PJIPRFPS.pls 120.1 2006/07/27 13:35:16 ajdas noship $*/
/*#
 * This package contains the public APIs for project performance reporting.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Performance Reporting API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PERF_REPORTING
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


--Package constant used for package version validation
G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;


/*#
 * This procedure creates resource rollup lines in the PJI_FP_XBS_ACCUM_F table  for the
 * RBS, for the workplans, financial plans, and actual transactions supplied when the
 * API is called. These lines have their header entries in the PJI_ROLLUP_LEVEL_STATUS
 * table for the corresponding PROJECT_ID, PLAN_VERSION_ID, WBS_VERSION_ID, RBS_VERSION_ID,
 * and detail entries in PJI_FP_XBS_ACCUM_F. These lines are created only when the first
 * user navigates to the Resource Summary, Resource, and Task Analysis pages..
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = 'F') indicates if transcation will be commited
 * @param p_init_msg_list API standard (default = 'F') indicates if message stack will be initialized
 * @param x_msg_count API standard Return count of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard Return error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_project_id Identifier of the project for which resource rollups need to be created
 * @rep:paraminfo {@rep:required}
 * @param p_plan_version_id_tbl Table of plan version identifiers for creating the resource rollups
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id_tbl  Table of resource breakdown structure version identifiers for
 * which resource rollups need to be created
 * @rep:paraminfo {@rep:required}
 * @param p_prg_rollup_flag Flag indicating whether to create resource rollups for the linked projects.
 * The valid values are Y or N (default.) Pass Y only if you want  to create the resource rollups for
 * the linked projects.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Resource Rollup
 * @rep:compatibility S
*/

PROCEDURE Create_resource_rollup
( p_api_version_number      IN   NUMBER          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                  IN   VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list           IN   VARCHAR2        := FND_API.G_FALSE
 ,x_msg_count               OUT  NOCOPY NUMBER
 ,x_msg_data                OUT  NOCOPY VARCHAR2
 ,x_return_status           OUT  NOCOPY VARCHAR2
 ,p_project_id              IN   NUMBER
 ,p_plan_version_id_tbl     IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_rbs_version_id_tbl      IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_prg_rollup_flag         IN   VARCHAR2        :='N'
);


/*#
 * This API deletes the resource summary information from the PJI_FP_XBS_ACCUM_F table
 * for a list of workplans, financial plans, and actual transactions. The API also
 * deletes the resource summary header information from  the PJI_ROLLUP_LEVEL_STATUS
 * table for the corresponding PROJECT_ID ,PLAN_VERSION_ID and  RBS_VERSION_ID.
 * @param p_api_version_number API standard version number
 * @param p_commit API standard (default = 'F') indicates if transcation will be commited
 * @param p_init_msg_list API standard (default = 'F') indicates if message stack will be initialized
 * @param x_msg_count API standard Return count of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard Return error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param x_return_status API standard Return of the API success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_project_id Identifier of the project for which resource rollups need to be deleted
 * @rep:paraminfo {@rep:required}
 * @param p_plan_version_id_tbl Table of plan version identifiers for deleting the resource rollups.
 * To delete actuals, pass -1 as the value for the plan version identifier.
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id_tbl  Table of resource breakdown structure version identifiers for
 * which resource rollups need to be deleted
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Resource Rollup
 * @rep:compatibility S
*/

PROCEDURE Delete_resource_rollup
( p_api_version_number      IN   NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                  IN   VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN   VARCHAR2    := FND_API.G_FALSE
 ,x_msg_count               OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
 ,x_return_status           OUT NOCOPY VARCHAR2
 ,p_project_id              IN   NUMBER
 ,p_plan_version_id_tbl     IN SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_rbs_version_id_tbl      IN SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
);


end PJI_PERF_RPTG_PUB;

 

/
