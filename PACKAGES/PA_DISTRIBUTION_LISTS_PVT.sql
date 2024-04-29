--------------------------------------------------------
--  DDL for Package PA_DISTRIBUTION_LISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DISTRIBUTION_LISTS_PVT" AUTHID CURRENT_USER AS
 /* $Header: PATDSLVS.pls 120.1 2005/08/19 17:03:59 mwasowic noship $ */
procedure CREATE_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID 		in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_NAME 		in     VARCHAR2,
  P_DESCRIPTION 	in VARCHAR2,
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

procedure UPDATE_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_NAME                in VARCHAR2,
  P_DESCRIPTION         in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE default sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure DELETE_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_DELETE_LIST_ITEM_FLAG in VARCHAR2 default 'N',
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;
procedure CREATE_DIST_LIST_ITEM (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ITEM_ID        in OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
  P_LIST_ID             in NUMBER:= null,
  P_RECIPIENT_TYPE      in VARCHAR2:= null,
  P_RECIPIENT_ID        in VARCHAR2:= null,
  P_ACCESS_LEVEL        in NUMBER:= null,
  P_MENU_ID             in NUMBER:= null,
  P_EMAIL               in VARCHAR2:= null,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  P_CREATED_BY          in NUMBER default fnd_global.user_id,
  P_CREATION_DATE       in DATE default sysdate,
  P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE default sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;
procedure UPDATE_DIST_LIST_ITEM (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ITEM_ID        in NUMBER := null,
  P_LIST_ID             in NUMBER := null,
  P_RECIPIENT_TYPE      in VARCHAR2 := null,
  P_RECIPIENT_ID        in VARCHAR2 := null,
  P_ACCESS_LEVEL        in NUMBER := null,
  P_MENU_ID             in NUMBER := null,
  P_EMAIL               in VARCHAR2 := null,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE default sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;
procedure DELETE_DIST_LIST_ITEM (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ITEM_ID in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

END  PA_DISTRIBUTION_LISTS_PVT;
 

/
