--------------------------------------------------------
--  DDL for Package Body PA_REPORT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REPORT_TYPES_PKG" AS
--$Header: PARTYPHB.pls 120.1 2005/08/19 17:02:24 mwasowic noship $


procedure INSERT_ROW (
  P_NAME                    IN VARCHAR2,
  P_PAGE_ID                 IN NUMBER,
  P_OVERRIDE_PAGE_LAYOUT    IN VARCHAR2,
  P_DESCRIPTION             IN VARCHAR2,
  P_GENERATION_METHOD       IN VARCHAR2,
  P_START_DATE_ACTIVE       IN DATE,
  P_END_DATE_ACTIVE         IN DATE,
  p_LAST_UPDATED_BY         IN NUMBER,
  p_CREATED_BY              IN NUMBER,
  p_LAST_UPDATE_LOGIN       IN NUMBER,
  x_report_type_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
)
  IS

   l_row_id ROWID;

   CURSOR  c1 IS
      SELECT rowid
	FROM   pa_report_Types
	WHERE  report_type_id = x_report_type_id;

begin

   insert into PA_REPORT_TYPES (
    REPORT_TYPE_ID,
    NAME,
    PAGE_ID,
    OVERRIDE_PAGE_LAYOUT,
    DESCRIPTION,
    GENERATION_METHOD,
    START_DATE_active,
    END_DATE_active,
    RECORD_VERSION_NUMBER,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
  VALUES
  (
     pa_report_types_s.NEXTVAL,
     P_NAME,
     P_PAGE_ID,
     P_OVERRIDE_PAGE_LAYOUT,
     P_DESCRIPTION,
     P_GENERATION_METHOD,
     P_START_DATE_ACTIVE,
     P_END_DATE_ACTIVE,
     1,
     sysdate,
     sysdate,
     p_LAST_UPDATED_BY,
     p_CREATED_BY,
     p_LAST_UPDATE_LOGIN) returning report_type_id INTO x_report_type_id;

 OPEN c1;
  FETCH c1 INTO l_row_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c1;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        RAISE;
end INSERT_ROW;

procedure UPDATE_ROW (
  P_REPORT_TYPE_ID          IN NUMBER,
  P_NAME                    IN VARCHAR2,
  P_PAGE_ID                 IN NUMBER,
  P_OVERRIDE_PAGE_LAYOUT    IN VARCHAR2,
  P_DESCRIPTION             IN VARCHAR2,
  P_GENERATION_METHOD       IN VARCHAR2,
  P_START_DATE_ACTIVE       IN DATE,
  P_END_DATE_ACTIVE         IN DATE,
  P_RECORD_VERSION_NUMBER   IN NUMBER,
  P_Last_Updated_By         IN NUMBER,
  P_LAST_UPDATE_LOGIN       IN NUMBER,
  x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  update PA_REPORT_TYPES set
    NAME = decode(P_NAME,'^',name,p_name),
    PAGE_ID = decode(p_page_id,'-99',page_id,p_page_id),
    OVERRIDE_PAGE_LAYOUT = decode(p_OVERRIDE_PAGE_LAYOUT,'^',OVERRIDE_PAGE_LAYOUT,p_OVERRIDE_PAGE_LAYOUT),
    DESCRIPTION = decode(P_DESCRIPTION,'^',DESCRIPTION,P_DESCRIPTION),
    GENERATION_METHOD = P_GENERATION_METHOD,
    START_DATE_active = P_START_DATE_ACTIVE,
    END_DATE_active = P_END_DATE_ACTIVE,
    RECORD_VERSION_NUMBER = p_record_version_number + 1,

    LAST_UPDATED_BY =  P_Last_Updated_By,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where REPORT_TYPE_ID = p_report_type_id;


  if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
  end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end UPDATE_ROW;

procedure DELETE_ROW (
		      P_REPORT_TYPE_ID in NUMBER,
                      P_RECORD_VERSION_NUMBER in NUMBER,

		      x_return_status      OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PA_REPORT_TYPES
    where REPORT_TYPE_ID = p_report_type_id
    AND    nvl(p_record_version_number, record_version_number) = record_version_number;


  IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA', p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_ROW;


END  PA_REPORT_TYPES_PKG;

/
