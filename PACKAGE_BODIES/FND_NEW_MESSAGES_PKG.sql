--------------------------------------------------------
--  DDL for Package Body FND_NEW_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_NEW_MESSAGES_PKG" as
/* $Header: AFMDMSGB.pls 120.4.12000000.1 2007/01/18 13:20:55 appldev ship $ */

PROCEDURE CHECK_COMPATIBILITY is
  sqlbuf		VARCHAR2(1000);
  v_catg		VARCHAR2(10);
  v_sev			VARCHAR2(10);
  v_log_sev		NUMBER;

  COL_NOT_FOUND		EXCEPTION;

  PRAGMA EXCEPTION_INIT(COL_NOT_FOUND, -904);
BEGIN

  sqlbuf := 	'SELECT category, severity, fnd_log_severity
		 FROM   fnd_new_messages
		 WHERE  ROWNUM < 2';

  begin

    execute immediate sqlbuf into v_catg, v_sev, v_log_sev;

    ADDN_COLS := 'Y';

  exception
   when COL_NOT_FOUND then
    ADDN_COLS := 'N';
   when NO_DATA_FOUND then
    ADDN_COLS := 'Y';
  end;

END CHECK_COMPATIBILITY;


procedure ADD_LANGUAGE
is
  sql_string  varchar2(6000);
begin

/***** Commented Update Statement

  update FND_NEW_MESSAGES T set (
      MESSAGE_TEXT
    ) = (select
      B.MESSAGE_TEXT
    from FND_NEW_MESSAGES B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.LANGUAGE_CODE = T.LANGUAGE_CODE
    and B.MESSAGE_NAME = T.MESSAGE_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.LANGUAGE_CODE,
      T.MESSAGE_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.LANGUAGE_CODE,
      SUBT.MESSAGE_NAME,
      SUBT.LANGUAGE
    from FND_NEW_MESSAGES SUBB, FND_NEW_MESSAGES SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LANGUAGE_CODE = SUBT.LANGUAGE_CODE
    and SUBB.MESSAGE_NAME = SUBT.MESSAGE_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MESSAGE_TEXT <> SUBT.MESSAGE_TEXT
  ));

  insert into FND_NEW_MESSAGES (
    FND_LOG_SEVERITY,
    APPLICATION_ID,
    LANGUAGE_CODE,
    MESSAGE_NUMBER,
    MESSAGE_NAME,
    MESSAGE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    TYPE,
    MAX_LENGTH,
    CATEGORY,
    SEVERITY
  ) select -- Dropped ORDERED hint here
    B.FND_LOG_SEVERITY,
    B.APPLICATION_ID,
    L.LANGUAGE_CODE,
    B.MESSAGE_NUMBER,
    B.MESSAGE_NAME,
    B.MESSAGE_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.TYPE,
    B.MAX_LENGTH,
    B.CATEGORY,
    B.SEVERITY
  from FND_NEW_MESSAGES B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE_CODE = userenv('LANG')
  and not exists
    (select NULL
    from FND_NEW_MESSAGES T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.LANGUAGE_CODE = L.LANGUAGE_CODE
    and T.MESSAGE_NAME = B.MESSAGE_NAME);
  ******************/

  -- Above Insert Statement is commented and the below line code is written
  -- which executes the insert statement according to which DB
  -- (category/severity present or not present) is being used.
  -- This is backward compatible for upgrades.

   fnd_new_messages_pkg.check_compatibility;

sql_string := 'insert into FND_NEW_MESSAGES (
    APPLICATION_ID,
    LANGUAGE_CODE,
    MESSAGE_NUMBER,
    MESSAGE_NAME,
    MESSAGE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    TYPE,
    MAX_LENGTH ';

    if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
        sql_string := sql_string || ',CATEGORY,
                                      SEVERITY,
                                      FND_LOG_SEVERITY ';
    end if;

    sql_string := sql_string ||
      ') select /*+ ORDERED */
    B.APPLICATION_ID,
    L.LANGUAGE_CODE,
    B.MESSAGE_NUMBER,
    B.MESSAGE_NAME,
    B.MESSAGE_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.TYPE,
    B.MAX_LENGTH ';

    if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
       sql_string := sql_string ||
       ', B.CATEGORY,
        B.SEVERITY,
        B.FND_LOG_SEVERITY ';
    end if;

    sql_string := sql_string ||
      ' from FND_NEW_MESSAGES B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in (''I'', ''B'')
    and B.LANGUAGE_CODE = ''' || userenv('LANG') || '''' ||
    ' and not exists
    (select NULL
    from FND_NEW_MESSAGES T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.LANGUAGE_CODE = L.LANGUAGE_CODE
    and T.MESSAGE_NAME = B.MESSAGE_NAME)';

   execute immediate sql_string;
end ADD_LANGUAGE;


/* Overloaded Version Below */
procedure LOAD_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_NUMBER in VARCHAR2,
  X_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_MAX_LENGTH in VARCHAR2,
  X_CATEGORY in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_FND_LOG_SEVERITY in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_new_messages_pkg.LOAD_ROW (
    X_APPLICATION_ID   => X_APPLICATION_ID,
    X_MESSAGE_NAME     => X_MESSAGE_NAME,
    X_MESSAGE_NUMBER   => X_MESSAGE_NUMBER,
    X_MESSAGE_TEXT     => X_MESSAGE_TEXT,
    X_DESCRIPTION      => X_DESCRIPTION,
    X_TYPE             => X_TYPE,
    X_MAX_LENGTH       => X_MAX_LENGTH,
    X_CATEGORY         => X_CATEGORY,
    X_SEVERITY         => X_SEVERITY,
    X_FND_LOG_SEVERITY => X_FND_LOG_SEVERITY,
    X_OWNER            => X_OWNER,
    X_CUSTOM_MODE      => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end LOAD_ROW;

/* Overloaded Version Above */
procedure LOAD_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_NUMBER in VARCHAR2,
  X_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_MAX_LENGTH in VARCHAR2,
  X_CATEGORY in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_FND_LOG_SEVERITY in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
  f_luby number;  -- entity owner in file
  f_ludate date;  -- entity update date in file
  db_luby number; -- entity owner in db
  db_ludate date; -- entity update date in db

  app_id   number := x_application_id;

  sql_string  varchar2(6000);

  --bug3331476 modified and added variables for binds
  --fnd_log_severity  number := X_FND_LOG_SEVERITY;
  --max_length        number := X_MAX_LENGTH;
  --message_number    number := X_MESSAGE_NUMBER;

  fnd_log_severity  number;
  max_length        number;
  message_number    number;

  msg_type          varchar2(30);
  category          varchar2(10);
  severity          varchar2(10);

  description       varchar2(240);
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  --select application_id into app_id
  --from   fnd_application
  --where  application_short_name = X_APPLICATION_SHORT_NAME;

  --if (X_MAX_LENGTH IS NULL) then
      --max_length := NULL;
  --end if;

  --if (X_MESSAGE_NUMBER IS NULL) then
      --message_number := NULL;
  --end if;

  --if (X_FND_LOG_SEVERITY is NULL) then
      --fnd_log_severity := NULL;
  --end if;

    select decode(X_MESSAGE_NUMBER, fnd_load_util.null_value, null,
                  null, X_MESSAGE_NUMBER,
                  TO_NUMBER(X_MESSAGE_NUMBER)),
           decode(X_TYPE, fnd_load_util.null_value, null,
                  null, X_TYPE,
                  X_TYPE),
           decode(X_DESCRIPTION, fnd_load_util.null_value, null,
                  null, X_DESCRIPTION,
                  X_DESCRIPTION),
           decode(X_MAX_LENGTH, fnd_load_util.null_value, null,
                  null, X_MAX_LENGTH,
                  TO_NUMBER(X_MAX_LENGTH)),
           decode(X_CATEGORY, fnd_load_util.null_value, null,
                  null, X_CATEGORY,
                  X_CATEGORY),
           decode(X_SEVERITY, fnd_load_util.null_value, null,
                  null, X_SEVERITY,
                  X_SEVERITY),
           decode(X_FND_LOG_SEVERITY, fnd_load_util.null_value, null,
                  null, X_FND_LOG_SEVERITY,
                  TO_NUMBER(X_FND_LOG_SEVERITY))
           into   message_number,
                  msg_type,
                  description,
                  max_length,
                  category,
                  severity,
                  fnd_log_severity
           from dual;

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_NEW_MESSAGES
    where application_id = app_id
    and language_code = userenv('LANG')
    and message_name = X_MESSAGE_NAME;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
       -- bug 2747318
       -- According to which DB (category/severity present or not present)
       -- is being used, the correct section will execute for update.
       -- This is backward compatible for upgrades.

       -- bug3331476 Modified the following update and insert sql
       -- statements to use bind values instead of all concatenation.

       -- bug 3562652 Removed language_code from update sql_string so
       -- non-translatable values in all language rows will be updated.
       -- Moved message_text to sql_string2 so message_text will be
       -- updated for the current language only.  NLS mode handles
       -- updating message_text for translations.

       sql_string := 'update fnd_new_messages set
          message_number = :1,
          description = :2,
          type =  :3,
          max_length =  :4,';

       if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then

          sql_string := sql_string ||
          'category = :5,
          severity = :6,
          fnd_log_severity = :7,';

       end if;

       sql_string := sql_string ||
          'last_updated_by = :8,
          last_update_date = :9,
          last_update_login = 0
          where application_id = :10
          and message_name = :11';

       if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then

           execute immediate sql_string USING message_number,
                   description, msg_type, max_length,
                   category, severity, fnd_log_severity,
                   f_luby, f_ludate, app_id, X_MESSAGE_NAME;

       else
           execute immediate sql_string USING message_number,
                   description, msg_type, max_length,
                   f_luby, f_ludate, app_id, X_MESSAGE_NAME;

       end if;

       -- bug 3562652 Added to handle TRANS attribute
       sql_string := 'update fnd_new_messages set
          message_text = :1
          where application_id = :2
          and message_name = :3
          and language_code = ''' || userenv('LANG') || '''';

       execute immediate sql_string USING X_MESSAGE_TEXT,
               app_id, X_MESSAGE_NAME;
    end if;
  exception
    when no_data_found then
      -- bug 2747318
      -- According to which DB (category/severity present or not present)
      -- is being used, the correct section will execute for insertion.
      -- This is backward compatible for upgrades.

     sql_string := 'insert into fnd_new_messages
        (application_id,
         language_code,
         message_number,
         message_name,
         message_text,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         description,
         type,
         max_length ';

      if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
        sql_string := sql_string || ',category,
                                      severity,
                                      fnd_log_severity ';
      end if;

      sql_string := sql_string ||
        ') values (
         :1,
         ''' ||  userenv('LANG') || ''', ' ||
          ':2,
          :3,
          :4,
          :5,
          :6,
          :7,
          :8,
          0,
          :9,
          :10,
          :11';

      if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
         sql_string := sql_string ||
         ', :12,
          :13,
         :14) ';
      else
         sql_string := sql_string || ')';
      end if;

      if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then

         execute immediate sql_string USING app_id, message_number,
                 X_MESSAGE_NAME, X_MESSAGE_TEXT,
                 f_ludate, f_luby, f_ludate, f_luby,
                 description, msg_type, max_length,
                 category, severity, fnd_log_severity;
     else
         execute immediate sql_string USING app_id, message_number,
                 X_MESSAGE_NAME, X_MESSAGE_TEXT,
                 f_ludate, f_luby, f_ludate, f_luby,
                 description, msg_type, max_length;
     end if;
  end;
end LOAD_ROW;

/* Overloaded Version Below */
procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_new_messages_pkg.TRANSLATE_ROW (
    X_APPLICATION_ID    => X_APPLICATION_ID,
    X_MESSAGE_NAME      => X_MESSAGE_NAME,
    X_MESSAGE_TEXT      => X_MESSAGE_TEXT,
    X_OWNER             => X_OWNER,
    X_CUSTOM_MODE       => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE  => null
  );
end TRANSLATE_ROW;


/* Overloaded Version Above */
procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
  f_luby number;  -- entity owner in file
  f_ludate date;  -- entity update date in file
  db_luby number; -- entity owner in db
  db_ludate date; -- entity update date in db
  app_id   number := x_application_id;

  sql_string  varchar2(6000);
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  --select application_id into app_id
  --from   fnd_application
  --where  application_short_name = X_APPLICATION_SHORT_NAME;

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_NEW_MESSAGES
    where application_id = app_id
    and language_code = userenv('LANG')
    and message_name = X_MESSAGE_NAME;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
       update fnd_new_messages set
               message_text      = nvl(X_MESSAGE_TEXT, message_text),
               last_updated_by   = f_luby,
               last_update_date  = f_ludate,
               last_update_login = 0
             where application_id = app_id
             and   language_code  = userenv('LANG')
             and   message_name   = X_MESSAGE_NAME;
    end if;
  exception
    when no_data_found then

      -- According to which DB (category/severity present or not present)
      -- is being used, the correct section will execute for insertion.
      -- This is backward compatible for upgrades.

      -- If row is not found during NLS mode, then just default the data from
      -- any language, with a preference for US first, then Base,
      -- then anything else

     sql_string := 'insert into fnd_new_messages
        (application_id,
         language_code,
         message_number,
         message_name,
         message_text,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         description,
         type,
         max_length ';

      if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
        sql_string := sql_string || ',category,
                                      severity,
                                      fnd_log_severity ';
      end if;

      sql_string := sql_string ||
        ') select
         application_id,
         ''' ||  userenv('LANG') || ''', ' ||
          'message_number,
          message_name,
          :1,
          :2,
          :3,
          :4,
          :5,
          0,
          description,
          type,
          max_length';

      if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
         sql_string := sql_string ||
         ', category,
          severity,
          fnd_log_severity ';
      end if;

      sql_string := sql_string ||
        ' from (select
                  application_id,
                  language_code,
                  message_number,
                  message_name,
                  message_text,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  description,
                  type,
                  max_length ';

      if (FND_NEW_MESSAGES_PKG.ADDN_COLS = 'Y') then
        sql_string := sql_string || ',category,
                                      severity,
                                      fnd_log_severity ';
      end if;


      sql_string := sql_string ||
              ' from fnd_new_messages
                where application_id = :6
                and   message_name = :7
                order by decode(language_code, ''US'', 1,
                                   (select L.language_code from fnd_languages L
                                    where L.installed_flag = ''B''), 2,
                                3)
           )
           where rownum = 1';

      execute immediate sql_string USING X_MESSAGE_TEXT,
              f_ludate, f_luby, f_ludate, f_luby,
              app_id, X_MESSAGE_NAME;

  end;
end TRANSLATE_ROW;


procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LANGUAGE_CODE in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2
) is
begin

  delete from FND_NEW_MESSAGES
  where APPLICATION_ID = X_APPLICATION_ID
  and   LANGUAGE_CODE  = X_LANGUAGE_CODE
  and   MESSAGE_NAME   = X_MESSAGE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

---------------VALIDATION PROCEDURE BEGIN-----------------------


procedure CHECK_MESSAGE_TYPE (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2
 ) is
begin

    -- ******************************
    -- Check for invalid Types
    -- ******************************

    if X_TYPE is not NULL
      and X_TYPE not in
               ('ERROR', 'NOTE', 'HINT', 'TITLE',
                     '30_PCT_EXPANSION_PROMPT',
                     '50_PCT_EXPANSION_PROMPT',
                     '100_PCT_EXPANSION_PROMPT',
                     'MENU', 'TOKEN', 'OTHER') then
      fnd_message.set_name('FND', 'AFDICT_VAL_INVALID_TYPE');
      fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
      fnd_message.set_token('TYPE', X_TYPE);
      app_exception.raise_exception();
    end if;

end CHECK_MESSAGE_TYPE;


procedure CHECK_MESSAGE_DESCRIPTION (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_DESCRIPTION in VARCHAR2
 ) is
begin

    -- ******************************
    -- Check for Descriptions against Types
    -- ******************************

    if X_TYPE in ('OTHER', 'TOKEN')
       and X_DESCRIPTION is null then
       fnd_message.set_name('FND', 'AFDICT_VAL_NEED_DESCR');
       fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
       fnd_message.set_token('TYPE', X_TYPE);
       app_exception.raise_exception();
    end if;

end CHECK_MESSAGE_DESCRIPTION;


procedure CHECK_MAX_LENGTH_TYPE (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_MAX_LENGTH in NUMBER
 ) is
begin

    -- ******************************
    -- Check for Max Length against Types
    -- ******************************
    if(X_TYPE not in ('ERROR', 'NOTE', 'TOKEN', 'OTHER')
       and X_TYPE is not null
       and X_MAX_LENGTH is not null) then
       fnd_message.set_name('FND', 'AFDICT_VAL_MAX_LEN_NOTNULL');
       fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
       fnd_message.set_token('TYPE', X_TYPE);
       app_exception.raise_exception();
    end if;

end CHECK_MAX_LENGTH_TYPE;


/* OverLoaded */
procedure CHECK_MAX_LEN_MSG_LEN (
 X_MESSAGE_NAME in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2,
 X_MAX_LENGTH in NUMBER
 ) is
begin
  CHECK_MAX_LEN_MSG_LEN (
    X_MESSAGE_NAME   => X_MESSAGE_NAME,
    X_MESSAGE_TEXT   => X_MESSAGE_TEXT,
    X_MAX_LENGTH     => X_MAX_LENGTH,
    X_VALIDATION     => null);
end CHECK_MAX_LEN_MSG_LEN;


procedure CHECK_MAX_LEN_MSG_LEN (
 X_MESSAGE_NAME in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2,
 X_MAX_LENGTH in NUMBER,
 X_VALIDATION in VARCHAR2
 ) is

  limit_length number:=0;
  trans_length integer := 0;
  actual_length number:=0;

begin

    -- ******************************
    -- Check whether message exceeds Max Length bytes
    -- ******************************
    if(X_MAX_LENGTH is not null) then
       actual_length := lengthb(X_MESSAGE_TEXT);
       limit_length  := X_MAX_LENGTH;
       trans_length  := limit_length/1.3;
       if (actual_length > limit_length) then
           if ((X_VALIDATION is not null) and (X_VALIDATION='POST_TRANSLATE'))
              or (X_VALIDATION is null) then
              fnd_message.set_name('FND', 'AFDICT_VAL_MAXLEN_SMALL');
              fnd_message.set_token('MESSAGE_NAME',  X_MESSAGE_NAME);
              fnd_message.set_token('MESSAGE_TEXT_LENGTH',  actual_length);
              fnd_message.set_token('MAXIMUM_LENGTH',       limit_length);
              app_exception.raise_exception();
           end if;
       end if;
       if (actual_length > trans_length) then
           if ((X_VALIDATION is not null) and (X_VALIDATION='STRICT'))
           then
              fnd_message.set_name('FND', 'AFDICT_VAL_MAXLEN_SMALL_TRN');
              fnd_message.set_token('MESSAGE_NAME',  X_MESSAGE_NAME);
              fnd_message.set_token('MESSAGE_TEXT_LENGTH',  actual_length);
              fnd_message.set_token('MAXIMUM_LENGTH',       limit_length);
              fnd_message.set_token('TRANSLATED_MAXIMUM_LENGTH',
                                     trans_length);
              app_exception.raise_exception();
           end if;
       end if;
    end if;

end CHECK_MAX_LEN_MSG_LEN;



procedure CHECK_TOKENS_ACCESS_KEYS (
 X_MESSAGE_NAME in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2
 ) is
  line        varchar2(2000);
  token       varchar2(2000);
  i           number:=0;
  j           number:=0;
  l_start     number:=0;
  l_end       number:=0;
  punctuation   varchar2(80);
begin


     -- ******************************
    -- Check for Tokens and Access Keys
    -- ******************************

    punctuation := fnd_global.newline||'`~!@#$%^*()-=+|][{}\";:,.<>/?''';
    i:=99999;
    j:=1;
    while (i <> 0) loop
        line := ltrim(rtrim(translate(X_MESSAGE_TEXT,
                      punctuation,'                              ')));

        i := instr(line, '&', 1, j);

        if i=0 then
           exit;
        end if;

        if i=1 then
           l_start:=1;
        else
           l_start := instr(substr(line,1,i), ' ', -1);
           if l_start=0 then
              l_start:=1;
           end if;
        end if;

        l_end:=instr(substr(line,i), ' ', 1);

        if l_end=0 then
           l_end := length(line);
           token := substr(line, l_start);
        else
           l_end := l_end + i;
           token := substr(line, l_start, l_end-l_start);
        end if;

        token := ltrim(rtrim(token));

        if (substr(token,1,1) <> '&') and (instr(token,'&&',1)=0) then
           fnd_message.set_name('FND', 'AFDICT_VAL_SINGLE_AMP_MIDDLE');
           fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
           fnd_message.set_token('WORD', token);
           app_exception.raise_exception();
        end if;

        if upper(token)=token and instr(token,'&&',1)>0 then
           fnd_message.set_name('FND', 'AFDICT_VAL_DOUBLE_AMP_UPPER');
           fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
           fnd_message.set_token('WORD', token);
           app_exception.raise_exception();
        end if;

        if upper(token)<>token and substr(token,1,1)='&'
           and substr(token,2,1)<>'&' then
           fnd_message.set_name('FND', 'AFDICT_VAL_SINGLE_AMP_MIXED');
           fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
           fnd_message.set_token('WORD', token);
           app_exception.raise_exception();
        end if;

        if substr(line, i+1,1)='&' then
           j := j + 2;
        else
           j := j + 1;
        end if;

    end loop;

end CHECK_TOKENS_ACCESS_KEYS;

/* OverLoaded */
procedure CHECK_TYPE_RULES (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2
 ) is
begin
  CHECK_TYPE_RULES (
    X_MESSAGE_NAME    => X_MESSAGE_NAME,
    X_TYPE            => X_TYPE,
    X_MESSAGE_TEXT    => X_MESSAGE_TEXT,
    X_VALIDATION      => null);
end CHECK_TYPE_RULES;


procedure CHECK_TYPE_RULES (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2,
 X_VALIDATION  in VARCHAR2
 ) is
  limit_length number:=0;
  trans_length integer := 0;
  actual_length number:=0;
  trans_ratio number:=0;
begin

    -- ******************************
    -- Messages not following Type Rules
    -- ******************************
    trans_ratio:=1.3;
    if X_TYPE in ('50_PCT_EXPANSION_PROMPT') then
       trans_ratio := 1.5;
    elsif X_TYPE in ('100_PCT_EXPANSION_PROMPT') then
       trans_ratio := 2.0;
    end if;

    limit_length := 1800;
    if X_TYPE in ('ERROR', 'NOTE', 'OTHER') then
       limit_length := 1800;
    elsif X_TYPE in ('HINT') then
       limit_length := 250;
    elsif X_TYPE in ('TITLE') then
       limit_length := 80;
    elsif X_TYPE in ('MENU') then
       limit_length := 60;
    elsif X_TYPE is NULL then
       limit_length := 1800;
    elsif X_TYPE in ('30_PCT_EXPANSION_PROMPT',
    '50_PCT_EXPANSION_PROMPT', '100_PCT_EXPANSION_PROMPT') then
       limit_length := 1800;

    end if;

    actual_length := lengthb(X_MESSAGE_TEXT);
    trans_length  := limit_length/trans_ratio;
    if (actual_length > limit_length) then
       if ((X_VALIDATION is not null) and (X_VALIDATION='POST_TRANSLATE'))
	  or (X_VALIDATION is null) then
	   fnd_message.set_name('FND', 'AFDICT_VAL_TYPELEN_SMALL');
	   fnd_message.set_token('MESSAGE_NAME',  X_MESSAGE_NAME);
	   fnd_message.set_token('MESSAGE_TEXT_LENGTH',  actual_length);
	   fnd_message.set_token('MAXIMUM_LENGTH',       limit_length);
	   fnd_message.set_token('TYPE', X_TYPE);
	   app_exception.raise_exception();
       end if;
    end if;
    if lengthb(X_MESSAGE_TEXT) > trans_length then
       if ((X_VALIDATION is not null) and (X_VALIDATION='STRICT'))
       then
	   fnd_message.set_name('FND', 'AFDICT_VAL_TYPELEN_SMALL_TRN');
	   fnd_message.set_token('MESSAGE_NAME',  X_MESSAGE_NAME);
	   fnd_message.set_token('MESSAGE_TEXT_LENGTH',  actual_length);
	   fnd_message.set_token('MAXIMUM_LENGTH',       limit_length);
	   fnd_message.set_token('TRANSLATED_MAXIMUM_LENGTH', trans_length);
	   fnd_message.set_token('TYPE', X_TYPE);
	   app_exception.raise_exception();
       end if;
    end if;

end CHECK_TYPE_RULES;


procedure CHECK_MAXIMUM_LENGTH_RANGE (
  X_MAX_LENGTH in NUMBER,
  X_MESSAGE_NAME in VARCHAR2
) is
begin

    -- ******************************
    -- Check for Max Length range
    -- ******************************
    if(X_MAX_LENGTH is not null
       and (X_MAX_LENGTH < 10 or X_MAX_LENGTH > 1800)) then
       fnd_message.set_name('FND', 'AFDICT_VAL_MAXLEN_RANGE');
       fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
       fnd_message.set_token('MAXIMUM_LENGTH', X_MAX_LENGTH);
       fnd_message.set_token('MINIMUM', 10);
       fnd_message.set_token('MAXIMUM', 1800);
       app_exception.raise_exception();
    end if;


end CHECK_MAXIMUM_LENGTH_RANGE;


procedure CHECK_CATEGORY_SEVERITY (
  X_CATEGORY in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_FND_LOG_SEVERITY in NUMBER,
  X_MESSAGE_NAME in VARCHAR2
) is
  -- counters to determine checking of columns in POST-TRANS/STRICT check
  count_category  number:=0;
  count_severity  number:=0;
begin

    -- bug 2747318
    -- If no data is present for category or severity because no lookup_type
    -- exist, then skip the validation; otherwise, continue on to check if
    -- there are values present.
    -- This is backward compatible for upgrades.
    -- ******************************
    -- Check for valid Category
    -- ******************************
    if (X_CATEGORY is not NULL) then
       select count(*) into count_category from fnd_lookups
         where lookup_type = 'FND_KBF_CATEGORY';
       if ( count_category > 0 ) then
          select count(*) into count_category from fnd_lookups
            where lookup_type = 'FND_KBF_CATEGORY' AND
                  lookup_code = X_CATEGORY;
          if ( count_category = 0 ) then
             fnd_message.set_name('FND', 'AFDICT_CATEGORY_NOT_VALID');
             fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
             fnd_message.set_token('CATEGORY', X_CATEGORY);
             app_exception.raise_exception();
          end if;
       end if;
    end if;
    -- ******************************
    -- Check for valid Severity
    -- ******************************
    if (X_SEVERITY is not NULL) then
       select count(*) into count_severity from fnd_lookups
         where lookup_type = 'FND_KBF_SEVERITY';
       if ( count_severity > 0 ) then
          select count(*) into count_severity from fnd_lookups
            where lookup_type = 'FND_KBF_SEVERITY' AND
                  lookup_code = X_SEVERITY;
          if ( count_severity = 0 ) then
             fnd_message.set_name('FND', 'AFDICT_SEVERITY_NOT_VALID');
             fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
             fnd_message.set_token('SEVERITY', X_SEVERITY);
             app_exception.raise_exception();
          end if;
       end if;
    end if;
    -- ******************************
    -- Check for valid Fnd_Log_Severity
    -- ******************************
    if (X_FND_LOG_SEVERITY is not NULL) then
       select count(*) into count_severity from fnd_lookups
         where lookup_type = 'AFLOG_LEVELS';
       if ( count_severity > 0 ) then
          select count(*) into count_severity from fnd_lookups
            where lookup_type = 'AFLOG_LEVELS' AND
                  lookup_code = X_FND_LOG_SEVERITY;
          if ( count_severity = 0 ) then
             fnd_message.set_name('FND', 'AFDICT_SEVERITY_NOT_VALID');
             fnd_message.set_token('MESSAGE_NAME', X_MESSAGE_NAME);
             fnd_message.set_token('SEVERITY', X_FND_LOG_SEVERITY);
             app_exception.raise_exception();
          end if;
       end if;
    end if;

end CHECK_CATEGORY_SEVERITY;

end FND_NEW_MESSAGES_PKG;

/
