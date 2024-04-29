--------------------------------------------------------
--  DDL for Package PA_PAGE_TYPE_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAGE_TYPE_REGION_PUB" AUTHID CURRENT_USER AS
--$Header: PAPLPTPS.pls 120.1 2005/08/19 16:41:39 mwasowic noship $

PROCEDURE Create_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 1.7E20,

 P_PAGE_TYPE_CODE in VARCHAR2,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_SOURCE_CODE in VARCHAR2  := null,
 P_REGION_SOURCE_NAME in VARCHAR2 := null,

 P_VIEW_REGION_CODE in VARCHAR2 := null,
 P_EDIT_REGION_CODE in VARCHAR2 := null,
 P_VIEW_REGION_NAME in VARCHAR2 := null,
 P_EDIT_REGION_NAME in VARCHAR2 := null,
 P_REGION_STYLE in VARCHAR2 := null,
 P_DISPLAY_ORDER in NUMBER := null,
 P_MANDATORY_FLAG in VARCHAR2 := null,
 P_DEFAULT_REGION_POSITION in VARCHAR2 := null,
 P_PLACEHOLDER_REGION_FLAG in VARCHAR2:=null,
 P_START_DATE_ACTIVE in DATE,
 P_END_DATE_ACTIVE in DATE,

 P_DOCUMENT_SOURCE in VARCHAR2 := null,
 P_PAGE_FUNCTION_NAME in VARCHAR2 := null,
 P_SECURITY_FUNCTION_NAME in VARCHAR2 := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;

PROCEDURE Update_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 1.7E20,

 P_PAGE_TYPE_CODE in VARCHAR2,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_SOURCE_CODE in VARCHAR2  := null,
 P_REGION_SOURCE_NAME in VARCHAR2  := null,

 P_VIEW_REGION_CODE in VARCHAR2 := null,
 P_EDIT_REGION_CODE in VARCHAR2 := null,
 P_VIEW_REGION_NAME in VARCHAR2 := null,
 P_EDIT_REGION_NAME in VARCHAR2 := null,
 P_REGION_STYLE in VARCHAR2 := '^',
 P_DISPLAY_ORDER in NUMBER := 1.7E20,
 P_MANDATORY_FLAG in VARCHAR2 := '^',
 P_DEFAULT_REGION_POSITION in VARCHAR2 := '^',
 P_PLACEHOLDER_REGION_FLAG in VARCHAR2 := '^',
 P_START_DATE_ACTIVE in DATE,
 P_END_DATE_ACTIVE in DATE,

 P_DOCUMENT_SOURCE in VARCHAR2 := null,
 P_PAGE_FUNCTION_NAME in VARCHAR2 := null,
 P_SECURITY_FUNCTION_NAME in VARCHAR2 := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;

PROCEDURE Delete_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_rowid                       IN     VARCHAR2 := NULL,
 P_PAGE_TYPE_CODE in VARCHAR2 := NULL,
 P_REGION_SOURCE_TYPE in VARCHAR2 := NULL,
 P_REGION_SOURCE_CODE in VARCHAR2 := NULL,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;

END  PA_PAGE_TYPE_REGION_PUB;

 

/
