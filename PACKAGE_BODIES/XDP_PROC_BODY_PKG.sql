--------------------------------------------------------
--  DDL for Package Body XDP_PROC_BODY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PROC_BODY_PKG" AS
/* $Header: XDPPBDYB.pls 120.2 2005/07/15 01:52:00 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_PROC_NAME in VARCHAR2,
  X_PROC_SPEC in VARCHAR2,
  X_PROC_BODY in VARCHAR2,
  X_PROC_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROTECTED_FLAG in VARCHAR2 := 'N'
) is
  cursor C is select ROWID from XDP_PROC_BODY
    where PROC_NAME = X_PROC_NAME
    ;
        lv_lob_i          CLOB;
begin
-- Bug Fix 1489219.
-- Removed references to CLOB

   insert into XDP_PROC_BODY (
                   proc_name,
                   proc_type,
                   protected_flag,
                   proc_spec,
                   proc_body,
                   creation_date,
                   created_by,
                   last_update_date,
                   last_updated_by,
                   last_update_login )
            values
                   (X_PROC_NAME,
                    X_PROC_TYPE,
                    X_PROTECTED_FLAG,
                    X_PROC_SPEC,
                    empty_clob(),
                    sysdate,
                    X_CREATED_BY,
                    sysdate,
                    X_LAST_UPDATED_BY,
                    0)
    returning proc_body into lv_lob_i;

    dbms_lob.write(lv_lob_i, length(X_PROC_BODY), 1, X_PROC_BODY);

      insert into XDP_PROC_BODY_TL (
                   proc_name,
                   display_name,
                   description,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   language,
                   source_lang
               ) select
                   X_PROC_NAME,
                   X_DISPLAY_NAME,
                   X_DESCRIPTION,
                   X_CREATED_BY,
                   sysdate,
                   X_LAST_UPDATED_BY,
                   sysdate,
                   0,
                   L.LANGUAGE_CODE,
                   userenv('LANG')
                from FND_LANGUAGES L
               where L.INSTALLED_FLAG in ('I', 'B')
                 and not exists
                    (select NULL
                       from XDP_PROC_BODY_TL T
                      where T.PROC_NAME = X_PROC_NAME
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
  X_PROC_NAME in VARCHAR2,
  X_PROC_SPEC in VARCHAR2,
  X_PROC_BODY in CLOB,
  X_PROC_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2 := 'N'
) is
  cursor c is select
      PROC_BODY,
      PROC_SPEC,
      PROC_TYPE,
      PROTECTED_FLAG
    from XDP_PROC_BODY
    where PROC_NAME = X_PROC_NAME
    for update of PROC_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_PROC_BODY_TL
    where PROC_NAME = X_PROC_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROC_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (DBMS_LOB.COMPARE (recinfo.PROC_BODY, X_PROC_BODY, DBMS_LOB.GETLENGTH(X_PROC_BODY), 1, 1) = 0)
      AND (recinfo.PROC_TYPE = X_PROC_TYPE)
      AND (recinfo.PROC_SPEC = X_PROC_SPEC)
      AND (recinfo.PROTECTED_FLAG = X_PROTECTED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_PROC_NAME in VARCHAR2,
  X_PROC_SPEC in VARCHAR2,
  X_PROC_BODY in VARCHAR2,
  X_PROC_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROTECTED_FLAG in VARCHAR2 := 'N'
) is
        lv_lob_u          CLOB;
begin

-- Bug Fix 1489219.
-- Removed references to CLOB

          update XDP_PROC_BODY
            set
              proc_spec = X_PROC_SPEC,
              proc_body = empty_clob(),
              proc_type = X_PROC_TYPE,
              protected_flag = X_PROTECTED_FLAG,
              last_updated_by = X_LAST_UPDATED_BY,
              last_update_date = sysdate,
              last_update_login = 0
           where
              proc_name = X_PROC_NAME
              returning proc_body into lv_lob_u;

              if sql%notfound then
                raise NO_DATA_FOUND;
              end if;

              DBMS_LOB.WRITE(lv_lob_u,length(X_PROC_BODY),1,X_PROC_BODY);


           update XDP_PROC_BODY_TL
             set
              display_name = X_DISPLAY_NAME,
              description = X_DESCRIPTION,
              last_updated_by = X_LAST_UPDATED_BY,
              last_update_date = sysdate,
              last_update_login = 0,
              source_lang = userenv('LANG')
           where proc_name = X_PROC_NAME
             and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

             if sql%notfound then
                raise NO_DATA_FOUND;
              end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROC_NAME in VARCHAR2
) is
begin
  delete from XDP_PROC_BODY_TL
  where PROC_NAME = X_PROC_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_PROC_BODY
  where PROC_NAME = X_PROC_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_PROC_BODY_TL T
  where not exists
    (select NULL
    from XDP_PROC_BODY B
    where B.PROC_NAME = T.PROC_NAME
    );



/******

-- rephrased the query to use EXISTS ratherthan using IN
-- skilaru 03/26/2001

  update XDP_PROC_BODY_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XDP_PROC_BODY_TL B
    where B.PROC_NAME = T.PROC_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROC_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.PROC_NAME,
      SUBT.LANGUAGE
    from XDP_PROC_BODY_TL SUBB, XDP_PROC_BODY_TL SUBT
    where SUBB.PROC_NAME = SUBT.PROC_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

*****/


 update   XDP_PROC_BODY_TL T
    set ( DISPLAY_NAME, DESCRIPTION) = (select B.DISPLAY_NAME, B.DESCRIPTION
                                          from XDP_PROC_BODY_TL B
                                         where B.PROC_NAME = T.PROC_NAME
                                           and B.LANGUAGE = T.SOURCE_LANG)
  where EXISTS (select SUBT.PROC_NAME, SUBT.LANGUAGE
                  from XDP_PROC_BODY_TL SUBB, XDP_PROC_BODY_TL SUBT
                 where SUBB.PROC_NAME = SUBT.PROC_NAME
                   and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                   and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
                        or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                        or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
                        or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null))
                   and SUBT.proc_name =  T.PROC_NAME
                   and SUBT.language  =  T.LANGUAGE
               );


  insert into XDP_PROC_BODY_TL (
    PROC_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PROC_NAME,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_PROC_BODY_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_PROC_BODY_TL T
    where T.PROC_NAME = B.PROC_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_PROC_NAME in VARCHAR2,
  X_PROC_SPEC in VARCHAR2,
  X_PROC_BODY in VARCHAR2,
  X_PROC_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2 := 'N'
  ) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     /* The following derivation has been replaced with the FND API.		dputhiye 15-JUL-2005. R12 ATG "Seed Version by Date" Uptake */
     --if (X_OWNER = 'SEED') then
     --   user_id := 1;
     --end if;
     user_id := fnd_load_util.owner_id(X_OWNER);

     XDP_PROC_BODY_PKG.UPDATE_ROW (
  	X_PROC_NAME => X_PROC_NAME,
  	X_PROC_SPEC => X_PROC_SPEC,
  	X_PROC_BODY => X_PROC_BODY,
  	X_PROC_TYPE => X_PROC_TYPE,
  	X_DISPLAY_NAME => X_DISPLAY_NAME,
  	X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0,
  		X_PROTECTED_FLAG => X_PROTECTED_FLAG);

    exception
       when NO_DATA_FOUND then
          XDP_PROC_BODY_PKG.INSERT_ROW (
             	X_ROWID => row_id,
  		X_PROC_NAME => X_PROC_NAME,
  		X_PROC_SPEC => X_PROC_SPEC,
  		X_PROC_BODY => X_PROC_BODY,
  		X_PROC_TYPE => X_PROC_TYPE,
  		X_DISPLAY_NAME => X_DISPLAY_NAME,
  		X_DESCRIPTION => X_DESCRIPTION,
             	X_CREATION_DATE => sysdate,
             	X_CREATED_BY => user_id,
             	X_LAST_UPDATE_DATE => sysdate,
             	X_LAST_UPDATED_BY => user_id,
             	X_LAST_UPDATE_LOGIN => 0 ,
  				X_PROTECTED_FLAG => X_PROTECTED_FLAG);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_PROC_NAME in VARCHAR2,
   X_DISPLAY_NAME in VARCHAR2,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_PROC_BODY_TL
    set  description = X_DESCRIPTION,
        display_name = X_DISPLAY_NAME,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 15-JUL-2005. DECODE replaced with FND API.*/
	last_updated_by = fnd_load_util.owner_id(X_OWNER),
        last_update_login = 0
  where proc_name = X_PROC_NAME
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


end XDP_PROC_BODY_PKG;

/
