--------------------------------------------------------
--  DDL for Package Body CS_SR_SAVED_SEARCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_SAVED_SEARCHES_PKG" as
/* $Header: csxtssmb.pls 120.0 2006/01/10 11:48:14 jngeorge noship $*/

procedure INSERT_ROW (  X_ROWID in out nocopy VARCHAR2,
		    X_SEARCH_ID in out nocopy NUMBER,
		    X_OBJECT_VERSION_NUMBER in NUMBER,
		    X_USER_ID in VARCHAR2,
		    X_NAME in VARCHAR2,
		    X_CREATION_DATE in DATE,
		    X_CREATED_BY in NUMBER,
		    X_LAST_UPDATE_DATE in DATE,
		    X_LAST_UPDATED_BY in NUMBER,
		    X_LAST_UPDATE_LOGIN in NUMBER) is

	 cursor C is select ROWID from CS_SR_SAVED_SEARCHES_B                            where SEARCH_ID = X_SEARCH_ID    ;

begin
        select CS_SR_SAVED_SEARCHES_S.NEXTVAL  into x_Search_id from dual;

        Insert into CS_SR_SAVED_SEARCHES_B (
                     OBJECT_VERSION_NUMBER,
                     SEARCH_ID,
                     USER_ID,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN  )
        values (
                      X_OBJECT_VERSION_NUMBER,
		      X_SEARCH_ID,
		      X_USER_ID,
		      X_CREATION_DATE,
		      X_CREATED_BY,
		      X_LAST_UPDATE_DATE,
                      X_LAST_UPDATED_BY,
                      X_LAST_UPDATE_LOGIN  );

	insert into CS_SR_SAVED_SEARCHES_TL (
                      CREATION_DATE,
	              CREATED_BY,
		      LAST_UPDATE_LOGIN,
                      NAME,
                      SEARCH_ID,
		      LAST_UPDATE_DATE,
		      LAST_UPDATED_BY,
		      LANGUAGE,
		      SOURCE_LANG  )
        select        X_CREATION_DATE,
                      X_CREATED_BY,
                      X_LAST_UPDATE_LOGIN,
                      X_NAME,
                      X_SEARCH_ID,
                      X_LAST_UPDATE_DATE,
                      X_LAST_UPDATED_BY,
                      L.LANGUAGE_CODE,
                      userenv('LANG')
        from FND_LANGUAGES L  where L.INSTALLED_FLAG in ('I', 'B')
	    and not exists    ( select NULL  from CS_SR_SAVED_SEARCHES_TL T
				where T.SEARCH_ID = X_SEARCH_ID
                                and T.LANGUAGE = L.LANGUAGE_CODE);

	 open c;
	 fetch c into X_ROWID;

	 if (c%notfound) then
                      close c;
                      raise no_data_found;
         end if;

	 close c;

end INSERT_ROW;

procedure DELETE_ROW (  X_SEARCH_ID in NUMBER) is
begin

  delete from CS_SR_SAVED_SEARCHES_TL  where SEARCH_ID = X_SEARCH_ID;

  if  (sql%notfound) then
        raise no_data_found;
  end if;

 delete from CS_SR_SAVED_SEARCHES_B  where SEARCH_ID = X_SEARCH_ID;

 if (sql%notfound) then
     raise no_data_found;
 end if ;

 commit;

end DELETE_ROW;

PROCEDURE ADD_LANGUAGE is
BEGIN

delete from CS_SR_SAVED_SEARCHES_TL T
where not exists
 (select NULL     from  CS_SR_SAVED_SEARCHES_B B
  where B.SEARCH_ID = T.SEARCH_ID    );

 update CS_SR_SAVED_SEARCHES_TL T set (
              NAME ) = ( select B.NAME from CS_SR_SAVED_SEARCHES_TL B
                         where B.SEARCH_ID = T.SEARCH_ID
                         and B.LANGUAGE = T.SOURCE_LANG)
                         where ( T.SEARCH_ID,T.LANGUAGE  ) in
                             (select  SUBT.SEARCH_ID,  SUBT.LANGUAGE
                              from CS_SR_SAVED_SEARCHES_TL SUBB,
                              CS_SR_SAVED_SEARCHES_TL SUBT
                              where SUBB.SEARCH_ID = SUBT.SEARCH_ID
                              and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                              and (SUBB.NAME <> SUBT.NAME  or
                                 (SUBB.NAME is null and SUBT.NAME is not null)
                              or (SUBB.NAME is not null and SUBT.NAME is null)  ));

 insert into CS_SR_SAVED_SEARCHES_TL (
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     NAME,
                     SECURITY_GROUP_ID,
                     SEARCH_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LANGUAGE,
                     SOURCE_LANG  )
 select         B.CREATION_DATE,
                B.CREATED_BY,
                B.LAST_UPDATE_LOGIN,
                B.NAME,
                B.SECURITY_GROUP_ID,
                B.SEARCH_ID,
                B.LAST_UPDATE_DATE,
                B.LAST_UPDATED_BY,
                L.LANGUAGE_CODE,
                B.SOURCE_LANG
 from CS_SR_SAVED_SEARCHES_TL B, FND_LANGUAGES L
 where L.INSTALLED_FLAG in ('I', 'B')  and B.LANGUAGE = userenv('LANG')
 and not exists    (select NULL    from CS_SR_SAVED_SEARCHES_TL T
                    where T.SEARCH_ID = B.SEARCH_ID
                    and T.LANGUAGE =L.LANGUAGE_CODE);
end ADD_LANGUAGE;
end CS_SR_SAVED_SEARCHES_PKG;

/
