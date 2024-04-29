--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_REPORT_PKG" AS
--$Header: PAPRRPHB.pls 120.1 2005/08/19 16:44:58 mwasowic noship $

procedure INSERT_PROGRESS_REPORT_VER_ROW (

  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE in VARCHAR2,
  P_PAGE_STATUS in VARCHAR2,

    p_report_start_date IN DATE,
    p_report_end_date IN DATE,
    p_reported_by in NUMBER,
    p_progress_status in VARCHAR2,
    p_overview in VARCHAR2,
    p_current_flag in VARCHAR2,
    p_published_date IN DATE,
    p_comments in VARCHAR2,
    p_canceled_date IN DATE,
    p_report_type_id IN NUMBER,
    X_VERSION_ID                  out NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                    OUT    NOCOPY VARCHAR2			    --File.Sql.39 bug 4440895
) is

   l_version_id NUMBER;
   l_rowid ROWID;

   cursor C is select ROWID from PA_PROGRESS_REPORT_VERS
    where VERSION_ID = l_VERSION_ID
    ;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --SELECT pa_object_page_versions_s.NEXTVAL
  --INTO   l_version_id
  --  FROM   dual;


  insert into PA_PROGRESS_REPORT_VERS (
    OBJECT_ID,
    OBJECT_TYPE,
    PAGE_ID,
    VERSION_ID,
    PAGE_TYPE_CODE,
    REPORT_STATUS_CODE,

    report_start_date,
    report_end_date,
    reported_by,
    progress_status_code,
    overview,
    current_flag,
    published_date,
    comments,
    canceled_date,
    report_Type_id,


    RECORD_VERSION_NUMBER,
    summary_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (
    P_OBJECT_ID,
    P_OBJECT_TYPE,
    P_PAGE_ID,
    pa_progress_report_vers_s.NEXTVAL,
    P_PAGE_TYPE,
    P_PAGE_STATUS,

    p_report_start_date,
    p_report_end_date,
    p_reported_by,
    p_progress_status,
    p_overview,
    p_current_flag,
    p_published_date,
    p_comments,
    p_canceled_date,
    p_report_Type_id,
    1,
    1,
    fnd_global.user_id,
    fnd_global.user_id,
    sysdate,
    sysdate,
    fnd_global.user_id) returning version_id INTO l_version_id;

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  x_version_id := l_version_id;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end INSERT_PROGRESS_REPORT_VER_ROW;

procedure UPDATE_PROGRESS_REPORT_VER_ROW (
  P_VERSION_ID in NUMBER,
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE in VARCHAR2,
  P_PAGE_STATUS in VARCHAR2,

    p_report_start_date IN DATE,
    p_report_end_date IN DATE,
    p_reported_by in NUMBER,
    p_progress_status in VARCHAR2,
    p_overview in VARCHAR2,
    p_current_flag in VARCHAR2,
    p_published_date IN DATE,
    p_comments in VARCHAR2,
    p_canceled_date IN DATE,

  P_RECORD_VERSION_NUMBER in NUMBER,
  P_summary_VERSION_NUMBER in NUMBER,
  p_report_type_id         in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --debug_msg ('before update ');
  --debug_msg ('before update ' || To_char (p_version_id));

  update PA_PROGRESS_REPORT_VERS set
    OBJECT_ID = Nvl(p_object_id, object_id),
    OBJECT_TYPE = Nvl(p_object_type, object_type),
    PAGE_ID = Nvl(p_page_id, page_id),
    PAGE_TYPE_CODE = Nvl(p_page_type, page_type_CODE),
    REPORT_STATUS_CODE = Nvl(p_page_status, report_status_code),
    RECORD_VERSION_NUMBER = record_version_number +1,
    summary_VERSION_NUMBER = summary_version_number +1,

    report_start_date =Nvl(p_report_start_date, report_start_date) ,
    report_end_date =Nvl(p_report_end_date, report_end_date),
    reported_by =Nvl(p_reported_by, reported_by),
    progress_status_code =Nvl(p_progress_status, progress_status_code),
    overview = decode(p_overview,FND_API.G_MISS_CHAR,null,nvl(p_overview,overview)),		-- Bug 3877982
   -- overview=Nvl(p_overview,overview),
    current_flag =Nvl(p_current_flag, current_flag),
    published_date=Nvl(p_published_date, published_date),
    comments =Nvl(p_comments, comments),
    canceled_date = Nvl(p_canceled_date, canceled_date),
    report_Type_id = nvl(p_report_Type_id,report_Type_id),

    LAST_UPDATED_BY =  fnd_global.user_id,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = fnd_global.login_id
    where VERSION_ID = p_version_id
    AND record_version_number = Nvl(p_record_version_number, record_version_number)
    AND summary_version_number = Nvl(p_summary_version_number, summary_version_number);

  --debug_msg ('after update ');
  if (sql%notfound) THEN
     -- debug_msg ('failed after update ');
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_PROGRESS_REPORT_VER_ROW;



procedure DELETE_PROGRESS_REPORT_VER_ROW (
  P_VERSION_ID in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2	       --File.Sql.39 bug 4440895
) is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PA_PROGRESS_REPORT_VERS
  where VERSION_ID = p_version_id AND record_version_number = nvl(p_record_version_number, record_version_number);

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end DELETE_PROGRESS_REPORT_VER_ROW;


procedure INSERT_PROGRESS_REPORT_VAL_ROW (
  P_VERSION_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_CODE in VARCHAR2,
  P_RECORD_SEQUENCE in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE16 in VARCHAR2,
  P_ATTRIBUTE17 in VARCHAR2,
  P_ATTRIBUTE18 in VARCHAR2,
  P_ATTRIBUTE19 in VARCHAR2,
  P_ATTRIBUTE20 in VARCHAR2,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_UDS_ATTRIBUTE1 in VARCHAR2,
  P_UDS_ATTRIBUTE2 in VARCHAR2,
  P_UDS_ATTRIBUTE3 in VARCHAR2,
  P_UDS_ATTRIBUTE4 in VARCHAR2,
  P_UDS_ATTRIBUTE5 in VARCHAR2,
  P_UDS_ATTRIBUTE6 in VARCHAR2,
  P_UDS_ATTRIBUTE7 in VARCHAR2,
  P_UDS_ATTRIBUTE8 in VARCHAR2,
  P_UDS_ATTRIBUTE9 in VARCHAR2,
  P_UDS_ATTRIBUTE10 in VARCHAR2,
  P_UDS_ATTRIBUTE11 in VARCHAR2,
  P_UDS_ATTRIBUTE12 in VARCHAR2,
  P_UDS_ATTRIBUTE13 in VARCHAR2,
  P_UDS_ATTRIBUTE14 in VARCHAR2,
  P_UDS_ATTRIBUTE15 in VARCHAR2,
  P_UDS_ATTRIBUTE16 in VARCHAR2,
  P_UDS_ATTRIBUTE17 in VARCHAR2,
  P_UDS_ATTRIBUTE18 in VARCHAR2,
  P_UDS_ATTRIBUTE19 in VARCHAR2,
  P_UDS_ATTRIBUTE20 in VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2				      --File.Sql.39 bug 4440895
) is

   l_rowid ROWID;
   l_record_sequence NUMBER;

   cursor C is select ROWID from PA_PROGRESS_REPORT_VALS
    where VERSION_ID = P_VERSION_ID
    and REGION_SOURCE_TYPE = P_REGION_SOURCE_TYPE
    and REGION_CODE = P_REGION_CODE
     and RECORD_SEQUENCE = L_RECORD_SEQUENCE;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;


  insert into PA_PROGRESS_REPORT_VALS (
    VERSION_ID,
    REGION_SOURCE_TYPE,
    REGION_CODE,
    RECORD_SEQUENCE,
    RECORD_VERSION_NUMBER,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    UDS_ATTRIBUTE_CATEGORY,
    UDS_ATTRIBUTE1,
    UDS_ATTRIBUTE2,
    UDS_ATTRIBUTE3,
    UDS_ATTRIBUTE4,
    UDS_ATTRIBUTE5,
    UDS_ATTRIBUTE6,
    UDS_ATTRIBUTE7,
    UDS_ATTRIBUTE8,
    UDS_ATTRIBUTE9,
    UDS_ATTRIBUTE10,
    UDS_ATTRIBUTE11,
    UDS_ATTRIBUTE12,
    UDS_ATTRIBUTE13,
    UDS_ATTRIBUTE14,
    UDS_ATTRIBUTE15,
    UDS_ATTRIBUTE16,
    UDS_ATTRIBUTE17,
    UDS_ATTRIBUTE18,
    UDS_ATTRIBUTE19,
    UDS_ATTRIBUTE20,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    last_update_login
  ) VALUES(
    P_VERSION_ID,
    P_REGION_SOURCE_TYPE,
    P_REGION_CODE,
    pa_progress_report_vers_s.NEXTVAL,
    1,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15,
    P_ATTRIBUTE16,
    P_ATTRIBUTE17,
    P_ATTRIBUTE18,
    P_ATTRIBUTE19,
    P_ATTRIBUTE20,
    P_UDS_ATTRIBUTE_CATEGORY,
    P_UDS_ATTRIBUTE1,
    P_UDS_ATTRIBUTE2,
    P_UDS_ATTRIBUTE3,
    P_UDS_ATTRIBUTE4,
    P_UDS_ATTRIBUTE5,
    P_UDS_ATTRIBUTE6,
    P_UDS_ATTRIBUTE7,
    P_UDS_ATTRIBUTE8,
    P_UDS_ATTRIBUTE9,
    P_UDS_ATTRIBUTE10,
    P_UDS_ATTRIBUTE11,
    P_UDS_ATTRIBUTE12,
    P_UDS_ATTRIBUTE13,
    P_UDS_ATTRIBUTE14,
    P_UDS_ATTRIBUTE15,
    P_UDS_ATTRIBUTE16,
    P_UDS_ATTRIBUTE17,
    P_UDS_ATTRIBUTE18,
    P_UDS_ATTRIBUTE19,
    P_UDS_ATTRIBUTE20,
    fnd_global.user_id,
    fnd_global.user_id,
    sysdate,
    sysdate,
    fnd_global.user_id) returning record_sequence INTO L_RECORD_SEQUENCE;


  open c;
  fetch c into l_ROWID;
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

end INSERT_PROGRESS_REPORT_VAL_ROW;

procedure UPDATE_PROGRESS_REPORT_VAL_ROW (
  P_VERSION_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_CODE in VARCHAR2,
  P_RECORD_SEQUENCE in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE16 in VARCHAR2,
  P_ATTRIBUTE17 in VARCHAR2,
  P_ATTRIBUTE18 in VARCHAR2,
  P_ATTRIBUTE19 in VARCHAR2,
  P_ATTRIBUTE20 in VARCHAR2,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_UDS_ATTRIBUTE1 in VARCHAR2,
  P_UDS_ATTRIBUTE2 in VARCHAR2,
  P_UDS_ATTRIBUTE3 in VARCHAR2,
  P_UDS_ATTRIBUTE4 in VARCHAR2,
  P_UDS_ATTRIBUTE5 in VARCHAR2,
  P_UDS_ATTRIBUTE6 in VARCHAR2,
  P_UDS_ATTRIBUTE7 in VARCHAR2,
  P_UDS_ATTRIBUTE8 in VARCHAR2,
  P_UDS_ATTRIBUTE9 in VARCHAR2,
  P_UDS_ATTRIBUTE10 in VARCHAR2,
  P_UDS_ATTRIBUTE11 in VARCHAR2,
  P_UDS_ATTRIBUTE12 in VARCHAR2,
  P_UDS_ATTRIBUTE13 in VARCHAR2,
  P_UDS_ATTRIBUTE14 in VARCHAR2,
  P_UDS_ATTRIBUTE15 in VARCHAR2,
  P_UDS_ATTRIBUTE16 in VARCHAR2,
  P_UDS_ATTRIBUTE17 in VARCHAR2,
  P_UDS_ATTRIBUTE18 in VARCHAR2,
  P_UDS_ATTRIBUTE19 in VARCHAR2,
  P_UDS_ATTRIBUTE20 in VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
begin

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --debug_msg ('***********update attribute 3: ' ||P_ATTRIBUTE3 );

   update PA_PROGRESS_REPORT_VALS set
    RECORD_VERSION_NUMBER = record_version_number +1,

    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    ATTRIBUTE6 = P_ATTRIBUTE6,
    ATTRIBUTE7 = P_ATTRIBUTE7,
    ATTRIBUTE8 = P_ATTRIBUTE8,
    ATTRIBUTE9 = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    ATTRIBUTE11 = P_ATTRIBUTE11,
    ATTRIBUTE12 = P_ATTRIBUTE12,
    ATTRIBUTE13 = P_ATTRIBUTE13,
    ATTRIBUTE14 = P_ATTRIBUTE14,
    ATTRIBUTE15 = P_ATTRIBUTE15,
    ATTRIBUTE16 = P_ATTRIBUTE16,
    ATTRIBUTE17 = P_ATTRIBUTE17,
    ATTRIBUTE18 = P_ATTRIBUTE18,
    ATTRIBUTE19 = P_ATTRIBUTE19,
    ATTRIBUTE20 = P_ATTRIBUTE20,
    UDS_ATTRIBUTE_CATEGORY = P_UDS_ATTRIBUTE_CATEGORY,
    UDS_ATTRIBUTE1 = P_UDS_ATTRIBUTE1,
    UDS_ATTRIBUTE2 = P_UDS_ATTRIBUTE2,
    UDS_ATTRIBUTE3 = P_UDS_ATTRIBUTE3,
    UDS_ATTRIBUTE4 = P_UDS_ATTRIBUTE4,
    UDS_ATTRIBUTE5 = P_UDS_ATTRIBUTE5,
    UDS_ATTRIBUTE6 = P_UDS_ATTRIBUTE6,
    UDS_ATTRIBUTE7 = P_UDS_ATTRIBUTE7,
    UDS_ATTRIBUTE8 = P_UDS_ATTRIBUTE8,
    UDS_ATTRIBUTE9 = P_UDS_ATTRIBUTE9,
    UDS_ATTRIBUTE10 = P_UDS_ATTRIBUTE10,
    UDS_ATTRIBUTE11 = P_UDS_ATTRIBUTE11,
    UDS_ATTRIBUTE12 = P_UDS_ATTRIBUTE12,
    UDS_ATTRIBUTE13 = P_UDS_ATTRIBUTE13,
    UDS_ATTRIBUTE14 = P_UDS_ATTRIBUTE13,
    UDS_ATTRIBUTE15 = P_UDS_ATTRIBUTE13,
    UDS_ATTRIBUTE16 = P_UDS_ATTRIBUTE14,
    UDS_ATTRIBUTE17 = P_UDS_ATTRIBUTE14,
    UDS_ATTRIBUTE18 = P_UDS_ATTRIBUTE15,
    UDS_ATTRIBUTE19 = P_UDS_ATTRIBUTE16,
    UDS_ATTRIBUTE20 = P_UDS_ATTRIBUTE17,
    LAST_UPDATED_BY =  fnd_global.user_id,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = fnd_global.login_id
     WHERE VERSION_ID = P_VERSION_ID
     AND region_source_type = p_region_source_type
     AND region_code = p_region_code
     AND record_sequence = p_record_sequence;


   if (sql%notfound) THEN

      --debug_msg ('***********update failed');
      PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
      x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end UPDATE_PROGRESS_REPORT_VAL_ROW;

procedure DELETE_PROGRESS_REPORT_VAL_ROW (
  P_VERSION_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_CODE in VARCHAR2,
  P_RECORD_SEQUENCE in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			      --File.Sql.39 bug 4440895
) is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PA_PROGRESS_REPORT_VALS
  where VERSION_ID = P_VERSION_ID
  and REGION_SOURCE_TYPE = P_REGION_SOURCE_TYPE
  and REGION_CODE = P_REGION_CODE
  and RECORD_SEQUENCE = p_record_sequence
  AND nvl(p_record_version_number, record_version_number) = record_version_number;


  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end DELETE_PROGRESS_REPORT_VAL_ROW;

procedure DELETE_PROGRESS_REPORT_VALS (
  P_VERSION_ID in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			      --File.Sql.39 bug 4440895
) is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PA_PROGRESS_REPORT_VALS
  where VERSION_ID = p_version_id;



  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end DELETE_PROGRESS_REPORT_VALS;

procedure DELETE_PROGRESS_REPORT_REGION (
  P_VERSION_ID in NUMBER,
  p_region_source_type IN VARCHAR2,
  p_region_code IN VARCHAR2,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			      --File.Sql.39 bug 4440895
) is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PA_PROGRESS_REPORT_VALS
    where VERSION_ID = p_version_id
    AND region_source_type = p_region_source_type
    AND region_code = p_region_code;



  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end DELETE_PROGRESS_REPORT_REGION;

procedure INSERT_OBJECT_PAGE_LAYOUT_ROW (

  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE_CODE in VARCHAR2,

  P_APPROVAL_REQUIRED in VARCHAR2,
--  P_AUTO_PUBLISH in VARCHAR2,
  P_REPORTING_CYCLE_ID in NUMBER,
  P_REPORTING_OFFSET_DAYS in NUMBER,
  P_NEXT_REPORTING_DATE in DATE,
  P_REMINDER_DAYS in NUMBER,
  P_REMINDER_DAYS_TYPE in VARCHAR2,
  P_INITIAL_PROGRESS_STATUS in VARCHAR2,
  P_FINAL_PROGRESS_STATUS in VARCHAR2,
  P_ROLLUP_PROGRESS_STATUS in VARCHAR2,
  p_report_type_id              IN     NUMBER,
  p_approver_source_id          IN     NUMBER,
  p_approver_source_type        IN     NUMBER,
  p_effective_from              IN     DATE,
  p_effective_to                IN     DATE,
  p_function_name		IN     VARCHAR2,
  x_object_page_layout_id       OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			    --File.Sql.39 bug 4440895
) is

   l_version_id NUMBER;
   l_rowid ROWID;
   l_layout_id NUMBER;

   cursor C is select ROWID from PA_OBJECT_PAGE_LAYOUTS
     where object_Page_Layout_id = l_layout_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --get the unique task id from the Oracle Sequence
  SELECT pa_object_page_layouts_s.nextval
  INTO l_layout_id
  FROM DUAL;


  insert into PA_OBJECT_PAGE_LAYOUTS (
    OBJECT_ID,
    OBJECT_TYPE,
    PAGE_ID,
    PAGE_TYPE_CODE,

    APPROVAL_REQUIRED ,
    --AUTO_PUBLISH ,
    REPORTING_CYCLE_ID ,
    REPORT_OFFSET_DAYS ,
    NEXT_REPORTING_DATE ,
    REMINDER_DAYS ,
    REMINDER_DAYS_TYPE ,
    INITIAL_PROGRESS_STATUS,
    FINAL_PROGRESS_STATUS,
    ROLLUP_PROGRESS_STATUS,

    RECORD_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    object_page_layout_id,
    report_type_id,
    approver_source_id,
    approver_source_type,
    effective_from,
    effective_to,
    pers_function_name

  ) VALUES (
    P_OBJECT_ID,
    P_OBJECT_TYPE,
    P_PAGE_ID,
    P_PAGE_TYPE_CODE,

    P_APPROVAL_REQUIRED ,
    --P_AUTO_PUBLISH ,
    P_REPORTING_CYCLE_ID ,
    P_REPORTING_OFFSET_DAYS ,
    P_NEXT_REPORTING_DATE ,
    P_REMINDER_DAYS ,
    P_REMINDER_DAYS_TYPE ,
    P_INITIAL_PROGRESS_STATUS,
    P_FINAL_PROGRESS_STATUS,
    P_ROLLUP_PROGRESS_STATUS,

    1,
    fnd_global.user_id,
    fnd_global.user_id,
    sysdate,
    sysdate,
    fnd_global.user_id,
    l_layout_id,
    p_report_type_id,
    p_approver_source_id,
    p_approver_source_type,
    p_effective_from,
    p_effective_to,
    p_function_name);


  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  x_object_page_layout_id := l_layout_id;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end INSERT_OBJECT_PAGE_LAYOUT_ROW;

procedure UPDATE_OBJECT_PAGE_LAYOUT_ROW (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE_CODE in VARCHAR2,

  P_APPROVAL_REQUIRED in VARCHAR2,
  --P_AUTO_PUBLISH in VARCHAR2,
  P_REPORTING_CYCLE_ID in NUMBER,
  P_REPORTING_OFFSET_DAYS in NUMBER,
  P_NEXT_REPORTING_DATE in DATE,
  P_REMINDER_DAYS in NUMBER,
  P_REMINDER_DAYS_TYPE in VARCHAR2,
  P_INITIAL_PROGRESS_STATUS in VARCHAR2,
  P_FINAL_PROGRESS_STATUS in VARCHAR2,
  P_ROLLUP_PROGRESS_STATUS in VARCHAR2,

  p_report_type_id              IN     NUMBER,
  p_approver_source_id          IN     NUMBER,
  p_approver_source_type        IN     NUMBER,
  p_effective_from              IN     DATE,
  p_effective_to                IN     DATE,
  p_object_page_layout_id       IN     NUMBER,

  p_record_version_number	IN NUMBER,
  p_function_name		IN     VARCHAR2,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  update PA_OBJECT_PAGE_LAYOUTS set
    OBJECT_ID = Nvl(p_object_id, object_id),
    OBJECT_TYPE = Nvl(p_object_type, object_type),
    PAGE_ID = Nvl(p_page_id, page_id),
    PAGE_TYPE_CODE = Nvl(p_page_type_code, page_type_CODE),

    RECORD_VERSION_NUMBER = record_version_number +1,

    approval_required = P_APPROVAL_REQUIRED ,
    --auto_publish = P_AUTO_PUBLISH ,
    reporting_cycle_id = P_REPORTING_CYCLE_ID ,
    report_offset_days = P_REPORTING_OFFSET_DAYS ,
    next_reporting_date = P_NEXT_REPORTING_DATE ,
    reminder_days = P_REMINDER_DAYS ,
    reminder_days_type = P_REMINDER_DAYS_TYPE ,
    initial_progress_status = P_INITIAL_PROGRESS_STATUS,
    final_progress_status = P_FINAL_PROGRESS_STATUS,
    rollup_progress_status = P_ROLLUP_PROGRESS_STATUS,

    report_type_id          = p_report_type_id,
    approver_source_id      = p_approver_source_id,
    approver_source_type    = p_approver_source_type,
    effective_from          = p_effective_from,
    effective_to            = p_effective_to,
    pers_function_name	    =   p_function_name,
    LAST_UPDATED_BY =  fnd_global.user_id,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = fnd_global.login_id
    where object_page_layout_ID = p_object_page_layout_id
    AND record_version_number = Nvl(p_record_version_number, record_version_number);

   if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_OBJECT_PAGE_LAYOUT_ROW;



procedure DELETE_OBJECT_PAGE_LAYOUTS (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM  PA_OBJECT_PAGE_LAYOUTS
    where object_ID = p_object_id
    AND object_type = p_object_type;


EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_OBJECT_PAGE_LAYOUTS;

END  PA_PROGRESS_REPORT_PKG;

/
