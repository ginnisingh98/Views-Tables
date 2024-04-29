--------------------------------------------------------
--  DDL for Package Body PA_PAGE_TYPE_REGION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_TYPE_REGION_PKG" AS
--$Header: PAPLPTHB.pls 115.3 2003/06/16 21:33:58 shanif noship $


procedure INSERT_PAGE_TYPE_REGION_ROW (
  P_PAGE_TYPE_CODE in VARCHAR2,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,

  P_VIEW_REGION_CODE in VARCHAR2,
  P_EDIT_REGION_CODE in VARCHAR2,
  P_REGION_STYLE in VARCHAR2,
  P_DISPLAY_ORDER in NUMBER,
  P_MANDATORY_FLAG in VARCHAR2,

  P_DEFAULT_REGION_POSITION in VARCHAR2,
  P_PLACEHOLDER_REGION_FLAG in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_DOCUMENT_SOURCE in VARCHAR2,
  P_PAGE_FUNCTION_NAME in VARCHAR2,
  P_SECURITY_FUNCTION_NAME in VARCHAR2
)
  IS

   l_row_id ROWID;

   CURSOR  c1 IS
      SELECT rowid
	FROM   pa_page_type_regions
	WHERE  page_type_code = p_page_type_code
	AND region_source_type = p_region_source_type
	AND region_source_code = p_region_source_code;

begin

  insert into PA_PAGE_TYPE_REGIONS (
				    PAGE_TYPE_CODE,
				    VIEW_REGION_CODE,
				    EDIT_REGION_CODE,
				    DISPLAY_ORDER,
				    MANDATORY_FLAG,
				    LAST_UPDATED_BY,
				    CREATED_BY ,
				    CREATION_DATE ,
				    LAST_UPDATE_DATE ,
				    LAST_UPDATE_LOGIN ,
				    DEFAULT_REGION_POSITION ,
				    PLACEHOLDER_REGION_FLAG ,
  				    REGION_SOURCE_TYPE,
				    REGION_SOURCE_CODE,
				    region_style,
				    START_DATE_ACTIVE ,
				    end_date_active,
				    DOCUMENT_SOURCE,
                                    page_function_name,
                                    security_function_name)
				    VALUES
				    (
				     P_PAGE_TYPE_CODE,
				     P_VIEW_REGION_CODE,
				     P_EDIT_REGION_CODE,
				     P_DISPLAY_ORDER,
				     P_MANDATORY_FLAG,

				     fnd_global.user_id,
				     fnd_global.user_id,
				     sysdate,
				     sysdate,
				     fnd_global.user_id,

				     P_DEFAULT_REGION_POSITION ,
				     P_PLACEHOLDER_REGION_FLAG ,
				     P_REGION_SOURCE_TYPE,
				     P_REGION_SOURCE_CODE,
				     P_region_style,
				     Nvl(p_start_date_active, Sysdate) ,
				     p_end_date_active,
				     P_DOCUMENT_SOURCE,
                                     p_page_function_name,
                                     p_security_function_name);


				    OPEN c1;
				    FETCH c1 INTO l_row_id;
				    IF (c1%NOTFOUND) THEN
				       CLOSE c1;
				       RAISE NO_DATA_FOUND;
				    END IF;
				    CLOSE c1;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Insert_Row');
--        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end INSERT_PAGE_TYPE_REGION_ROW;


procedure UPDATE_PAGE_TYPE_REGION_ROW (
  P_PAGE_TYPE_CODE in VARCHAR2,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,

  P_VIEW_REGION_CODE in VARCHAR2,
  P_EDIT_REGION_CODE in VARCHAR2,
  P_REGION_STYLE in VARCHAR2,
  P_DISPLAY_ORDER in NUMBER,
  P_MANDATORY_FLAG in VARCHAR2,

  P_DEFAULT_REGION_POSITION in VARCHAR2,
  P_PLACEHOLDER_REGION_FLAG in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  p_document_source IN varchar2,
  p_page_function_name IN varchar2,
  p_security_function_name IN varchar2)
  IS

   l_row_id ROWID;

   CURSOR  c1 IS
      SELECT rowid
	FROM   pa_page_type_regions
	WHERE  page_type_code = p_page_type_code
	AND region_source_type = p_region_source_type
	AND region_source_code = p_region_source_code;

BEGIN

  UPDATE PA_PAGE_TYPE_REGIONS SET
    view_region_code = P_VIEW_REGION_CODE,
    edit_region_code = P_EDIT_REGION_CODE,
    display_order = Decode(p_display_order, 1.7e20, display_order, p_display_order),
    mandatory_flag = Decode(p_mandatory_flag, '^', mandatory_flag,p_mandatory_flag ),
    default_region_position = Decode(p_default_region_position,'^', default_region_position, p_default_region_position ) ,
    placeholder_region_flag = Decode(p_placeholder_region_flag,'^', placeholder_region_flag, p_placeholder_region_flag ) ,
    region_style = Decode(P_region_style, '^', region_style, p_region_style),
    start_date_active = P_START_DATE_ACTIVE ,
    end_date_active = p_end_date_active,
    LAST_UPDATED_BY =  fnd_global.user_id,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = fnd_global.login_id,
    document_source = p_document_source,
    page_function_name = p_page_function_name,
    security_function_name = p_security_function_name
    WHERE
    page_type_code = p_page_type_code
    AND region_source_type = p_region_source_type
    AND region_source_code = p_region_source_code;

  if (sql%notfound) THEN
      raise no_data_found;
--     PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
 --    x_return_status := FND_API.G_RET_STS_ERROR;
   --  RETURN;
  end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Update_Row');
       -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end UPDATE_PAGE_TYPE_REGION_ROW;


procedure delete_page_type_REGION_ROW (
				       p_rowid IN VARCHAR2 := NULL,
				       P_PAGE_TYPE_CODE in VARCHAR2 := NULL ,
				       P_REGION_SOURCE_TYPE in VARCHAR2 := NULL ,
				       P_REGION_SOURCE_CODE in VARCHAR2  := NULL
) is
BEGIN

   IF p_rowid IS NOT NULL THEN
 delete from PA_PAGE_TYPE_REGIONS
    where rowid = p_rowid;
    ELSE

  delete from PA_PAGE_TYPE_REGIONS
    where PAGE_TYPE_CODE = p_page_type_code
    AND region_source_type = p_region_source_type
    AND region_source_code = p_region_source_code;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

--        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end DELETE_PAGE_TYPE_REGION_ROW;


END  PA_PAGE_TYPE_REGION_PKG;

/
