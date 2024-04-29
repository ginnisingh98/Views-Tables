--------------------------------------------------------
--  DDL for Package Body PA_PAGE_LAYOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_LAYOUT_PKG" AS
--$Header: PAPRPLHB.pls 120.1 2005/08/19 16:44:34 mwasowic noship $


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
)
  IS

   l_row_id ROWID;
   l_page_id NUMBER;

   CURSOR  c1 IS
      SELECT rowid
	FROM   pa_page_layouts
	WHERE  page_id = l_page_id;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;


--  SELECT pa_page_layouts_s.NEXTVAL
--  INTO   l_page_id
--  FROM   dual;

   insert into PA_PAGE_LAYOUTS (
    PAGE_ID,
    PAGE_NAME,
    PAGE_TYPE_CODE,
    DESCRIPTION,
    START_DATE_active,
    END_DATE_active,
    SHORTCUT_MENU_ID ,
    RECORD_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PERS_FUNCTION_NAME)
  VALUES
  (
     pa_page_layouts_s.NEXTVAL,
     P_PAGE_NAME,
     P_PAGE_TYPE,
     P_DESCRIPTION,
     P_START_DATE,
     P_END_DATE,
     P_SHORTCUT_MENU_ID ,
     1,
     fnd_global.user_id,
     fnd_global.user_id,
     sysdate,
     sysdate,
     fnd_global.user_id,
     P_FUNCTION_NAME) returning page_id INTO l_page_id;

 OPEN c1;
  FETCH c1 INTO l_row_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c1;

  x_page_id := l_page_id;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Insert_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end INSERT_PAGE_LAYOUT_ROW;

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
) is
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  update PA_PAGE_LAYOUTS set
    PAGE_NAME = P_PAGE_NAME,
    PAGE_TYPE_CODE = Nvl(p_page_type, page_type_code),
    DESCRIPTION = P_DESCRIPTION,
    START_DATE_active = P_START_DATE,
    END_DATE_active = P_END_DATE,
    SHORTCUT_MENU_ID = P_SHORTCUT_MENU_ID ,
    RECORD_VERSION_NUMBER = p_record_version_number + 1,
    PERS_FUNCTION_NAME = P_FUNCTION_NAME,
    LAST_UPDATED_BY =  fnd_global.user_id,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = fnd_global.login_id
  where PAGE_ID = p_page_id;


  if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
  end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Update_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end UPDATE_PAGE_LAYOUT_ROW;

procedure DELETE_PAGE_LAYOUT_ROW (
		      P_PAGE_ID in NUMBER,
                      P_RECORD_VERSION_NUMBER in NUMBER,

		      x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		      x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
		      x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PA_PAGE_LAYOUTS
    where PAGE_ID = p_page_id
    AND    nvl(p_record_version_number, record_version_number) = record_version_number;

   --
--  IF (SQL%NOTFOUND) THEN
  --     PA_UTILS.Add_Message ( p_app_short_name => 'PA', p_msg_name => 'PA_XC_RECORD_CHANGED');
    --   x_return_status := FND_API.G_RET_STS_ERROR;
      -- RETURN;
  --END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;


end DELETE_PAGE_LAYOUT_ROW;



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
) IS

  l_row_id ROWID;

  cursor C is select ROWID from PA_PAGE_LAYOUT_REGIONS
    where PAGE_ID = P_PAGE_ID
    and REGION_SOURCE_TYPE = p_REGION_SOURCE_TYPE
    and REGION_SOURCE_CODE = P_REGION_SOURCE_CODE
    ;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  insert into PA_PAGE_LAYOUT_REGIONS (
    PAGE_ID,
    REGION_SOURCE_TYPE,
    REGION_SOURCE_CODE,
    VIEW_REGION_CODE,
    EDIT_REGION_CODE,
    REGION_STYLE,
    DISPLAY_ORDER,
    record_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    last_update_login
  ) VALUES (
    P_PAGE_ID,
    P_REGION_SOURCE_TYPE,
    P_REGION_SOURCE_CODE,
    P_VIEW_REGION_CODE,
    P_EDIT_REGION_CODE,
    P_REGION_STYLE,
    P_DISPLAY_ORDER,
    1,
    fnd_global.user_id,
    fnd_global.user_id,
    sysdate,
    sysdate,
    fnd_global.user_id)
    ;

  open c;
  fetch c into l_ROW_ID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Insert_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end INSERT_PAGE_REGION_ROW;

procedure DELETE_PAGE_REGION_ROW (
  P_PAGE_ID in NUMBER,
  p_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   delete from PA_PAGE_LAYOUT_REGIONS
     where PAGE_ID = P_PAGE_ID
     and REGION_SOURCE_TYPE = p_REGION_SOURCE_TYPE
     and REGION_SOURCE_CODE = P_REGION_SOURCE_CODE
     and nvl(p_record_version_number, record_version_number) = record_version_number;

EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end DELETE_PAGE_REGION_ROW;


END  PA_PAGE_LAYOUT_PKG;

/
