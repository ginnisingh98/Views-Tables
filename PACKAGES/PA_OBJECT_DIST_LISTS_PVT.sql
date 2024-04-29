--------------------------------------------------------
--  DDL for Package PA_OBJECT_DIST_LISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OBJECT_DIST_LISTS_PVT" AUTHID CURRENT_USER AS
 /* $Header: PATODLVS.pls 120.1 2005/08/19 17:04:41 mwasowic noship $ */
procedure CREATE_OBJECT_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID 		in     NUMBER,
  P_OBJECT_TYPE 	in     VARCHAR2,
  P_OBJECT_ID 		in     VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  P_CREATED_BY 		in NUMBER default fnd_global.user_id,
  P_CREATION_DATE 	in DATE default sysdate,
  P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE 	in DATE default sysdate,
  P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure UPDATE_OBJECT_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE default sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure DELETE_OBJECT_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure DELETE_ASSOC_DIST_LISTS (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

END  PA_OBJECT_DIST_LISTS_PVT;

 

/
