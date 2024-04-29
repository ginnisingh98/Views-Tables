--------------------------------------------------------
--  DDL for Package PA_PAGE_LAYOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAGE_LAYOUT_PKG" AUTHID CURRENT_USER AS
--$Header: PAPRPLHS.pls 120.1 2005/08/19 16:44:38 mwasowic noship $
procedure INSERT_PAGE_LAYOUT_ROW (
  P_PAGE_NAME in VARCHAR2,
  P_PAGE_TYPE in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_START_DATE in DATE,
  P_END_DATE in DATE,
  P_SHORTCUT_MENU_ID in NUMBER,
  P_FUNCTION_NAME in VARCHAR2,
  x_page_id                     OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure UPDATE_PAGE_LAYOUT_ROW (
  P_PAGE_ID in NUMBER,
  P_PAGE_NAME in VARCHAR2,
  P_PAGE_TYPE in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_START_DATE in DATE,
  P_END_DATE in DATE,
  P_SHORTCUT_MENU_ID in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_FUNCTION_NAME in VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure DELETE_PAGE_LAYOUT_ROW (
		      P_PAGE_ID in NUMBER,
		      P_RECORD_VERSION_NUMBER in NUMBER,

		      x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		      x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
		      x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure INSERT_PAGE_REGION_ROW (
  P_PAGE_ID in NUMBER,
  p_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,
  P_VIEW_REGION_CODE in VARCHAR2,
  P_EDIT_REGION_CODE in VARCHAR2,
  P_REGION_STYLE     in VARCHAR2,
  P_DISPLAY_ORDER in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure DELETE_PAGE_REGION_ROW (
  P_PAGE_ID in NUMBER,
  p_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END  PA_PAGE_LAYOUT_PKG;

 

/
