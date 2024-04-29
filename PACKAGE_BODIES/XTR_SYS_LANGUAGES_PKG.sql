--------------------------------------------------------
--  DDL for Package Body XTR_SYS_LANGUAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_SYS_LANGUAGES_PKG" as
/* $Header: xtrlangb.pls 120.3 2005/06/29 10:10:50 badiredd ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XTR_SYS_LANGUAGES
    where MODULE_NAME = X_MODULE_NAME
    and CANVAS_TYPE = X_CANVAS_TYPE
    and ITEM_NAME = X_ITEM_NAME
    ;
  v_rowid	VARCHAR2(30);
begin
  insert into XTR_SYS_LANGUAGES (
    MODULE_NAME,
    CANVAS_TYPE,
    ITEM_NAME,
    ORIGINAL_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MODULE_NAME,
    X_CANVAS_TYPE,
    X_ITEM_NAME,
    X_ORIGINAL_TEXT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XTR_SYS_LANGUAGES_TL (
    MODULE_NAME,
    TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CANVAS_TYPE,
    ITEM_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MODULE_NAME,
    X_TEXT,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CANVAS_TYPE,
    X_ITEM_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XTR_SYS_LANGUAGES_TL T
    where T.MODULE_NAME = X_MODULE_NAME
    and T.CANVAS_TYPE = X_CANVAS_TYPE
    and T.ITEM_NAME = X_ITEM_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into v_rowid;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure LOAD_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT VARCHAR2,
  X_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2 )
 is
 begin
  declare
   row_id  varchar2(64);
   user_id number ;
   begin
   if ( X_OWNER ='SEED')
   then
      user_id:=1;
   else
      user_id:=0;
   end if;
   xtr_sys_languages_pkg.update_row (
         x_module_name => X_MODULE_NAME,
         x_canvas_type => X_CANVAS_TYPE,
         x_item_name   => X_ITEM_NAME,
         x_original_text        => X_ORIGINAL_TEXT ,
         x_text        => X_TEXT ,
         x_lang        => null,
         x_last_update_date => sysdate ,
         x_last_updated_by => user_id,
         x_last_update_login => 0);
   exception
     when no_data_found then
       xtr_sys_languages_pkg.insert_row(
       X_ROWID => row_id,
       x_module_name => X_MODULE_NAME,
       x_canvas_type => X_CANVAS_TYPE,
       x_item_name   => X_ITEM_NAME,
       x_original_text => X_ORIGINAL_TEXT,
       x_text        => X_TEXT ,
       x_creation_date => sysdate,
       x_created_by    => 1,
       x_last_update_date => sysdate ,
       x_last_updated_by =>user_id,
       x_last_update_login => 0);
   end;
end LOAD_ROW;

procedure LOCK_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2
) is
  cursor c1 is select
      TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XTR_SYS_LANGUAGES_TL
    where MODULE_NAME = X_MODULE_NAME
    and CANVAS_TYPE = X_CANVAS_TYPE
    and ITEM_NAME = X_ITEM_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MODULE_NAME nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TEXT = X_TEXT)
               OR ((tlinfo.TEXT is null) AND (X_TEXT is null)))
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
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_LANG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
/*  Update Logic

     File           Database         Update
 ---------------------------------------------
     CUSTOM         SEED              Yes
     CUSTOM         CUSTOM            Yes
     SEED           CUSTOM            No
     SEED           SEED              YES
*/


begin
  declare
   l_last_updated_by   number;
   l_original_text   varchar2(100);
  begin
        /* need to update xtr_sys_languages if original_text
           is changed */
        select  original_text
        into l_original_text
        from xtr_sys_languages
  	where MODULE_NAME = X_MODULE_NAME
  	and CANVAS_TYPE = X_CANVAS_TYPE
        and ITEM_NAME = X_ITEM_NAME;

        if ((l_original_text <> x_original_text)
            and
            (x_original_text is not null))
        then
    		update XTR_SYS_LANGUAGES set
    		ORIGINAL_TEXT = X_ORIGINAL_TEXT,
    		LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    		LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  	     		where MODULE_NAME = X_MODULE_NAME
  	     		and CANVAS_TYPE = X_CANVAS_TYPE
             		and ITEM_NAME = X_ITEM_NAME;
         end if;

        /* end of change for update of original_text */
        select last_updated_by
        into l_last_updated_by
        from xtr_sys_languages_tl
  	where MODULE_NAME = X_MODULE_NAME
  	and CANVAS_TYPE = X_CANVAS_TYPE
        and ITEM_NAME = X_ITEM_NAME
  	and LANGUAGE = userenv('LANG') ;

        If ( l_last_updated_by = 1 or x_last_updated_by <> 1)
	/* Update as long as Database is not CUSTOM and File is SEED */
        then
    		update XTR_SYS_LANGUAGES_TL set
    		TEXT = X_TEXT,
    		LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    		LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
		SOURCE_LANG = userenv('LANG')
  	     		where MODULE_NAME = X_MODULE_NAME
  	     		and CANVAS_TYPE = X_CANVAS_TYPE
             		and ITEM_NAME = X_ITEM_NAME
                        and LANGUAGE = nvl(X_LANG, userenv('LANG'))
  	     		and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

	  	if (sql%notfound) then
    		   raise no_data_found;
	        end if;
 	end if;
  end;
end UPDATE_ROW;


procedure TRANSLATE_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2
) is
Begin
declare
user_id number;
 begin

   if ( X_OWNER ='SEED')
   then
      user_id:=1;
   else
      user_id:=0;
   end if;
   xtr_sys_languages_pkg.update_row (
         x_module_name => X_MODULE_NAME,
         x_canvas_type => X_CANVAS_TYPE,
         x_item_name   => X_ITEM_NAME,
         x_original_text        => X_ORIGINAL_TEXT ,
         x_text        => X_TEXT ,
         x_last_update_date => sysdate ,
         x_last_updated_by => user_id,
         x_last_update_login => 0);

/* update XTR_SYS_LANGUAGES_TL set
    TEXT = X_TEXT,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = 1,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where MODULE_NAME = X_MODULE_NAME
  and CANVAS_TYPE = X_CANVAS_TYPE
  and ITEM_NAME = X_ITEM_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
*/

end;
end TRANSLATE_ROW;


procedure DELETE_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2
) is
begin
  delete from XTR_SYS_LANGUAGES_TL
  where MODULE_NAME = X_MODULE_NAME
  and CANVAS_TYPE = X_CANVAS_TYPE
  and ITEM_NAME = X_ITEM_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XTR_SYS_LANGUAGES
  where MODULE_NAME = X_MODULE_NAME
  and CANVAS_TYPE = X_CANVAS_TYPE
  and ITEM_NAME = X_ITEM_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XTR_SYS_LANGUAGES_TL T
  where not exists
    (select NULL
    from XTR_SYS_LANGUAGES B
    where B.MODULE_NAME = T.MODULE_NAME
    and B.CANVAS_TYPE = T.CANVAS_TYPE
    and B.ITEM_NAME = T.ITEM_NAME
    );

  update XTR_SYS_LANGUAGES_TL T set (
      TEXT
    ) = (select
      B.TEXT
    from XTR_SYS_LANGUAGES_TL B
    where B.MODULE_NAME = T.MODULE_NAME
    and B.CANVAS_TYPE = T.CANVAS_TYPE
    and B.ITEM_NAME = T.ITEM_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MODULE_NAME,
      T.CANVAS_TYPE,
      T.ITEM_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.MODULE_NAME,
      SUBT.CANVAS_TYPE,
      SUBT.ITEM_NAME,
      SUBT.LANGUAGE
    from XTR_SYS_LANGUAGES_TL SUBB, XTR_SYS_LANGUAGES_TL SUBT
    where SUBB.MODULE_NAME = SUBT.MODULE_NAME
    and SUBB.CANVAS_TYPE = SUBT.CANVAS_TYPE
    and SUBB.ITEM_NAME = SUBT.ITEM_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEXT <> SUBT.TEXT
      or (SUBB.TEXT is null and SUBT.TEXT is not null)
      or (SUBB.TEXT is not null and SUBT.TEXT is null)
  ));

  insert into XTR_SYS_LANGUAGES_TL (
    MODULE_NAME,
    TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CANVAS_TYPE,
    ITEM_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MODULE_NAME,
    B.TEXT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CANVAS_TYPE,
    B.ITEM_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XTR_SYS_LANGUAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XTR_SYS_LANGUAGES_TL T
    where T.MODULE_NAME = B.MODULE_NAME
    and T.CANVAS_TYPE = B.CANVAS_TYPE
    and T.ITEM_NAME = B.ITEM_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end XTR_SYS_LANGUAGES_PKG;

/
