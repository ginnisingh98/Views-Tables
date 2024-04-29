--------------------------------------------------------
--  DDL for Package BIS_IMPL_DEV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_IMPL_DEV_PKG" AUTHID CURRENT_USER AS
/* $Header: BISCONCS.pls 120.2 2005/07/12 01:10:40 smulye noship $ */
   version               CONSTANT VARCHAR (80)
            := '$Header: BISCONCS.pls 120.2 2005/07/12 01:10:40 smulye noship $';

function clob_to_varchar2 (
  p_in      clob,
  p_size    integer
) return varchar2;

procedure Create_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Update_Linkage (
 P_ROWID		in ROWID,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Delete_Linkage (
 P_ROWID		in ROWID
) ;

-- added to detect loop for enabled dependency in RSG
PROCEDURE dep_loop_validation (
 p_object_type          IN VARCHAR2,
 p_object_name          IN VARCHAR2,
 p_dep_object_type      IN VARCHAR2,
 p_dep_object_name      IN VARCHAR2,
 p_enabled_flag         IN VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
);

procedure page_name_validation (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_USER_OBJECT_NAME     IN VARCHAR2,
 X_OBJECT_NAME          IN OUT NOCOPY VARCHAR2,
 X_IS_OA_PAGE           IN OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) ;

procedure object_name_validation (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_USER_OBJECT_NAME     IN VARCHAR2,
 X_OBJECT_NAME          IN OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) ;

procedure object_owner_validation (
 P_OBJECT_OWNER         IN VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) ;

procedure conc_program_validation (
 P_USER_CONC_PROGRAM_NAME    IN VARCHAR2,
 X_CONC_APP_ID               IN OUT NOCOPY NUMBER,
 X_CONC_APP_SHORT_NAME       OUT NOCOPY VARCHAR2,
 X_CONC_PROGRAM_NAME         OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS             OUT NOCOPY VARCHAR2
) ;

FUNCTION Refresh_Program_Exists(
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2) RETURN VARCHAR2;

procedure Create_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2     DEFAULT NULL,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Update_Dependency (
 P_ROWID		in ROWID       := null,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2     DEFAULT NULL,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Delete_Dependency (
 P_ROWID		in ROWID
) ;

procedure Create_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2 default null,
 P_CREATED_BY             in NUMBER default null,
 P_CREATION_DATE          in DATE default null,
 P_LAST_UPDATED_BY        in NUMBER default null,
 P_LAST_UPDATE_LOGIN	in NUMBER default null,
 P_LAST_UPDATE_DATE	in DATE default null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

-- added for bug3040249
procedure Update_Obj_Last_Refresh_Date(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_LAST_REFRESH_DATE		in DATE
);


procedure Update_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 P_LAST_UPDATED_BY        in NUMBER default null,
 P_LAST_UPDATE_LOGIN	in NUMBER default null,
 P_LAST_UPDATE_DATE	in DATE default null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Delete_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2
);

function Get_User_Object_Name (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_OBJECT_NAME          IN VARCHAR2
) RETURN varchar2;

/* starts BIS407 _OA Cleanup*/
function is_page_migrated (
 P_PAGE_NAME		in VARCHAR2
) RETURN boolean;


function get_function_by_page (
 P_PAGE_NAME		in VARCHAR2
) RETURN varchar2;

procedure migrate_page(
 P_PAGE_NAME		in VARCHAR2,
 P_NEW_PAGE_NAME	in VARCHAR2
);

/* ends BIS407 _OA Cleanup*/

/* starts: bug 3562027 -- change owner for parent object */
FUNCTION is_owner_changed (
 p_obj_name IN VARCHAR2,
 p_obj_type IN VARCHAR2,
 p_new_obj_owner IN VARCHAR2,
 p_actual_owner  OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

PROCEDURE change_prop_linkage_owner (
 p_obj_name IN VARCHAR2,
 p_obj_type IN VARCHAR2,
 p_obj_owner IN VARCHAR2
);
/* sends: bug 3562027 -- change owner for parent object */

/* starts: bug 3881369 -- inner APIs not blocking  exceptions*/

procedure Create_Properties_Inner(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2 default null,
 P_CREATED_BY             in NUMBER default null,
 P_CREATION_DATE          in DATE default null,
 P_LAST_UPDATED_BY        in NUMBER default null,
 P_LAST_UPDATE_LOGIN	in NUMBER default null,
 P_LAST_UPDATE_DATE	in DATE default null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;


procedure Update_Properties_Inner(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 P_LAST_UPDATED_BY        in NUMBER default null,
 P_LAST_UPDATE_LOGIN	in NUMBER default null,
 P_LAST_UPDATE_DATE	in DATE default null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Create_Dependency_Inner (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2     DEFAULT NULL,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Update_Dependency_Inner (
 P_ROWID		in ROWID       := null,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2     DEFAULT NULL,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Create_Linkage_Inner (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure Update_Linkage_Inner (
 P_ROWID		in ROWID,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;
/* ends: bug 3881369 -- inner APIs not blocking exceptions*/

FUNCTION is_object_seeded
( p_obj_name IN VARCHAR2,
  p_obj_type IN VARCHAR2) return varchar2;
end bis_impl_dev_pkg;

 

/
