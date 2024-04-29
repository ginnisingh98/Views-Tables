--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT_PROGRAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT_PROGRAMS_PKG" as
/* $Header: AFCPMCPB.pls 120.3.12010000.3 2014/01/17 21:21:34 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_EXECUTABLE_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_ARGUMENT_METHOD_CODE in VARCHAR2,
  X_QUEUE_CONTROL_FLAG in VARCHAR2,
  X_QUEUE_METHOD_CODE in VARCHAR2,
  X_REQUEST_SET_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRINT_FLAG in VARCHAR2,
  X_RUN_ALONE_FLAG in VARCHAR2,
  X_SRS_FLAG in VARCHAR2,
  X_CLASS_APPLICATION_ID in NUMBER,
  X_CONCURRENT_CLASS_ID in NUMBER,
  X_EXECUTION_OPTIONS in VARCHAR2,
  X_SAVE_OUTPUT_FLAG in VARCHAR2,
  X_REQUIRED_STYLE in VARCHAR2,
  X_OUTPUT_PRINT_STYLE in VARCHAR2,
  X_PRINTER_NAME in VARCHAR2,
  X_MINIMUM_WIDTH in NUMBER,
  X_MINIMUM_LENGTH in NUMBER,
  X_REQUEST_PRIORITY in NUMBER,
  X_OUTPUT_FILE_TYPE in VARCHAR2,
  X_RESTART in VARCHAR2,
  X_NLS_COMPLIANT in VARCHAR2,
  X_ENABLE_TRACE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_CD_PARAMETER in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_INCREMENT_PROC in VARCHAR2,
  X_MLS_EXECUTABLE_APP_ID in NUMBER,
  X_MLS_EXECUTABLE_ID in NUMBER,
  X_RESOURCE_CONSUMER_GROUP in VARCHAR2,
  X_ROLLBACK_SEGMENT in VARCHAR2,
  X_OPTIMIZER_MODE in VARCHAR2,
  X_USER_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_TIME_STATISTICS in VARCHAR2,
  X_REFRESH_PORTLET in VARCHAR2,
  X_PROGRAM_TYPE in VARCHAR2,
  X_ACTIVITY_SUMMARIZER in VARCHAR2,
  X_ALLOW_MULTIPLE_PENDING_REQUE VARCHAR2,
  X_DELETE_LOG_FILE VARCHAR2,
  X_TEMPLATE_APPL_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_MULTI_ORG_CATEGORY in VARCHAR2,
  X_RECALC_PARAMETERS in VARCHAR2
 ) is
  cursor C is select ROWID from FND_CONCURRENT_PROGRAMS
    where APPLICATION_ID = X_APPLICATION_ID
    and CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID;
begin
  insert into FND_CONCURRENT_PROGRAMS (
    APPLICATION_ID,
    CONCURRENT_PROGRAM_ID,
    CONCURRENT_PROGRAM_NAME,
    EXECUTABLE_APPLICATION_ID,
    EXECUTABLE_ID,
    EXECUTION_METHOD_CODE,
    ARGUMENT_METHOD_CODE,
    QUEUE_CONTROL_FLAG,
    QUEUE_METHOD_CODE,
    REQUEST_SET_FLAG,
    ENABLED_FLAG,
    PRINT_FLAG,
    RUN_ALONE_FLAG,
    SRS_FLAG,
    CLASS_APPLICATION_ID,
    CONCURRENT_CLASS_ID,
    EXECUTION_OPTIONS,
    SAVE_OUTPUT_FLAG,
    REQUIRED_STYLE,
    OUTPUT_PRINT_STYLE,
    PRINTER_NAME,
    MINIMUM_WIDTH,
    MINIMUM_LENGTH,
    REQUEST_PRIORITY,
    OUTPUT_FILE_TYPE,
    ENABLE_TRACE,
    RESTART,
    NLS_COMPLIANT,
    ICON_NAME,
    CD_PARAMETER,
    SECURITY_GROUP_ID,
    INCREMENT_PROC,
    MLS_EXECUTABLE_APP_ID,
    MLS_EXECUTABLE_ID,
    RESOURCE_CONSUMER_GROUP,
    ROLLBACK_SEGMENT,
    OPTIMIZER_MODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ENABLE_TIME_STATISTICS,
    REFRESH_PORTLET,
    PROGRAM_TYPE,
    ACTIVITY_SUMMARIZER,
    ALLOW_MULTIPLE_PENDING_REQUEST,
    DELETE_LOG_FILE,
    TEMPLATE_CODE,
    TEMPLATE_APPL_SHORT_NAME,
    MULTI_ORG_CATEGORY,
    RECALC_PARAMETERS
  ) values (
    X_APPLICATION_ID,
    X_CONCURRENT_PROGRAM_ID,
    X_CONCURRENT_PROGRAM_NAME,
    X_EXECUTABLE_APPLICATION_ID,
    X_EXECUTABLE_ID,
    X_EXECUTION_METHOD_CODE,
    X_ARGUMENT_METHOD_CODE,
    X_QUEUE_CONTROL_FLAG,
    X_QUEUE_METHOD_CODE,
    X_REQUEST_SET_FLAG,
    X_ENABLED_FLAG,
    X_PRINT_FLAG,
    X_RUN_ALONE_FLAG,
    X_SRS_FLAG,
    X_CLASS_APPLICATION_ID,
    X_CONCURRENT_CLASS_ID,
    X_EXECUTION_OPTIONS,
    X_SAVE_OUTPUT_FLAG,
    X_REQUIRED_STYLE,
    X_OUTPUT_PRINT_STYLE,
    X_PRINTER_NAME,
    X_MINIMUM_WIDTH,
    X_MINIMUM_LENGTH,
    X_REQUEST_PRIORITY,
    X_OUTPUT_FILE_TYPE,
    X_ENABLE_TRACE,
    X_RESTART,
    X_NLS_COMPLIANT,
    X_ICON_NAME,
    X_CD_PARAMETER,
    X_SECURITY_GROUP_ID,
    X_INCREMENT_PROC,
    X_MLS_EXECUTABLE_APP_ID,
    X_MLS_EXECUTABLE_ID,
    X_RESOURCE_CONSUMER_GROUP,
    X_ROLLBACK_SEGMENT,
    X_OPTIMIZER_MODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NVL(X_ENABLE_TIME_STATISTICS,'N'),
    X_REFRESH_PORTLET,
    X_PROGRAM_TYPE,
    X_ACTIVITY_SUMMARIZER,
    X_ALLOW_MULTIPLE_PENDING_REQUE,
    X_DELETE_LOG_FILE,
    X_TEMPLATE_CODE ,
    X_TEMPLATE_APPL_SHORT_NAME,
    X_MULTI_ORG_CATEGORY,
    X_RECALC_PARAMETERS
  );


  insert into FND_CONCURRENT_PROGRAMS_TL (
    APPLICATION_ID,
    CONCURRENT_PROGRAM_ID,
    USER_CONCURRENT_PROGRAM_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_CONCURRENT_PROGRAM_ID,
    X_USER_CONCURRENT_PROGRAM_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_CONCURRENT_PROGRAMS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_EXECUTABLE_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_ARGUMENT_METHOD_CODE in VARCHAR2,
  X_QUEUE_CONTROL_FLAG in VARCHAR2,
  X_QUEUE_METHOD_CODE in VARCHAR2,
  X_REQUEST_SET_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRINT_FLAG in VARCHAR2,
  X_RUN_ALONE_FLAG in VARCHAR2,
  X_SRS_FLAG in VARCHAR2,
  X_CLASS_APPLICATION_ID in NUMBER,
  X_CONCURRENT_CLASS_ID in NUMBER,
  X_EXECUTION_OPTIONS in VARCHAR2,
  X_SAVE_OUTPUT_FLAG in VARCHAR2,
  X_REQUIRED_STYLE in VARCHAR2,
  X_OUTPUT_PRINT_STYLE in VARCHAR2,
  X_PRINTER_NAME in VARCHAR2,
  X_MINIMUM_WIDTH in NUMBER,
  X_MINIMUM_LENGTH in NUMBER,
  X_REQUEST_PRIORITY in NUMBER,
  X_OUTPUT_FILE_TYPE in VARCHAR2,
  X_RESTART in VARCHAR2,
  X_NLS_COMPLIANT in VARCHAR2,
  X_ENABLE_TRACE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_CD_PARAMETER in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_INCREMENT_PROC in VARCHAR2,
  X_MLS_EXECUTABLE_APP_ID in NUMBER,
  X_MLS_EXECUTABLE_ID in NUMBER,
  X_RESOURCE_CONSUMER_GROUP in VARCHAR2,
  X_ROLLBACK_SEGMENT in VARCHAR2,
  X_OPTIMIZER_MODE in VARCHAR2,
  X_USER_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENABLE_TIME_STATISTICS in VARCHAR2,
  X_REFRESH_PORTLET in VARCHAR2,
  X_PROGRAM_TYPE in VARCHAR2,
  X_ACTIVITY_SUMMARIZER in VARCHAR2,
  X_ALLOW_MULTIPLE_PENDING_REQUE VARCHAR2,
  X_DELETE_LOG_FILE VARCHAR2,
  X_TEMPLATE_APPL_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_MULTI_ORG_CATEGORY in VARCHAR2,
  X_RECALC_PARAMETERS in VARCHAR2
) is
  cursor c is select
      CONCURRENT_PROGRAM_NAME,
      EXECUTABLE_APPLICATION_ID,
      EXECUTABLE_ID,
      EXECUTION_METHOD_CODE,
      ARGUMENT_METHOD_CODE,
      QUEUE_CONTROL_FLAG,
      QUEUE_METHOD_CODE,
      REQUEST_SET_FLAG,
      ENABLED_FLAG,
      PRINT_FLAG,
      RUN_ALONE_FLAG,
      SRS_FLAG,
      CLASS_APPLICATION_ID,
      CONCURRENT_CLASS_ID,
      EXECUTION_OPTIONS,
      SAVE_OUTPUT_FLAG,
      REQUIRED_STYLE,
      OUTPUT_PRINT_STYLE,
      PRINTER_NAME,
      MINIMUM_WIDTH,
      MINIMUM_LENGTH,
      REQUEST_PRIORITY,
      OUTPUT_FILE_TYPE,
      RESTART,
      NLS_COMPLIANT,
      ENABLE_TRACE,
      ICON_NAME,
      CD_PARAMETER,
      SECURITY_GROUP_ID,
      INCREMENT_PROC,
      MLS_EXECUTABLE_APP_ID,
      MLS_EXECUTABLE_ID,
      RESOURCE_CONSUMER_GROUP,
      ROLLBACK_SEGMENT,
      OPTIMIZER_MODE,
      ENABLE_TIME_STATISTICS,
      REFRESH_PORTLET,
      PROGRAM_TYPE,
      ACTIVITY_SUMMARIZER,
      ALLOW_MULTIPLE_PENDING_REQUEST,
      DELETE_LOG_FILE,
      TEMPLATE_CODE,
      TEMPLATE_APPL_SHORT_NAME,
      MULTI_ORG_CATEGORY,
      RECALC_PARAMETERS
    from FND_CONCURRENT_PROGRAMS
    where APPLICATION_ID = X_APPLICATION_ID
    and CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_CONCURRENT_PROGRAM_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_CONCURRENT_PROGRAMS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CONCURRENT_PROGRAM_NAME = X_CONCURRENT_PROGRAM_NAME)
      AND (recinfo.EXECUTABLE_APPLICATION_ID = X_EXECUTABLE_APPLICATION_ID)
      AND (recinfo.EXECUTABLE_ID = X_EXECUTABLE_ID)
      AND (recinfo.EXECUTION_METHOD_CODE = X_EXECUTION_METHOD_CODE)
      AND (recinfo.ARGUMENT_METHOD_CODE = X_ARGUMENT_METHOD_CODE)
      AND (recinfo.QUEUE_CONTROL_FLAG = X_QUEUE_CONTROL_FLAG)
      AND (recinfo.QUEUE_METHOD_CODE = X_QUEUE_METHOD_CODE)
      AND (recinfo.REQUEST_SET_FLAG = X_REQUEST_SET_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.PRINT_FLAG = X_PRINT_FLAG)
      AND (recinfo.RUN_ALONE_FLAG = X_RUN_ALONE_FLAG)
      AND (recinfo.SRS_FLAG = X_SRS_FLAG)
      AND ((recinfo.CLASS_APPLICATION_ID = X_CLASS_APPLICATION_ID)
           OR ((recinfo.CLASS_APPLICATION_ID is null) AND (X_CLASS_APPLICATION_ID is null)))
      AND ((recinfo.CONCURRENT_CLASS_ID = X_CONCURRENT_CLASS_ID)
           OR ((recinfo.CONCURRENT_CLASS_ID is null) AND (X_CONCURRENT_CLASS_ID is null)))
      AND ((recinfo.EXECUTION_OPTIONS = X_EXECUTION_OPTIONS)
           OR ((recinfo.EXECUTION_OPTIONS is null) AND (X_EXECUTION_OPTIONS is null)))
      AND ((recinfo.SAVE_OUTPUT_FLAG = X_SAVE_OUTPUT_FLAG)
           OR ((recinfo.SAVE_OUTPUT_FLAG is null) AND (X_SAVE_OUTPUT_FLAG is null)))
      AND (recinfo.REQUIRED_STYLE = X_REQUIRED_STYLE)
      AND ((recinfo.OUTPUT_PRINT_STYLE = X_OUTPUT_PRINT_STYLE)
           OR ((recinfo.OUTPUT_PRINT_STYLE is null) AND (X_OUTPUT_PRINT_STYLE is null)))
      AND ((recinfo.PRINTER_NAME = X_PRINTER_NAME)
           OR ((recinfo.PRINTER_NAME is null) AND (X_PRINTER_NAME is null)))
      AND ((recinfo.MINIMUM_WIDTH = X_MINIMUM_WIDTH)
           OR ((recinfo.MINIMUM_WIDTH is null) AND (X_MINIMUM_WIDTH is null)))
      AND ((recinfo.MINIMUM_LENGTH = X_MINIMUM_LENGTH)
           OR ((recinfo.MINIMUM_LENGTH is null) AND (X_MINIMUM_LENGTH is null)))
      AND ((recinfo.REQUEST_PRIORITY = X_REQUEST_PRIORITY)
           OR ((recinfo.REQUEST_PRIORITY is null) AND (X_REQUEST_PRIORITY is null)))
      AND ((recinfo.OUTPUT_FILE_TYPE = X_OUTPUT_FILE_TYPE)
           OR ((recinfo.OUTPUT_FILE_TYPE is null) AND (X_OUTPUT_FILE_TYPE is null)))
      AND (recinfo.ENABLE_TRACE = X_ENABLE_TRACE)
      AND (recinfo.RESTART = X_RESTART)
      AND (recinfo.NLS_COMPLIANT = X_NLS_COMPLIANT)
      AND ((recinfo.ICON_NAME = X_ICON_NAME)
           OR ((recinfo.ICON_NAME is null) AND (X_ICON_NAME is null)))
      AND ((recinfo.CD_PARAMETER = X_CD_PARAMETER)
           OR ((recinfo.CD_PARAMETER is null) AND (X_CD_PARAMETER is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.INCREMENT_PROC = X_INCREMENT_PROC)
           OR ((recinfo.INCREMENT_PROC is null) AND (X_INCREMENT_PROC is null)))
      AND ((recinfo.MLS_EXECUTABLE_APP_ID = X_MLS_EXECUTABLE_APP_ID)
           OR ((recinfo.MLS_EXECUTABLE_APP_ID is null) AND (X_MLS_EXECUTABLE_APP_ID is null)))
      AND ((recinfo.MLS_EXECUTABLE_ID = X_MLS_EXECUTABLE_ID)
           OR ((recinfo.MLS_EXECUTABLE_ID is null) AND (X_MLS_EXECUTABLE_ID is null)))
      AND ((recinfo.RESOURCE_CONSUMER_GROUP = X_RESOURCE_CONSUMER_GROUP)
           OR ((recinfo.RESOURCE_CONSUMER_GROUP is null) AND (X_RESOURCE_CONSUMER_GROUP is null)))
      AND ((recinfo.ROLLBACK_SEGMENT = X_ROLLBACK_SEGMENT)
           OR ((recinfo.ROLLBACK_SEGMENT is null) AND (X_ROLLBACK_SEGMENT is null)))
      AND ((recinfo.OPTIMIZER_MODE = X_OPTIMIZER_MODE)
           OR ((recinfo.OPTIMIZER_MODE is null) AND (X_OPTIMIZER_MODE is null)))
      AND ((recinfo.ENABLE_TIME_STATISTICS = X_ENABLE_TIME_STATISTICS)
           OR ((recinfo.ENABLE_TIME_STATISTICS is null) AND (X_ENABLE_TIME_STATISTICS is null)))
      AND ((recinfo.REFRESH_PORTLET = X_REFRESH_PORTLET)
           OR ((recinfo.REFRESH_PORTLET is null) AND (X_REFRESH_PORTLET is null)))
      AND ((recinfo.PROGRAM_TYPE = X_PROGRAM_TYPE)
           OR ((recinfo.PROGRAM_TYPE is null) AND (X_PROGRAM_TYPE is null)))
      AND ((recinfo.ACTIVITY_SUMMARIZER = X_ACTIVITY_SUMMARIZER)
           OR ((recinfo.ACTIVITY_SUMMARIZER is null) AND (X_ACTIVITY_SUMMARIZER is null)))
      AND ((recinfo.ALLOW_MULTIPLE_PENDING_REQUEST = X_ALLOW_MULTIPLE_PENDING_REQUE)
           OR ((recinfo.ALLOW_MULTIPLE_PENDING_REQUEST is null) AND (X_ALLOW_MULTIPLE_PENDING_REQUE is null)))
      AND ((recinfo.DELETE_LOG_FILE = X_DELETE_LOG_FILE)
           OR ((recinfo.DELETE_LOG_FILE is null) AND (X_DELETE_LOG_FILE is null)))
      AND ((recinfo.TEMPLATE_CODE = X_TEMPLATE_CODE)
           OR ((recinfo.TEMPLATE_CODE is null) AND (X_TEMPLATE_CODE is null)))
      AND ((recinfo.TEMPLATE_APPL_SHORT_NAME = X_TEMPLATE_APPL_SHORT_NAME)
           OR ((recinfo.TEMPLATE_APPL_SHORT_NAME is null) AND (X_TEMPLATE_APPL_SHORT_NAME is null)))
      AND ((recinfo.MULTI_ORG_CATEGORY = X_MULTI_ORG_CATEGORY)
           OR ((recinfo.MULTI_ORG_CATEGORY is null) AND (X_MULTI_ORG_CATEGORY is null)))
      AND ((recinfo.RECALC_PARAMETERS = X_RECALC_PARAMETERS)
           OR ((recinfo.RECALC_PARAMETERS is null) AND (X_RECALC_PARAMETERS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_CONCURRENT_PROGRAM_NAME = X_USER_CONCURRENT_PROGRAM_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_EXECUTABLE_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_ARGUMENT_METHOD_CODE in VARCHAR2,
  X_QUEUE_CONTROL_FLAG in VARCHAR2,
  X_QUEUE_METHOD_CODE in VARCHAR2,
  X_REQUEST_SET_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRINT_FLAG in VARCHAR2,
  X_RUN_ALONE_FLAG in VARCHAR2,
  X_SRS_FLAG in VARCHAR2,
  X_CLASS_APPLICATION_ID in NUMBER,
  X_CONCURRENT_CLASS_ID in NUMBER,
  X_EXECUTION_OPTIONS in VARCHAR2,
  X_SAVE_OUTPUT_FLAG in VARCHAR2,
  X_REQUIRED_STYLE in VARCHAR2,
  X_OUTPUT_PRINT_STYLE in VARCHAR2,
  X_PRINTER_NAME in VARCHAR2,
  X_MINIMUM_WIDTH in NUMBER,
  X_MINIMUM_LENGTH in NUMBER,
  X_REQUEST_PRIORITY in NUMBER,
  X_OUTPUT_FILE_TYPE in VARCHAR2,
  X_RESTART in VARCHAR2,
  X_NLS_COMPLIANT in VARCHAR2,
  X_ENABLE_TRACE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_CD_PARAMETER in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_INCREMENT_PROC in VARCHAR2,
  X_MLS_EXECUTABLE_APP_ID in NUMBER,
  X_MLS_EXECUTABLE_ID in NUMBER,
  X_RESOURCE_CONSUMER_GROUP in VARCHAR2,
  X_ROLLBACK_SEGMENT in VARCHAR2,
  X_OPTIMIZER_MODE in VARCHAR2,
  X_USER_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_TIME_STATISTICS in VARCHAR2,
  X_REFRESH_PORTLET in VARCHAR2,
  X_PROGRAM_TYPE in VARCHAR2,
  X_ACTIVITY_SUMMARIZER in VARCHAR2,
  X_ALLOW_MULTIPLE_PENDING_REQUE in VARCHAR2,
  X_DELETE_LOG_FILE in VARCHAR2,
  X_TEMPLATE_APPL_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_MULTI_ORG_CATEGORY in VARCHAR2,
  X_RECALC_PARAMETERS in VARCHAR2
) is
begin
  update FND_CONCURRENT_PROGRAMS set
    CONCURRENT_PROGRAM_NAME =
        nvl(X_CONCURRENT_PROGRAM_NAME, CONCURRENT_PROGRAM_NAME),
    EXECUTABLE_APPLICATION_ID = X_EXECUTABLE_APPLICATION_ID,
    EXECUTABLE_ID = X_EXECUTABLE_ID,
    EXECUTION_METHOD_CODE = X_EXECUTION_METHOD_CODE,
    ARGUMENT_METHOD_CODE = X_ARGUMENT_METHOD_CODE,
    QUEUE_CONTROL_FLAG = X_QUEUE_CONTROL_FLAG,
    QUEUE_METHOD_CODE = X_QUEUE_METHOD_CODE,
    REQUEST_SET_FLAG = X_REQUEST_SET_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    PRINT_FLAG = X_PRINT_FLAG,
    RUN_ALONE_FLAG = X_RUN_ALONE_FLAG,
    SRS_FLAG = X_SRS_FLAG,
    CLASS_APPLICATION_ID = X_CLASS_APPLICATION_ID,
    CONCURRENT_CLASS_ID = X_CONCURRENT_CLASS_ID,
    EXECUTION_OPTIONS = X_EXECUTION_OPTIONS,
    SAVE_OUTPUT_FLAG = X_SAVE_OUTPUT_FLAG,
    REQUIRED_STYLE = X_REQUIRED_STYLE,
    OUTPUT_PRINT_STYLE = X_OUTPUT_PRINT_STYLE,
    PRINTER_NAME = X_PRINTER_NAME,
    MINIMUM_WIDTH = X_MINIMUM_WIDTH,
    MINIMUM_LENGTH = X_MINIMUM_LENGTH,
    REQUEST_PRIORITY = X_REQUEST_PRIORITY,
    OUTPUT_FILE_TYPE = X_OUTPUT_FILE_TYPE,
    ENABLE_TRACE = nvl(X_ENABLE_TRACE, ENABLE_TRACE),
    RESTART = X_RESTART,
    NLS_COMPLIANT = X_NLS_COMPLIANT,
    ICON_NAME = X_ICON_NAME,
    CD_PARAMETER = X_CD_PARAMETER,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    INCREMENT_PROC = X_INCREMENT_PROC,
    MLS_EXECUTABLE_APP_ID = X_MLS_EXECUTABLE_APP_ID,
    MLS_EXECUTABLE_ID = X_MLS_EXECUTABLE_ID,
    RESOURCE_CONSUMER_GROUP = X_RESOURCE_CONSUMER_GROUP,
    ROLLBACK_SEGMENT = X_ROLLBACK_SEGMENT,
    OPTIMIZER_MODE = X_OPTIMIZER_MODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ENABLE_TIME_STATISTICS = NVL(X_ENABLE_TIME_STATISTICS,'N'),
    REFRESH_PORTLET = X_REFRESH_PORTLET,
    PROGRAM_TYPE = X_PROGRAM_TYPE,
    ACTIVITY_SUMMARIZER = X_ACTIVITY_SUMMARIZER,
    ALLOW_MULTIPLE_PENDING_REQUEST = X_ALLOW_MULTIPLE_PENDING_REQUE,
    DELETE_LOG_FILE = X_DELETE_LOG_FILE,
    TEMPLATE_CODE =   X_TEMPLATE_CODE,
    TEMPLATE_APPL_SHORT_NAME = X_TEMPLATE_APPL_SHORT_NAME,
    MULTI_ORG_CATEGORY = X_MULTI_ORG_CATEGORY,
    RECALC_PARAMETERS = X_RECALC_PARAMETERS
  where APPLICATION_ID = X_APPLICATION_ID
  and CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_CONCURRENT_PROGRAMS_TL set
    USER_CONCURRENT_PROGRAM_NAME = X_USER_CONCURRENT_PROGRAM_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

-- Overloaded in case custom_mode and last_upate_date are not used
procedure TRANSLATE_ROW (
  x_concurrent_program_name      in varchar2,
  x_application_short_name       in varchar2,
  x_owner                        in varchar2,
  x_user_concurrent_program_name in varchar2,
  x_description                  in varchar2)
is
begin
  fnd_concurrent_programs_pkg.translate_row (
    x_concurrent_program_name => x_concurrent_program_name,
    x_application_short_name => x_application_short_name,
    x_owner => x_owner,
    x_user_concurrent_program_name => x_user_concurrent_program_name,
    x_description => x_description,
    x_custom_mode => null,
    x_last_update_date => null);
end TRANSLATE_ROW;

-- Overloaded
procedure TRANSLATE_ROW (
  x_concurrent_program_name      in varchar2,
  x_application_short_name       in varchar2,
  x_owner                        in varchar2,
  x_user_concurrent_program_name in varchar2,
  x_description                  in varchar2,
  x_custom_mode                  in varchar2,
  x_last_update_date             in varchar2)
is
  app_id    number := 0;
  key_id    number := 0;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  select application_id into app_id
  from   fnd_application
  where  application_short_name = x_application_short_name;

  begin
    select CONCURRENT_PROGRAM_ID into key_id
    from fnd_concurrent_programs
    where APPLICATION_ID = app_id
    and CONCURRENT_PROGRAM_NAME = x_concurrent_program_name;
  exception when others then key_id :=null;
  end;

   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.OWNER_ID(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   begin
     select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from FND_CONCURRENT_PROGRAMS_TL
     where APPLICATION_ID = app_id
     and CONCURRENT_PROGRAM_ID = key_id
     and LANGUAGE = userenv('LANG');

     -- Update record, honoring customization mode.
     -- Record should be updated only if:
     -- a. CUSTOM_MODE = FORCE, or
     -- b. file owner is USER, db owner is SEED
     -- c. owners are the same, and file_date > db_date
     if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud    => f_ludate,
                p_db_id       => db_luby,
                p_db_lud      => db_ludate,
                p_custom_mode => x_custom_mode))
     then
       update FND_CONCURRENT_PROGRAMS_TL set
         USER_CONCURRENT_PROGRAM_NAME =
           nvl(x_user_concurrent_program_name, USER_CONCURRENT_PROGRAM_NAME),
         DESCRIPTION         = nvl(x_description, DESCRIPTION),
         SOURCE_LANG         = userenv('LANG'),
         LAST_UPDATE_DATE      = f_ludate,
         LAST_UPDATED_BY       = f_luby,
         LAST_UPDATE_LOGIN     = 0
       where APPLICATION_ID = app_id
       and CONCURRENT_PROGRAM_ID = key_id
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
      end if;
   end;
end TRANSLATE_ROW;

-- Overloaded in case custom_mode and last_upate_date are not used
procedure LOAD_ROW (
  x_concurrent_program_name         in varchar2,
  x_application_short_name          in varchar2,
  x_owner                           in varchar2,
  x_user_concurrent_program_name    in varchar2,
  x_exec_executable_name            in varchar2,
  x_exec_application_short_name     in varchar2,
  x_execution_method_code           in varchar2,
  x_argument_method_code            in varchar2,
  x_queue_control_flag              in varchar2,
  x_queue_method_code               in varchar2,
  x_request_set_flag                in varchar2,
  x_enabled_flag                    in varchar2,
  x_print_flag                      in varchar2,
  x_run_alone_flag                  in varchar2,
  x_srs_flag                        in varchar2,
  x_description                     in varchar2,
  x_class_application               in varchar2,
  x_concurrent_class_name           in varchar2,
  x_execution_options               in varchar2,
  x_save_output_flag                in varchar2,
  x_required_style                  in varchar2,
  x_output_print_style              in varchar2,
  x_printer_name                    in varchar2,
  x_minimum_width                   in varchar2,
  x_minimum_length                  in varchar2,
  x_request_priority                in varchar2,
  x_attribute_category              in varchar2,
  x_attribute1                      in varchar2,
  x_attribute2                      in varchar2,
  x_attribute3                      in varchar2,
  x_attribute4                      in varchar2,
  x_attribute5                      in varchar2,
  x_attribute6                      in varchar2,
  x_attribute7                      in varchar2,
  x_attribute8                      in varchar2,
  x_attribute9                      in varchar2,
  x_attribute10                     in varchar2,
  x_attribute11                     in varchar2,
  x_attribute12                     in varchar2,
  x_attribute13                     in varchar2,
  x_attribute14                     in varchar2,
  x_attribute15                     in varchar2,
  x_output_file_type                in varchar2,
  x_restart                         in varchar2,
  x_nls_compliant                   in varchar2,
  x_cd_parameter                    in varchar2,
  x_increment_proc                  in varchar2,
  x_me_ex_id                        in varchar2,
  x_me_ap_id                        in varchar2,
  x_enable_time_statistics          in varchar2,
  x_security_group_name             in varchar2,
  x_resource_consumer_group         in varchar2,
  x_rollback_segment                in varchar2,
  x_optimizer_mode                  in varchar2,
  x_srs_flex                        in varchar2)
is
begin
  fnd_concurrent_programs_pkg.LOAD_ROW (
    x_concurrent_program_name => x_concurrent_program_name,
    x_application_short_name => x_application_short_name,
    x_owner => x_owner,
    x_user_concurrent_program_name => x_user_concurrent_program_name,
    x_exec_executable_name => x_exec_executable_name,
    x_exec_application_short_name => x_exec_application_short_name,
    x_execution_method_code => x_execution_method_code,
    x_argument_method_code => x_argument_method_code,
    x_queue_control_flag => x_queue_control_flag,
    x_queue_method_code => x_queue_method_code,
    x_request_set_flag => x_request_set_flag,
    x_enabled_flag => x_enabled_flag,
    x_print_flag => x_print_flag,
    x_run_alone_flag => x_run_alone_flag,
    x_srs_flag => x_srs_flag,
    x_description => x_description,
    x_class_application => x_class_application,
    x_concurrent_class_name => x_concurrent_class_name,
    x_execution_options => x_execution_options,
    x_save_output_flag => x_save_output_flag,
    x_required_style => x_required_style,
    x_output_print_style => x_output_print_style,
    x_printer_name => x_printer_name,
    x_minimum_width => x_minimum_width,
    x_minimum_length => x_minimum_length,
    x_request_priority => x_request_priority,
    x_attribute_category => x_attribute_category,
    x_attribute1 => x_attribute1,
    x_attribute2 => x_attribute2,
    x_attribute3 => x_attribute3,
    x_attribute4 => x_attribute4,
    x_attribute5 => x_attribute5,
    x_attribute6 => x_attribute6,
    x_attribute7 => x_attribute7,
    x_attribute8 => x_attribute8,
    x_attribute9 => x_attribute9,
    x_attribute10 => x_attribute10,
    x_attribute11 => x_attribute11,
    x_attribute12 => x_attribute12,
    x_attribute13 => x_attribute13,
    x_attribute14 => x_attribute14,
    x_attribute15 => x_attribute15,
    x_output_file_type => x_output_file_type,
    x_restart => x_restart,
    x_nls_compliant => x_nls_compliant,
    x_cd_parameter => x_cd_parameter,
    x_increment_proc => x_increment_proc,
    x_me_ex_id => x_me_ex_id,
    x_me_ap_id => x_me_ap_id,
    x_enable_time_statistics => x_enable_time_statistics,
    x_security_group_name => x_security_group_name,
    x_resource_consumer_group => x_resource_consumer_group,
    x_rollback_segment => x_rollback_segment,
    x_optimizer_mode => x_optimizer_mode,
    x_srs_flex => x_srs_flex,
    x_custom_mode => null,
    x_last_update_date=> null,
    x_refresh_portlet => null,
    x_activity_summarizer => null,
    x_program_type => null,
    x_allow_multiple_pending_reque => null,
    x_template_appl_short_name => null,
    x_template_code => null,
    x_multi_org_category => null,
    x_recalc_parameters => 'N');

end LOAD_ROW;

-- Overloaded
procedure LOAD_ROW (
  x_concurrent_program_name         in varchar2,
  x_application_short_name          in varchar2,
  x_owner                           in varchar2,
  x_user_concurrent_program_name    in varchar2,
  x_exec_executable_name            in varchar2,
  x_exec_application_short_name     in varchar2,
  x_execution_method_code           in varchar2,
  x_argument_method_code            in varchar2,
  x_queue_control_flag              in varchar2,
  x_queue_method_code               in varchar2,
  x_request_set_flag                in varchar2,
  x_enabled_flag                    in varchar2,
  x_print_flag                      in varchar2,
  x_run_alone_flag                  in varchar2,
  x_srs_flag                        in varchar2,
  x_description                     in varchar2,
  x_class_application               in varchar2,
  x_concurrent_class_name           in varchar2,
  x_execution_options               in varchar2,
  x_save_output_flag                in varchar2,
  x_required_style                  in varchar2,
  x_output_print_style              in varchar2,
  x_printer_name                    in varchar2,
  x_minimum_width                   in varchar2,
  x_minimum_length                  in varchar2,
  x_request_priority                in varchar2,
  x_attribute_category              in varchar2,
  x_attribute1                      in varchar2,
  x_attribute2                      in varchar2,
  x_attribute3                      in varchar2,
  x_attribute4                      in varchar2,
  x_attribute5                      in varchar2,
  x_attribute6                      in varchar2,
  x_attribute7                      in varchar2,
  x_attribute8                      in varchar2,
  x_attribute9                      in varchar2,
  x_attribute10                     in varchar2,
  x_attribute11                     in varchar2,
  x_attribute12                     in varchar2,
  x_attribute13                     in varchar2,
  x_attribute14                     in varchar2,
  x_attribute15                     in varchar2,
  x_output_file_type                in varchar2,
  x_restart                         in varchar2,
  x_nls_compliant                   in varchar2,
  x_cd_parameter                    in varchar2,
  x_increment_proc                  in varchar2,
  x_me_ex_id                        in varchar2,
  x_me_ap_id                        in varchar2,
  x_enable_time_statistics          in varchar2,
  x_security_group_name             in varchar2,
  x_resource_consumer_group         in varchar2,
  x_rollback_segment                in varchar2,
  x_optimizer_mode                  in varchar2,
  x_srs_flex                        in varchar2,
  x_custom_mode                     in varchar2,
  x_last_update_date                in varchar2,
  x_refresh_portlet                 in varchar2,
  x_activity_summarizer             in varchar2,
  x_program_type                    in varchar2,
  x_allow_multiple_pending_reque    in varchar2,
  x_template_appl_short_name        in varchar2,
  x_template_code                   in varchar2,
  x_multi_org_category              in varchar2,
  x_recalc_parameters              in varchar2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  app_id   number := 0;
  key_id   number := 0;
  sgrp_id  number := 0;
  rc_grp   varchar2(255) := NULL;
  ex_app   number := 0;
  ex_id    number := 0;
  cl_app   number := 0;
  cl_id    number := 0;
  ml_app   number := 0;
  ml_id    number := 0;

begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.OWNER_ID(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select APPLICATION_ID into app_id
  from   FND_APPLICATION
  where  APPLICATION_SHORT_NAME = x_application_short_name;


  begin
    select SECURITY_GROUP_ID into sgrp_id
    from FND_SECURITY_GROUPS
    where SECURITY_GROUP_KEY = x_security_group_name;
  exception when others then sgrp_id := null;
  end;

  begin
    select GRANTED_GROUP into rc_grp
    from DBA_RSRC_CONSUMER_GROUP_PRIVS
    where GRANTEE in (USER, 'PUBLIC')
    and GRANTED_GROUP = x_resource_consumer_group;
  exception when others then rc_grp :=null;
  end;

  select  ex.APPLICATION_ID, ex.EXECUTABLE_ID,
          cl.APPLICATION_ID, cl.REQUEST_CLASS_ID,
          ml.APPLICATION_ID, ml.EXECUTABLE_ID
  into    ex_app, ex_id, cl_app, cl_id, ml_app, ml_id
  FROM FND_EXECUTABLES ex, FND_APPLICATION exa,
          FND_CONCURRENT_REQUEST_CLASS cl, FND_APPLICATION cla,
          FND_EXECUTABLES ml, FND_APPLICATION mla
  WHERE ex.EXECUTABLE_NAME = x_exec_executable_name
          and ex.APPLICATION_ID = exa.APPLICATION_ID
          and exa.APPLICATION_SHORT_NAME = x_exec_application_short_name
          and cl.REQUEST_CLASS_NAME (+) = x_concurrent_class_name
          and cl.APPLICATION_ID (+) = cla.APPLICATION_ID
          and cla.APPLICATION_SHORT_NAME = NVL(x_class_application,'FND')
          and ml.EXECUTABLE_NAME (+) = x_me_ex_id
          and ml.APPLICATION_ID (+) = mla.APPLICATION_ID
          and mla.APPLICATION_SHORT_NAME =
                  NVL(x_me_ap_id,'FND');

  begin
     select CONCURRENT_PROGRAM_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
     into key_id, db_luby, db_ludate
     from FND_CONCURRENT_PROGRAMS
     where APPLICATION_ID = app_id
     and CONCURRENT_PROGRAM_NAME = x_concurrent_program_name;

     -- Update record, honoring customization mode.
     -- Record should be updated only if:
     -- a. CUSTOM_MODE = FORCE, or
     -- b. file owner is USER, db owner is SEED
     -- c. owners are the same, and file_date > db_date
     if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud    => f_ludate,
                p_db_id       => db_luby,
                p_db_lud      => db_ludate,
                p_custom_mode => x_custom_mode))
     then

	  -- Avoid removing incompatibilities for bug 6398080
          /* delete from fnd_concurrent_program_serial
          WHERE running_concurrent_program_id = key_id
          AND running_application_id = app_id;

           delete from fnd_concurrent_program_serial
          WHERE to_run_concurrent_program_id = key_id
          AND to_run_application_id = app_id; */

       update FND_CONCURRENT_PROGRAMS set
          LAST_UPDATE_DATE = f_ludate,
          LAST_UPDATED_BY = f_luby,
          LAST_UPDATE_LOGIN = 0,
          EXECUTABLE_ID = ex_id,
          EXECUTABLE_APPLICATION_ID = ex_app,
          EXECUTION_METHOD_CODE = x_execution_method_code,
          ARGUMENT_METHOD_CODE = x_argument_method_code,
          QUEUE_CONTROL_FLAG = x_queue_control_flag,
          QUEUE_METHOD_CODE = x_queue_method_code,
          REQUEST_SET_FLAG = x_request_set_flag,
          ENABLED_FLAG = x_enabled_flag,
          PRINT_FLAG = x_print_flag,
          RUN_ALONE_FLAG = x_run_alone_flag,
          SRS_FLAG = x_srs_flag,
          CLASS_APPLICATION_ID = cl_app,
          CONCURRENT_CLASS_ID = cl_id,
          EXECUTION_OPTIONS = x_execution_options,
          SAVE_OUTPUT_FLAG = x_save_output_flag,
          REQUIRED_STYLE = x_required_style,
          OUTPUT_PRINT_STYLE = x_output_print_style,
          PRINTER_NAME = x_printer_name,
          MINIMUM_WIDTH = x_minimum_width,
          MINIMUM_LENGTH = x_minimum_length,
          REQUEST_PRIORITY = x_request_priority,
          ATTRIBUTE_CATEGORY = x_attribute_category,
          ATTRIBUTE1 = x_attribute1,
          ATTRIBUTE2 = x_attribute2,
          ATTRIBUTE3 = x_attribute3,
          ATTRIBUTE4 = x_attribute4,
          ATTRIBUTE5 = x_attribute5,
          ATTRIBUTE6 = x_attribute6,
          ATTRIBUTE7 = x_attribute7,
          ATTRIBUTE8 = x_attribute8,
          ATTRIBUTE9 = x_attribute9,
          ATTRIBUTE10 = x_attribute10,
          ATTRIBUTE11 = x_attribute11,
          ATTRIBUTE12 = x_attribute12,
          ATTRIBUTE13 = x_attribute13,
          ATTRIBUTE14 = x_attribute14,
          ATTRIBUTE15 = x_attribute15,
          OUTPUT_FILE_TYPE = x_output_file_type,
          RESTART = x_restart,
          NLS_COMPLIANT = x_nls_compliant,
          CD_PARAMETER = x_cd_parameter,
          INCREMENT_PROC = x_increment_proc,
          MLS_EXECUTABLE_APP_ID = ml_app,
          MLS_EXECUTABLE_ID= ml_id,
          ENABLE_TIME_STATISTICS = x_enable_time_statistics,
          SECURITY_GROUP_ID = sgrp_id,
          RESOURCE_CONSUMER_GROUP = rc_grp,
          ROLLBACK_SEGMENT = x_rollback_segment,
          OPTIMIZER_MODE = x_optimizer_mode,
          REFRESH_PORTLET = x_refresh_portlet,
          ACTIVITY_SUMMARIZER = x_activity_summarizer,
          PROGRAM_TYPE = x_Program_type,
          ALLOW_MULTIPLE_PENDING_REQUEST = x_allow_multiple_pending_reque,
          TEMPLATE_APPL_SHORT_NAME = x_template_appl_short_name ,
          TEMPLATE_CODE = x_template_code,
          MULTI_ORG_CATEGORY = x_multi_org_category,
          RECALC_PARAMETERS = x_recalc_parameters

       where APPLICATION_ID = app_id
       and CONCURRENT_PROGRAM_ID = key_id;

       update fnd_concurrent_programs_tl set
          source_lang=userenv('LANG'),
          USER_CONCURRENT_PROGRAM_NAME =
              nvl(x_user_concurrent_program_name, USER_CONCURRENT_PROGRAM_NAME),
          DESCRIPTION = nvl(x_description, DESCRIPTION),
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATE_LOGIN = 0
        where application_id = app_id
        and   CONCURRENT_PROGRAM_ID = key_id
        and   NVL(x_user_concurrent_program_name,x_description) is not null
        and userenv('LANG') in (language, source_lang);

     else

       -- Here, UPLOAD_TEST has returned false,
       -- so this program has been customized by the user.
       -- However, we may still need to update certain columns, regardless of this.
       -- CD_PARAMETER is one of these, see bug 2737442
       -- Update it quietly, without setting last_update_date or last_updated_by
       -- 03/27/03 - not checking last_update anymore, this column is ALWAYS updated.
       begin
         update FND_CONCURRENT_PROGRAMS
           set CD_PARAMETER = x_cd_parameter
           where APPLICATION_ID = app_id
           and CONCURRENT_PROGRAM_ID = key_id;
       exception
         when no_data_found then
         -- somehow this row does not yet exist?
           null;
       end;

     end if;

  exception
     when no_data_found then

       select FND_CONCURRENT_PROGRAMS_S.nextval into key_id from dual;

       insert into FND_CONCURRENT_PROGRAMS
      (CONCURRENT_PROGRAM_NAME, CONCURRENT_PROGRAM_ID,
      APPLICATION_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
      LAST_UPDATED_BY, LAST_UPDATE_LOGIN, EXECUTABLE_ID,
      EXECUTABLE_APPLICATION_ID, EXECUTION_METHOD_CODE,
      ARGUMENT_METHOD_CODE,QUEUE_CONTROL_FLAG,QUEUE_METHOD_CODE,
      REQUEST_SET_FLAG, ENABLED_FLAG,PRINT_FLAG,RUN_ALONE_FLAG,
      SRS_FLAG, CLASS_APPLICATION_ID,CONCURRENT_CLASS_ID,
      EXECUTION_OPTIONS, SAVE_OUTPUT_FLAG, REQUIRED_STYLE,
      OUTPUT_PRINT_STYLE, PRINTER_NAME, MINIMUM_WIDTH,
      MINIMUM_LENGTH, REQUEST_PRIORITY, ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,
      ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,
      ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
      ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,
      OUTPUT_FILE_TYPE,RESTART,NLS_COMPLIANT,CD_PARAMETER,
      INCREMENT_PROC, MLS_EXECUTABLE_APP_ID, MLS_EXECUTABLE_ID,
      ENABLE_TIME_STATISTICS, SECURITY_GROUP_ID, ENABLE_TRACE,
      RESOURCE_CONSUMER_GROUP,ROLLBACK_SEGMENT,OPTIMIZER_MODE,
      REFRESH_PORTLET,ACTIVITY_SUMMARIZER,PROGRAM_TYPE,ALLOW_MULTIPLE_PENDING_REQUEST,
      TEMPLATE_APPL_SHORT_NAME    , TEMPLATE_CODE,
      MULTI_ORG_CATEGORY, RECALC_PARAMETERS
          )
      select x_concurrent_program_name, key_id,
        app_id, f_ludate, f_luby, f_ludate,
        f_luby, 0, ex_id, ex_app, x_execution_method_code,
        x_argument_method_code, x_queue_control_flag, x_queue_method_code,
        x_request_set_flag, x_enabled_flag, x_print_flag, x_run_alone_flag,
        x_srs_flag, cl_app, cl_id,
        x_execution_options,x_save_output_flag,x_required_style,
        x_output_print_style,x_printer_name,x_minimum_width,
        x_minimum_length,x_request_priority,x_attribute_category,
        x_attribute1,x_attribute2,x_attribute3,x_attribute4,
        x_attribute5, x_attribute6,x_attribute7,x_attribute8,
        x_attribute9,x_attribute10,x_attribute11,x_attribute12,
        x_attribute13,x_attribute14,x_attribute15,
        x_output_file_type,x_restart,x_nls_compliant,x_cd_parameter,
        x_increment_proc, ml_app, ml_id,
        x_enable_time_statistics, sgrp_id, 'N',
        rc_grp, x_rollback_segment, x_optimizer_mode,
        x_refresh_portlet,x_activity_summarizer,x_program_type,x_allow_multiple_pending_reque,
        x_template_appl_short_name, x_template_code,
        x_multi_org_category, x_recalc_parameters
      from DUAL;

       insert into FND_CONCURRENT_PROGRAMS_TL
      (CONCURRENT_PROGRAM_ID, APPLICATION_ID, CREATION_DATE,
      CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN, DESCRIPTION,USER_CONCURRENT_PROGRAM_NAME,
      LANGUAGE, SOURCE_LANG)
      select key_id, app_id, f_ludate,
        f_luby, f_ludate, f_luby, 0,
        x_description, x_user_concurrent_program_name,
        L.LANGUAGE_CODE, userenv('LANG')
      from FND_LANGUAGES L
          where L.INSTALLED_FLAG in ('I', 'B')
          and not exists
            (select NULL
             from FND_CONCURRENT_PROGRAMS_TL T
             where T.APPLICATION_ID = app_id
             and T.CONCURRENT_PROGRAM_ID =key_id
             and T.LANGUAGE = L.LANGUAGE_CODE);

  end;

end LOAD_ROW;
procedure ADD_LANGUAGE
is
begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*
  delete from FND_CONCURRENT_PROGRAMS_TL T
  where not exists
    (select NULL
    from FND_CONCURRENT_PROGRAMS B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.CONCURRENT_PROGRAM_ID = T.CONCURRENT_PROGRAM_ID
    );

  update FND_CONCURRENT_PROGRAMS_TL T set (
      USER_CONCURRENT_PROGRAM_NAME,
      DESCRIPTION
    ) = (select
      B.USER_CONCURRENT_PROGRAM_NAME,
      B.DESCRIPTION
    from FND_CONCURRENT_PROGRAMS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.CONCURRENT_PROGRAM_ID = T.CONCURRENT_PROGRAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.CONCURRENT_PROGRAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.CONCURRENT_PROGRAM_ID,
      SUBT.LANGUAGE
    from FND_CONCURRENT_PROGRAMS_TL SUBB, FND_CONCURRENT_PROGRAMS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.CONCURRENT_PROGRAM_ID = SUBT.CONCURRENT_PROGRAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_CONCURRENT_PROGRAM_NAME <> SUBT.USER_CONCURRENT_PROGRAM_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

/* bug8260682                                                             */
/* use fake early date for last_update_date and 2 for last_updated_by     */
/* so that FNDLOAD will recognize newly created rows as freshly installed */
/* see fnd_load_util.upload_test why this works...                        */

  insert into FND_CONCURRENT_PROGRAMS_TL (
    APPLICATION_ID,
    CONCURRENT_PROGRAM_ID,
    USER_CONCURRENT_PROGRAM_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.CONCURRENT_PROGRAM_ID,
    B.USER_CONCURRENT_PROGRAM_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    to_date('01011980','MMDDYYYY'),
    '2',
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_CONCURRENT_PROGRAMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_CONCURRENT_PROGRAMS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.CONCURRENT_PROGRAM_ID = B.CONCURRENT_PROGRAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



end FND_CONCURRENT_PROGRAMS_PKG;

/
