--------------------------------------------------------
--  DDL for Package Body FND_REQUEST_SET_STAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REQUEST_SET_STAGES_PKG" as
/* $Header: AFRSRSSB.pls 120.2 2005/08/19 20:20:34 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER,
  X_STAGE_NAME in VARCHAR2,
  X_CRITICAL in VARCHAR2,
  X_OUTCOME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_FUNCTION_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_SUCCESS_LINK in NUMBER,
  X_WARNING_LINK in NUMBER,
  X_ERROR_LINK in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_X in NUMBER,
  X_Y in NUMBER,
  X_ICON_NAME in VARCHAR2,
  X_USER_STAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_REQUEST_SET_STAGES
    where REQUEST_SET_ID = X_REQUEST_SET_ID
    and SET_APPLICATION_ID = X_SET_APPLICATION_ID
    and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID
    ;
begin
  insert into FND_REQUEST_SET_STAGES (
    SET_APPLICATION_ID,
    REQUEST_SET_ID,
    REQUEST_SET_STAGE_ID,
    STAGE_NAME,
    CRITICAL,
    OUTCOME,
    ALLOW_CONSTRAINTS_FLAG,
    DISPLAY_SEQUENCE,
    FUNCTION_APPLICATION_ID,
    FUNCTION_ID,
    SUCCESS_LINK,
    WARNING_LINK,
    ERROR_LINK,
    CONCURRENT_PROGRAM_ID,
    X,
    Y,
    ICON_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SET_APPLICATION_ID,
    X_REQUEST_SET_ID,
    X_REQUEST_SET_STAGE_ID,
    X_STAGE_NAME,
    X_CRITICAL,
    X_OUTCOME,
    X_ALLOW_CONSTRAINTS_FLAG,
    X_DISPLAY_SEQUENCE,
    X_FUNCTION_APPLICATION_ID,
    X_FUNCTION_ID,
    X_SUCCESS_LINK,
    X_WARNING_LINK,
    X_ERROR_LINK,
    X_CONCURRENT_PROGRAM_ID,
    X_X,
    X_Y,
    X_ICON_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_REQUEST_SET_STAGES_TL (
    SET_APPLICATION_ID,
    REQUEST_SET_ID,
    REQUEST_SET_STAGE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_STAGE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SET_APPLICATION_ID,
    X_REQUEST_SET_ID,
    X_REQUEST_SET_STAGE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USER_STAGE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_REQUEST_SET_STAGES_TL T
    where T.REQUEST_SET_ID = X_REQUEST_SET_ID
    and T.SET_APPLICATION_ID = X_SET_APPLICATION_ID
    and T.REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID
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
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER,
  X_STAGE_NAME in VARCHAR2,
  X_CRITICAL in VARCHAR2,
  X_OUTCOME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_FUNCTION_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_SUCCESS_LINK in NUMBER,
  X_WARNING_LINK in NUMBER,
  X_ERROR_LINK in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_X in NUMBER,
  X_Y in NUMBER,
  X_ICON_NAME in VARCHAR2,
  X_USER_STAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      STAGE_NAME,
      CRITICAL,
      OUTCOME,
      ALLOW_CONSTRAINTS_FLAG,
      DISPLAY_SEQUENCE,
      FUNCTION_APPLICATION_ID,
      FUNCTION_ID,
      SUCCESS_LINK,
      WARNING_LINK,
      ERROR_LINK,
      CONCURRENT_PROGRAM_ID,
      X,
      Y,
      ICON_NAME
    from FND_REQUEST_SET_STAGES
    where REQUEST_SET_ID = X_REQUEST_SET_ID
    and SET_APPLICATION_ID = X_SET_APPLICATION_ID
    and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID
    for update of REQUEST_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_STAGE_NAME,
      DESCRIPTION
    from FND_REQUEST_SET_STAGES_TL
    where REQUEST_SET_ID = X_REQUEST_SET_ID
    and SET_APPLICATION_ID = X_SET_APPLICATION_ID
    and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID
    and LANGUAGE = userenv('LANG')
    for update of REQUEST_SET_ID nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STAGE_NAME = X_STAGE_NAME)
      AND (recinfo.CRITICAL = X_CRITICAL)
      AND (recinfo.OUTCOME = X_OUTCOME)
      AND (recinfo.ALLOW_CONSTRAINTS_FLAG = X_ALLOW_CONSTRAINTS_FLAG)
      AND (recinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
      AND ((recinfo.FUNCTION_APPLICATION_ID = X_FUNCTION_APPLICATION_ID)
           OR ((recinfo.FUNCTION_APPLICATION_ID is null) AND (X_FUNCTION_APPLICATION_ID is null)))
      AND ((recinfo.FUNCTION_ID = X_FUNCTION_ID)
           OR ((recinfo.FUNCTION_ID is null) AND (X_FUNCTION_ID is null)))
      AND ((recinfo.SUCCESS_LINK = X_SUCCESS_LINK)
           OR ((recinfo.SUCCESS_LINK is null) AND (X_SUCCESS_LINK is null)))
      AND ((recinfo.WARNING_LINK = X_WARNING_LINK)
           OR ((recinfo.WARNING_LINK is null) AND (X_WARNING_LINK is null)))
      AND ((recinfo.ERROR_LINK = X_ERROR_LINK)
           OR ((recinfo.ERROR_LINK is null) AND (X_ERROR_LINK is null)))
      AND ((recinfo.CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID)
           OR ((recinfo.CONCURRENT_PROGRAM_ID is null) AND (X_CONCURRENT_PROGRAM_ID is null)))
      AND ((recinfo.X = X_X)
           OR ((recinfo.X is null) AND (X_X is null)))
      AND ((recinfo.Y = X_Y)
           OR ((recinfo.Y is null) AND (X_Y is null)))
      AND ((recinfo.ICON_NAME = X_ICON_NAME)
           OR ((recinfo.ICON_NAME is null) AND (X_ICON_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_STAGE_NAME = X_USER_STAGE_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER,
  X_STAGE_NAME in VARCHAR2,
  X_CRITICAL in VARCHAR2,
  X_OUTCOME in VARCHAR2,
  X_ALLOW_CONSTRAINTS_FLAG in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_FUNCTION_APPLICATION_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_SUCCESS_LINK in NUMBER,
  X_WARNING_LINK in NUMBER,
  X_ERROR_LINK in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_X in NUMBER,
  X_Y in NUMBER,
  X_ICON_NAME in VARCHAR2,
  X_USER_STAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_REQUEST_SET_STAGES set
    STAGE_NAME = X_STAGE_NAME,
    CRITICAL = X_CRITICAL,
    OUTCOME = X_OUTCOME,
    ALLOW_CONSTRAINTS_FLAG = X_ALLOW_CONSTRAINTS_FLAG,
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    FUNCTION_APPLICATION_ID = X_FUNCTION_APPLICATION_ID,
    FUNCTION_ID = X_FUNCTION_ID,
    SUCCESS_LINK = X_SUCCESS_LINK,
    WARNING_LINK = X_WARNING_LINK,
    ERROR_LINK = X_ERROR_LINK,
    CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID,
    X = X_X,
    Y = X_Y,
    ICON_NAME = X_ICON_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REQUEST_SET_ID = X_REQUEST_SET_ID
  and SET_APPLICATION_ID = X_SET_APPLICATION_ID
  and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_REQUEST_SET_STAGES_TL set
    USER_STAGE_NAME = X_USER_STAGE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REQUEST_SET_ID = X_REQUEST_SET_ID
  and SET_APPLICATION_ID = X_SET_APPLICATION_ID
  and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REQUEST_SET_ID in NUMBER,
  X_SET_APPLICATION_ID in NUMBER,
  X_REQUEST_SET_STAGE_ID in NUMBER
) is

-- This added code fixes the problem of having success, error, and/or warning links
--  pointing to stages which have been deleted. Before the stage gets deleted, the
--  following code checks to see if any other stage has a link pointing to the
--  stage which is about to be deleted. If so, the link is set to null.
--BUG 871226  (Begin of Added Declarations)

  bad_stage_id  NUMBER(15);

  bad_SL        NUMBER(15);
  bad_WL        NUMBER(15);
  bad_EL        NUMBER(15);

  TYPE set_app_id_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE req_set_id_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE req_set_stage_id_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  set_app_id_array              set_app_id_table;
  req_set_id_array              req_set_id_table;
  req_set_stage_id_array        req_set_stage_id_table;

  bad_link_counter              BINARY_INTEGER := 0;

  CURSOR get_bad_links IS SELECT set_application_id, request_set_id, request_set_stage_id
        FROM fnd_request_set_stages_vl WHERE (success_link =  bad_stage_id)
                                       OR (warning_link = bad_stage_id)
                                       OR (error_link = bad_stage_id);

--BUG 871226  (End of Added Declarations)

begin
  -- Disable the concurrent program (if any).
  begin
    update fnd_concurrent_programs
       set enabled_flag='N'
     where application_id = x_set_application_id
       and concurrent_program_id in
           (select concurrent_program_id
              from fnd_request_set_stages
             where set_application_id = x_set_application_id
               and request_set_id = x_request_set_id
               and request_set_stage_id = x_request_set_stage_id
               and concurrent_program_id is null);

--BUG 871226  (Begin of Added Code)

  SELECT request_set_stage_id INTO bad_stage_id
                                  FROM fnd_request_set_stages_vl
                                   WHERE set_application_id = x_set_application_id
                                   AND request_set_id = x_request_set_id
                                   AND request_set_stage_id = x_request_set_stage_id;

  OPEN get_bad_links;

  LOOP
        FETCH get_bad_links INTO set_app_id_array(bad_link_counter),
                                 req_set_id_array(bad_link_counter),
                                 req_set_stage_id_array(bad_link_counter);

        EXIT WHEN get_bad_links%NOTFOUND;
        bad_link_counter := bad_link_counter + 1; -- counter gets inc 1 too high here
  END LOOP;

  CLOSE get_bad_links;


  FOR array_index IN 0..bad_link_counter - 1  LOOP  -- dec 1 from counter because too high

        SELECT success_link,warning_link,error_link INTO bad_SL,bad_WL,bad_EL
                       FROM fnd_request_set_stages_vl WHERE
                        set_application_id = set_app_id_array(array_index) AND
                        request_set_id = req_set_id_array(array_index) AND
                        request_set_stage_id = req_set_stage_id_array(array_index);

        IF (bad_SL = bad_stage_id )  THEN
                        UPDATE fnd_request_set_stages SET success_link = NULL WHERE
                                 set_application_id = set_app_id_array(array_index) AND
                                 request_set_id = req_set_id_array(array_index) AND
                                 request_set_stage_id = req_set_stage_id_array(array_index);
        END IF;

        IF (bad_WL = bad_stage_id)  THEN
                        UPDATE fnd_request_set_stages SET warning_link = NULL WHERE
                                 set_application_id = set_app_id_array(array_index) AND
                                 request_set_id = req_set_id_array(array_index) AND
                                 request_set_stage_id = req_set_stage_id_array(array_index);
        END IF;

        IF (bad_EL = bad_stage_id)  THEN
                        UPDATE fnd_request_set_stages SET error_link = NULL WHERE
                                 set_application_id = set_app_id_array(array_index) AND
                                 request_set_id = req_set_id_array(array_index) AND
                                 request_set_stage_id = req_set_stage_id_array(array_index);
        END IF;
  END LOOP;
--BUG 871226  (End of Added Code)

  exception
    when no_data_found then -- We don't care.
      null;
  end;

  delete from FND_REQUEST_SET_PROGRAM_ARGS
   where (application_id, request_set_id, request_set_program_id)
      in (select set_application_id, request_set_id, request_set_program_id
            from fnd_request_set_programs
           where set_application_id =  x_set_application_id
             and request_set_id = x_request_set_id
             and request_set_stage_id = x_request_set_stage_id);

  delete from fnd_request_set_programs
   where set_application_id =  x_set_application_id
     and request_set_id = x_request_set_id
     and request_set_stage_id = x_request_set_stage_id;

  delete from FND_STAGE_FN_PARAMETER_VALUES
  where SET_APPLICATION_ID = X_SET_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID
  and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID;

  delete from FND_REQUEST_SET_STAGES
  where SET_APPLICATION_ID = X_SET_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID
  and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_REQUEST_SET_STAGES_TL
  where SET_APPLICATION_ID = X_SET_APPLICATION_ID
  and REQUEST_SET_ID = X_REQUEST_SET_ID
  and REQUEST_SET_STAGE_ID = X_REQUEST_SET_STAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_REQUEST_SET_STAGES_TL T
  where not exists
    (select NULL
    from FND_REQUEST_SET_STAGES B
    where B.REQUEST_SET_ID = T.REQUEST_SET_ID
    and B.SET_APPLICATION_ID = T.SET_APPLICATION_ID
    and B.REQUEST_SET_STAGE_ID = T.REQUEST_SET_STAGE_ID
    );

  update FND_REQUEST_SET_STAGES_TL T set (
      USER_STAGE_NAME,
      DESCRIPTION
    ) = (select
      B.USER_STAGE_NAME,
      B.DESCRIPTION
    from FND_REQUEST_SET_STAGES_TL B
    where B.REQUEST_SET_ID = T.REQUEST_SET_ID
    and B.SET_APPLICATION_ID = T.SET_APPLICATION_ID
    and B.REQUEST_SET_STAGE_ID = T.REQUEST_SET_STAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REQUEST_SET_ID,
      T.SET_APPLICATION_ID,
      T.REQUEST_SET_STAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REQUEST_SET_ID,
      SUBT.SET_APPLICATION_ID,
      SUBT.REQUEST_SET_STAGE_ID,
      SUBT.LANGUAGE
    from FND_REQUEST_SET_STAGES_TL SUBB, FND_REQUEST_SET_STAGES_TL SUBT
    where SUBB.REQUEST_SET_ID = SUBT.REQUEST_SET_ID
    and SUBB.SET_APPLICATION_ID = SUBT.SET_APPLICATION_ID
    and SUBB.REQUEST_SET_STAGE_ID = SUBT.REQUEST_SET_STAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_STAGE_NAME <> SUBT.USER_STAGE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_REQUEST_SET_STAGES_TL (
    SET_APPLICATION_ID,
    REQUEST_SET_ID,
    REQUEST_SET_STAGE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_STAGE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SET_APPLICATION_ID,
    B.REQUEST_SET_ID,
    B.REQUEST_SET_STAGE_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.USER_STAGE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_REQUEST_SET_STAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_REQUEST_SET_STAGES_TL T
    where T.REQUEST_SET_ID = B.REQUEST_SET_ID
    and T.SET_APPLICATION_ID = B.SET_APPLICATION_ID
    and T.REQUEST_SET_STAGE_ID = B.REQUEST_SET_STAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_REQUEST_SET_STAGES_PKG;

/
