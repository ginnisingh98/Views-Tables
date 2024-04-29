--------------------------------------------------------
--  DDL for Package PA_PAGE_LAYOUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAGE_LAYOUT_PVT" AUTHID CURRENT_USER AS
--$Header: PAPRPLVS.pls 120.1 2005/08/19 16:44:54 mwasowic noship $

--History
--    16-Feb-2004    svenketa - Modified, Added a parameter p_function_name for create and update.

PROCEDURE Create_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_name                   IN     VARCHAR2  := FND_API.g_miss_char,

 p_page_type                   IN     VARCHAR2 := FND_API.g_miss_char,

 p_description                 IN     VARCHAR2 := FND_API.g_miss_char,

 p_start_date                  IN     date,

 p_end_date                    IN     date,
 p_shortcut_menu_id            IN     number,
 p_shortcut_menu_name          IN     VARCHAR2,
 p_function_name	       IN     VARCHAR2 := NULL,
 x_page_id                     OUT    NOCOPY number, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );


 PROCEDURE Update_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     number,

 p_page_name                   IN     VARCHAR2  := FND_API.g_miss_char,

-- p_page_type                   IN     VARCHAR2 := FND_API.g_miss_char,

 p_description                 IN     VARCHAR2 := FND_API.g_miss_char,

 p_start_date                  IN     date,

 p_end_date                    IN     date,
 p_shortcut_menu_id            IN     number,
 p_shortcut_menu_name          IN     VARCHAR2,
 p_record_version_number       IN NUMBER ,
 p_function_name	       IN     VARCHAR2 := NULL,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) ;



 PROCEDURE Delete_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     number,
 p_record_version_number       IN NUMBER ,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;


procedure ADD_PAGE_REGION (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_PAGE_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,
  P_VIEW_REGION_CODE in VARCHAR2,
  P_EDIT_REGION_CODE in VARCHAR2,
  P_REGION_STYLE     in VARCHAR2 default 'PA_UDS_SINGLE_COL',
  P_DISPLAY_ORDER in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Delete_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     number,
 P_REGION_SOURCE_TYPE 		in VARCHAR2,
 P_REGION_SOURCE_CODE 		in VARCHAR2,
 p_record_version_number       IN NUMBER,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

PROCEDURE Delete_All_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,
 p_region_position             IN     VARCHAR2 := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;

PROCEDURE Delete_All_Link_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,
 p_region_position             IN     VARCHAR2 := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) ;

FUNCTION IS_REGION_DELETE_OK(p_region_source_type  in   varchar2,
                             p_region_source_code  in   varchar2) return varchar2;

END  PA_PAGE_LAYOUT_PVT;

 

/
