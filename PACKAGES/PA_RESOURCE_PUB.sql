--------------------------------------------------------
--  DDL for Package PA_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_PUB" AUTHID DEFINER AS
/*$Header: PAPMREPS.pls 120.3.12010000.3 2010/04/30 12:16:34 rthumma ship $*/
/*#
 * You can use the resource APIs to export your resource lists and the resources they include to Oracle Projects.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Create Resources
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJ_PLANNING_RESOURCE
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
-- -------------------------------------------------------------------------------------------------------
-- 	Globals
-- -------------------------------------------------------------------------------------------------------

G_PKG_NAME          		CONSTANT  	VARCHAR2(30) := 'PA_RESOURCE_PUB';

G_HEADER_CODE       		CONSTANT  	VARCHAR2(6) 	:= 'LIST';
G_LINE_CODE         		CONSTANT  	VARCHAR2(6) 	:= 'MEMBER';
G_API_VERSION_NUMBER 	CONSTANT	NUMBER 	:= 1.0;

ROW_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

-- -------------------------------------------------------------------------------------------------------
-- 	Record/Table Definitions
-- -------------------------------------------------------------------------------------------------------

TYPE resource_list_rec IS RECORD

( resource_list_name 	VARCHAR2(80)  	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  description               	VARCHAR2(255) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  group_resource_type       VARCHAR2(30)  	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  start_date		DATE          		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  end_date                  	DATE         		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  resource_list_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  new_list_name		VARCHAR2(30) 	 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  job_group_id             NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM     --Added for bug 2486405.
  );

TYPE resource_list_out_rec IS RECORD

( resource_list_id          NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  return_status             VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR );

TYPE member_rec IS RECORD

 ( resource_group_alias     VARCHAR2(80)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  -- Bug 9666020
   resource_group_name      VARCHAR2(80)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   resource_type_code       VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   resource_attr_value      VARCHAR2(80)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   resource_alias           VARCHAR2(80)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  -- Bug 9666020
   sort_order               NUMBER        := NULL,
   resource_list_member_id  NUMBER	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   new_alias		    VARCHAR2(30)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   enabled_flag             VARCHAR2(1)   := 'Y' );

TYPE member_out_rec IS RECORD

 ( resource_list_member_id  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   return_status            VARCHAR2(1)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR );

TYPE member_tbl IS TABLE OF member_rec
 INDEX BY BINARY_INTEGER;

TYPE member_out_tbl IS TABLE OF member_out_rec
 INDEX BY BINARY_INTEGER;


g_resource_list_rec      resource_list_rec;
g_resource_list_out_rec  resource_list_out_rec;
g_member_tbl             member_tbl;
g_member_out_tbl         member_out_tbl;
g_member_tbl_count       NUMBER := 0;

g_miss_resource_list_rec  resource_list_rec;
g_miss_resource_list_out_rec resource_list_out_rec;

g_load_resource_list_id       NUMBER := 0;
g_load_member_tbl             member_tbl;
g_load_member_out_tbl         member_out_tbl;
g_load_member_tbl_count       NUMBER := 0;

g_update_resource_list_id     NUMBER := 0;
g_update_member_tbl           member_tbl;
g_update_member_out_tbl       member_out_tbl;
g_update_member_tbl_count     NUMBER := 0;

-- -------------------------------------------------------------------------------------------------------
-- 	Procedures
-- -------------------------------------------------------------------------------------------------------
/*#
 * This API creates a resource list and optionally creates the resource list members.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @rep:paraminfo {@rep:precision 1}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_resource_list_rec Resource list input structure
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_out_rec Resource list output structure
 * @rep:paraminfo {@rep:required}
 * @param p_member_tbl Resource list members input structure
 * @rep:paraminfo {@rep:required}
 * @param p_member_out_tbl Resource list members output structure
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Resource List
 * @rep:compatibility S
*/
PROCEDURE Create_Resource_List
(p_commit                 IN 	VARCHAR2 := FND_API.G_FALSE,
 p_init_msg_list          IN 	VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number     IN 	NUMBER,
 p_return_status          OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count              OUT 	NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data               OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_rec      IN  	resource_list_rec,
 p_resource_list_out_rec  OUT  	NOCOPY resource_list_out_rec, --File.Sql.39 bug 4440895
 p_member_tbl             IN  	member_tbl,
 p_member_out_tbl         OUT  	NOCOPY member_out_tbl ); --File.Sql.39 bug 4440895

PROCEDURE Process_Members
(p_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_id       IN  NUMBER   		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_member_tbl             IN  member_tbl,
 p_group_resource_type    IN  VARCHAR2 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_job_group_id           IN  NUMBER,            -- Added for bug 2486405
 p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_member_out_tbl         OUT NOCOPY member_out_tbl ); --File.Sql.39 bug 4440895

/*#
 * This API sets up the global data structures used by other Load-Execute-Fetch procedures.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Resource Lists-Initialize
 * @rep:compatibility S
*/
PROCEDURE Init_Create_Resource_List ;
/*#
 * This API loads the resource list global input structure.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_name  Name of the resource list
 * @param p_description Description of the resource list
 * @param p_group_resource_type Type of the resource group
 * @param p_start_date Start date of the resource list
 * @param p_end_date End date of the resource list
 * @param p_resource_list_id Identifier of the resource list
 * @param p_new_list_name New name of the resource list
 * @param p_job_group_id Job group identifier of the job associated with the resource list. System generated primary key
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Resource Lists-Load
 * @rep:compatibility S
*/
PROCEDURE Load_Resource_List
( p_api_version_number     IN  NUMBER,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_description            IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_group_resource_type    IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_start_date             IN  DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_end_date               IN  DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_resource_list_id       IN  NUMBER	    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_new_list_name          IN  VARCHAR2	    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_job_group_id           IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  -- Added for bug 2486405.
  p_return_status          OUT NOCOPY VARCHAR2					); --File.Sql.39 bug 4440895
/*#
 * This API loads the resource list member global input structure.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_resource_group_alias Alias of the resource group
 * @param p_resource_group_name Name of the resource group
 * @param p_resource_type_code Type code of the resource
 * @param p_resource_attr_value Attribute value of the resource
 * @param p_resource_alias  Alias of the resource member
 * @param p_resource_list_member_id Identifier of the resource list member
 * @param p_new_alias New alias of the resource member
 * @param p_sort_order Sort order of the resource member
 * @param p_enabled_flag Flag indicating whether the resource list member is enabled
 * @rep:paraminfo {@rep:precision 1}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Mulitple Members-Load
 * @rep:compatibility S
*/
PROCEDURE Load_Members
( p_api_version_number     IN  NUMBER,
  p_resource_group_alias   IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_group_name    IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_type_code     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_attr_value    IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_alias         IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_member_id IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_new_alias		   IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_sort_order             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_enabled_flag           IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_return_status          OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
/*#
 * This API executes the composite API CREATE_RESOURCE_LIST.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Resource Lists-Execute Create
 * @rep:compatibility S
*/
PROCEDURE Exec_Create_Resource_List
(p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list          IN 	VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number      IN NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*#
 * This API fetches one resource list identifier at a time from the global output structure for resource lists.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_id Identifier of the resource list
 * @rep:paraminfo {@rep:required}
 * @param p_list_return_status Return status of the specific resource list
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Resource Lists-Fetch
 * @rep:compatibility S
*/
PROCEDURE Fetch_Resource_List
(p_api_version_number      IN NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_list_return_status      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


/*#
 * This API fetches resource members from the global output structure for resource list members.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_member_index Member index (default = 1)
 * @param p_resource_list_member_id Identifier of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param p_member_return_status Return status of the specific resource list member
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Members-Fetch
 * @rep:compatibility S
*/
PROCEDURE Fetch_Members
 ( p_api_version_number      IN NUMBER,
   p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_member_index            IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_member_return_status    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
/*#
 * This API clears the global data structures created during the initialize process.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Resource Lists-Clear
 * @rep:compatibility S
*/
PROCEDURE Clear_Create_Resource_List ;
-- ----------------------------------------------------------
/*#
 * This API updates an existing resource list, including updating existing or adding new resource list members.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id Identifier of the resource list
 * @param p_new_list_name New name of the existing resource list
 * @param p_grouped_by_type Group by type of the resource list
 * @param p_description Description of the resource list
 * @param p_start_date Start date of the resource list
 * @param p_end_date End date of the resource list
 * @param p_member_tbl Resource list members input structure
 * @rep:paraminfo {@rep:required}
 * @param p_member_out_tbl Resource list members output structure
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Resource List
 * @rep:compatibility S
*/
PROCEDURE Update_Resource_List
(p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number       IN  NUMBER,
 p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
 p_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_name       IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_id         IN  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_new_list_name            IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_grouped_by_type          IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_description              IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_start_date               IN  DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_end_date                 IN  DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_member_tbl               IN  member_tbl,
 p_member_out_tbl           OUT NOCOPY member_out_tbl  --File.Sql.39 bug 4440895
);

/*#
 * This API sets up the global data structures used by other Load-Execute-Fetch procedures.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Members-Initialize
 * @rep:compatibility S
*/
PROCEDURE Init_Update_Members ;

/*#
 * This API executes the composite API UPDATE_RESOURCE_LIST.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS and
 * CLEAR_UPDATE_MEMBERS
 * CLEAR_CREATE_RESOURCE_LIST
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Resource Lists
 * @rep:compatibility S
*/
PROCEDURE Exec_Update_Resource_List
(p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list          IN 	VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number      IN NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

/*#
 * This API clears the global data structures that were created during the initialize step for
 * the Load-Execute-Fetch update APIs.
 * In order to execute this API the following list of API's should be executed in the following order.
 * INIT_CREATE_RESOURCE_LIST,
 * LOAD_RESOURCE_LIST,
 * INIT_UPDATE_MEMBERS,
 * LOAD_MEMBERS,
 * EXEC_CREATE_RESOURCE_LIST / EXEC_UPDATE_RESOURCE_LIST,
 * FETCH_RESOURCE_LIST,
 * FETCH_MEMBERS,
 * CLEAR_UPDATE_MEMBERS and
 * CLEAR_CREATE_RESOURCE_LIST
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Members-Clear
 * @rep:compatibility S
*/
PROCEDURE Clear_Update_Members ;
-- ---------------------------------------------------------
/*#
 * This API deletes a resource member from an existing resource list.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id Identification code of resource list
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The point of occurrence of an error
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Resource List
 * @rep:compatibility S
*/
PROCEDURE Delete_Resource_List
( p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN  NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_err_code               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- ----------------------------------------------------------
/*#
 * This API adds a resource member to an existing resource list.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id Identifier of the resource list
 * @param p_resource_group_alias Alias of the resource group
 * @param p_resource_group_name Name of the resource group
 * @param p_resource_type_code Type of the resource
 * @param p_resource_attr_value Attribute value of the resource
 * @param p_resource_alias  Alias of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param p_sort_order Sort order of the resource list member
 * @param p_enabled_flag Flag indicating that whether the resource list member is enabled
 * @param p_resource_list_member_id Identifier of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Resource List Member
 * @rep:compatibility S
*/
PROCEDURE Add_Resource_List_Member
(p_commit                  IN VARCHAR2  := FND_API.G_FALSE,
 p_init_msg_list           IN VARCHAR2  := FND_API.G_FALSE,
 p_api_version_number      IN NUMBER,
 p_resource_list_name      IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_id        IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_resource_group_alias    IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_group_name     IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_type_code      IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_attr_value     IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_alias          IN VARCHAR2 ,
 p_sort_order              IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_enabled_flag            IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_return_status           OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*#
 * This API updates the alias and enables or disables the resource list members.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id Identifier of the resource list
 * @param p_resource_alias Alias of the resource list member
 * @param p_resource_list_member_id Identifier of the resource list member
 * @param p_new_alias New alias of the resource list member
 * @param p_sort_order Sort order of the resource list member
 * @param p_enabled_flag Flag indicating whether the resource list member is enabled
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Resource List Member
 * @rep:compatibility S
*/
PROCEDURE Update_Resource_List_Member
( p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN  NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_resource_alias         IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_member_id IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_new_alias              IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_sort_order             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_enabled_flag           IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) ;

/*#
 * This API deletes a resource list member.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id Identifier of the resource list
 * @param p_resource_alias Alias of the resource list member
 * @param p_resource_list_member_id Identifier of the resource list member
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_err_code The error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The point of occurrence of an error
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Resource List Member
 * @rep:compatibility S
*/
PROCEDURE Delete_Resource_List_Member
( p_commit                 IN VARCHAR2 := FND_API.G_FALSE,
  p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN NUMBER,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_resource_alias         IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_member_id IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_err_code               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;

/*#
 * This API updates the sort order for resource members in a given resource list
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_resource_list_name Name of the resource list
 * @param p_resource_list_id Identifier of the resource list
 * @param p_resource_group_alias Alias of the resource group
 * @param p_sort_by Sort by code
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Members-Sort
 * @rep:compatibility S
*/
PROCEDURE Sort_Resource_List_Members
( p_commit                 IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_resource_group_alias   IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_sort_by                IN  VARCHAR2,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

-- ----------------------------------------------------------
PROCEDURE Convert_List_Name_To_Id
(p_resource_list_name   IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_id     IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_out_resource_list_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_return_status        OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE Convert_Alias_To_Id
(
 p_resource_list_id            IN NUMBER,
 p_alias                       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_member_id     IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id                  IN NUMBER DEFAULT NULL,
 p_out_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_return_status        OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

FUNCTION is_planning_resource(p_resource_list_member_id IN NUMBER) RETURN VARCHAR2;
FUNCTION is_planning_resource_list(p_resource_list_id IN NUMBER) RETURN VARCHAR2;

END PA_RESOURCE_PUB ;

/
