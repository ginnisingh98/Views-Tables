--------------------------------------------------------
--  DDL for Package PA_CONTROL_ITEMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_ITEMS_UTILS" AUTHID CURRENT_USER AS
--$Header: PACICIUS.pls 120.4 2007/02/08 11:34:19 sukhanna ship $

g_ci_id Number        := NULL ;
g_ci_type_id Number   := NULL ;
g_ci_status varchar2(30) := NULL ;
g_ci_type_has_impact varchar2(1) := 'N' ;
g_type_has_impact varchar2(1) := 'N' ;


function GET_OBJECT_NAME(
         p_project_id   IN  NUMBER
        ,p_object_id 	IN  NUMBER   := NULL
        ,p_object_type  IN  VARCHAR2 := NULL
) RETURN VARCHAR2;

function GET_INITIAL_CI_STATUS(
         p_ci_type_id   IN NUMBER  := NULL
) RETURN VARCHAR2;

-- removed and replaced by API in PA_UTILS
--function GET_PARTY_ID (
--                        p_resource_id in NUMBER,
--                        p_resource_type_id in NUMBER)
--RETURN NUMBER;

Function IsImpactOkToInclude(p_ci_type_id_1   IN   NUMBER,
                             p_ci_type_id_2   IN   NUMBER,
                             p_ci_id_2        IN   NUMBER) return VARCHAR2;

 /* This Function will determine the specific action is allowed on the
    control item based on the current status.The return values are
    Y - Allows the specified action
    N - Specified action is not allowed
  */
Function CheckCIActionAllowed(p_status_type   IN   VARCHAR2 default null,
                              p_status_code   IN   VARCHAR2 default null,
                              p_action_code   IN   VARCHAR2 default  null,
			      p_ci_id IN NUMBER default  null) return VARCHAR2;

  Function CheckValidNextCISysStatus( p_curr_sys_status in varchar2
                                     ,p_next_sys_status in varchar2
                                     ,p_ci_type_class   in varchar2
                                     ,p_approval_req_flag in varchar2)
 return Boolean;

 Function CheckValidNextCIStatus( p_ci_id       in Number
                                 ,p_next_status in varchar2)
 return Boolean;

/*----------------------------------------------------------------------------
  Function to return status of control Item
  -----------------------------------------------------------------------------*/
  FUNCTION getCIStatus ( p_CI_id IN NUMBER)
  return VARCHAR2 ;

/*-----------------------------------------------------------------------------
  Function to check whether CI type has any impact
  This function retrieves impact flag for a control item
  -----------------------------------------------------------------------------*/
  FUNCTION isCITypehasimpact ( p_CI_id IN NUMBER)
  return VARCHAR2 ;

/*-----------------------------------------------------------------------------
  Function to check whether a type has any impact
  This one requires a TYPE ID as IN parm
  -----------------------------------------------------------------------------*/
  FUNCTION TypeHasImpact ( p_ci_type_id IN NUMBER)
  return VARCHAR2 ;

/*-------------------------------------------------------------------------------------
  Function Name: CheckValidNextPage
  Usage: Used with with lookup type to determine valid list of next pages to navigate
  Rules: 1. If CI id is null it is the create page. Allow all Next page
         2. Exclude the current page from the next page list.

---------------------------------------------------------------------------------------*/
-- !!! NOT USED - REPLACED with CheckNextPageValid
-- FUNCTION CheckValidNextPage( p_ci_id          IN NUMBER
--                             ,p_type_id        IN VARCHAR2
--                             ,p_status_control IN VARCHAR2
--                             ,p_page_code      IN VARCHAR2
--                             ,p_currpage_code  IN VARCHAR2
--                             ,p_action_list    IN VARCHAR2 := 'N')
-- return VARCHAR2;


  PROCEDURE checkandstartworkflow
   (
     p_api_version			IN NUMBER :=  1.0,
    p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
    p_commit			IN VARCHAR2 := FND_API.g_false,
    p_validate_only		IN VARCHAR2 := FND_API.g_true,
    p_max_msg_count		IN NUMBER := FND_API.g_miss_num,

    p_ci_id       in NUMBER,
    p_status_code IN VARCHAR2,

    x_msg_count      out NOCOPY     NUMBER,
    x_msg_data       out NOCOPY      VARCHAR2,
    x_return_status    OUT NOCOPY    VARCHAR2
    ) ;

/*-------------------------------------------------------------------------------------
 This function returns hz_parties.party_name for fnd_user.user_id  (IN parameter)
-------------------------------------------------------------------------------------*/
 FUNCTION GetUserName( p_user_id in Number)
 return Varchar2;
/*-------------------------------------------------------------------------------------
 This function returns hz_parties.party_id for fnd_user.user_id  (IN parameter)
-------------------------------------------------------------------------------------*/
 FUNCTION GetPartyId( p_user_id in Number)
 return NUMBER;

 FUNCTION CheckApprovalRequired(p_ci_id in Number)
 return Varchar2;

 FUNCTION CheckResolutionRequired(p_ci_id in Number)
 return Varchar2;

 FUNCTION CheckHasResolution(p_ci_id in Number)
 return Varchar2;

FUNCTION GetCITypeClassCode(p_ci_id in Number)
 return Varchar2;

 FUNCTION getCISystemStatus ( p_CI_id IN NUMBER)
  return VARCHAR2;

FUNCTION getSystemStatus ( p_status_code IN VARCHAR2)
  return VARCHAR2;


FUNCTION submitAllowed ( p_ci_id         IN NUMBER   := NULL
                        ,p_owner_id      IN NUMBER   := NULL
                        ,p_created_by_id IN NUMBER   := NULL
                        ,p_system_status IN VARCHAR2 := NULL)
return VARCHAR2;

FUNCTION deleteAllowed ( p_ci_id         IN NUMBER   := NULL
                        ,p_owner_id      IN NUMBER   := NULL
                        ,p_created_by_id IN NUMBER   := NULL
                        ,p_system_status IN VARCHAR2 := NULL)
return VARCHAR2;
FUNCTION closeAllowed ( p_ci_id         IN NUMBER   := NULL
                        ,p_owner_id      IN NUMBER   := NULL
                        ,p_created_by_id IN NUMBER   := NULL
                        ,p_system_status IN VARCHAR2 := NULL)
return VARCHAR2;

PROCEDURE ChangeCIStatus (
	 	  p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
		 ,p_commit               IN     VARCHAR2 := FND_API.g_false
		 ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
		 ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num
		 ,p_ci_id    in number
		 ,p_status   in varchar2
		 ,p_comment   in VARCHAR2 := null
		 ,p_enforce_security  in Varchar2 DEFAULT 'Y'
		 ,p_record_version_number    IN NUMBER
		 ,x_num_of_actions    OUT NOCOPY  NUMBER
		 ,x_return_status        OUT NOCOPY    VARCHAR2
		 ,x_msg_count            OUT NOCOPY    NUMBER
			  ,x_msg_data             OUT NOCOPY    VARCHAR2 );


  PROCEDURE CancelWorkflow
   (
    p_api_version			IN NUMBER :=  1.0,
    p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
    p_commit			IN VARCHAR2 := FND_API.g_false,
    p_validate_only		IN VARCHAR2 := FND_API.g_true,
    p_max_msg_count		IN NUMBER := FND_API.g_miss_num,

    p_ci_id       in NUMBER,

    x_msg_count      out NOCOPY     NUMBER,
    x_msg_data       out NOCOPY      VARCHAR2,
    x_return_status    OUT NOCOPY    VARCHAR2
    ) ;

FUNCTION CheckNonDraftCI(p_project_id in Number)
return Varchar2;

function GET_PARTY_ID_FROM_NAME(p_name IN VARCHAR2
) return NUMBER;

FUNCTION check_control_item_exists(
  p_project_id IN NUMBER,
  p_task_id IN NUMBER default NULL)
RETURN NUMBER;

FUNCTION check_class_category_in_use(
  p_class_category IN VARCHAR2)
RETURN NUMBER;

FUNCTION check_class_code_in_use(
  p_class_category IN VARCHAR2,
  p_class_code IN VARCHAR2)
RETURN NUMBER;

FUNCTION check_role_in_use(
  p_project_role_id IN NUMBER)
RETURN NUMBER;

FUNCTION check_project_type_in_use(
  p_project_type_id IN NUMBER)
RETURN NUMBER;
/*-------------------------------------------------------------------------------------
  Function Name: CheckNextPageValid
  Usage: Used with with lookup type to determine valid list of next pages to navigate
  Rules: 1. If CI id is null it is the create page.
         2. Exclude the current page from the next page list.

---------------------------------------------------------------------------------------*/
 FUNCTION CheckNextPageValid( p_ci_id           IN NUMBER := NULL
                             ,p_type_id         IN VARCHAR2
                             ,p_status_control  IN VARCHAR2
                             ,p_page_code       IN VARCHAR2
                             ,p_currpage_code   IN VARCHAR2
                             ,p_type_class_code IN VARCHAR2)

 return VARCHAR2;

function get_open_control_items(p_project_id   IN NUMBER,
                                p_object_type  IN VARCHAR2,
                                p_object_id    IN NUMBER,
                                p_item_type    IN VARCHAR2) return number;

Procedure GetDiagramUrl(p_project_id    IN  NUMBER,
                        p_ci_id         IN  NUMBER,
                        x_diagramurl    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2);

Procedure AbortWorkflow(p_project_id    IN  NUMBER,
                        p_ci_id         IN  NUMBER,
			p_record_version_number IN NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2);

Procedure ADD_STATUS_CHANGE_COMMENT(
                  p_object_type         IN VARCHAR2
                 ,p_object_id           IN NUMBER
                 ,p_type_code           IN VARCHAR2
                 ,p_status_type         IN VARCHAR2
                 ,p_new_project_status  IN VARCHAR2
                 ,p_old_project_status  IN VARCHAR2
                 ,p_comment             IN VARCHAR2 := null
                 ,P_CREATED_BY          IN NUMBER default fnd_global.user_id
                 ,P_CREATION_DATE       IN DATE default sysdate
                 ,P_LAST_UPDATED_BY     IN NUMBER default fnd_global.user_id
                 ,P_LAST_UPDATE_DATE    IN DATE default sysdate
                 ,P_LAST_UPDATE_LOGIN   IN NUMBER default fnd_global.user_id
                 ,x_return_status       OUT NOCOPY    VARCHAR2
                 ,x_msg_count           OUT NOCOPY    NUMBER
                 ,x_msg_data            OUT NOCOPY    VARCHAR2 );


--Bug 4716789 Added an API to delete the data from pa_obj_status_changes
Procedure DELETE_OBJ_STATUS_CHANGES(
		  p_object_type         IN     VARCHAR2
		 ,p_object_id           IN     NUMBER
		 ,x_return_status       OUT NOCOPY    VARCHAR2
                 ,x_msg_count           OUT NOCOPY    NUMBER
                 ,x_msg_data            OUT NOCOPY    VARCHAR2 );

PROCEDURE ChangeCIStatusValidate (
                     p_init_msg_list        IN  VARCHAR2 := fnd_api.g_true
                    ,p_commit               IN  VARCHAR2 := FND_API.g_false
                    ,p_validate_only        IN  VARCHAR2 := FND_API.g_true
                    ,p_max_msg_count        IN  NUMBER   := FND_API.g_miss_num
                    ,p_ci_id                IN  NUMBER
                    ,p_status               IN  VARCHAR2
                    ,p_enforce_security     IN  VARCHAR2 DEFAULT 'Y'
                    ,p_resolution_check     IN  VARCHAR2 DEFAULT 'UI'
                    ,x_resolution_req       OUT NOCOPY VARCHAR2
                    ,x_resolution_req_cls   OUT NOCOPY VARCHAR2
                    ,x_start_wf             OUT NOCOPY  VARCHAR2
                    ,x_new_status           OUT NOCOPY  VARCHAR2
                    ,x_num_of_actions       OUT NOCOPY  NUMBER
                    ,x_return_status        OUT NOCOPY  VARCHAR2
                    ,x_msg_count            OUT NOCOPY  NUMBER
                    ,x_msg_data             OUT NOCOPY  VARCHAR2 );



   PROCEDURE PostChangeCIStatus (
                     p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
                    ,p_commit               IN     VARCHAR2 := FND_API.g_false
                    ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
                    ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num
                    ,p_ci_id        in number
                    ,p_curr_status   in varchar2
                    ,p_new_status   in varchar2
                    ,p_start_wf     in VARCHAR2
                    ,p_enforce_security  in Varchar2 DEFAULT 'Y'
                    ,x_num_of_actions    OUT NOCOPY  NUMBER
                    ,x_return_status        OUT NOCOPY    VARCHAR2
                    ,x_msg_count            OUT NOCOPY    NUMBER
                    ,x_msg_data             OUT NOCOPY    VARCHAR2 );


END  PA_CONTROL_ITEMS_UTILS;

/
