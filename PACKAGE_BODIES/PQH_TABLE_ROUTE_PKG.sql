--------------------------------------------------------
--  DDL for Package Body PQH_TABLE_ROUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TABLE_ROUTE_PKG" as
/* $Header: pqtrtpkg.pkb 120.2 2005/10/12 20:20:30 srajakum noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TABLE_ROUTE_ID in NUMBER,
  X_SHADOW_TABLE_ROUTE_ID in NUMBER,
  X_FROM_CLAUSE in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_MAP_REQUIRED_FLAG in VARCHAR2,
  X_SELECT_ALLOWED_FLAG in VARCHAR2,
  X_HIDE_TABLE_FOR_VIEW_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_x_rowid varchar2(100) := x_rowid;

  cursor C is select ROWID from PQH_TABLE_ROUTE
    where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID
    ;
begin
  insert into PQH_TABLE_ROUTE (
    TABLE_ROUTE_ID,
    SHADOW_TABLE_ROUTE_ID,
    FROM_CLAUSE,
    TABLE_ALIAS,
    WHERE_CLAUSE,
    OBJECT_VERSION_NUMBER,
    DISPLAY_NAME,
    MAP_REQUIRED_FLAG ,
    SELECT_ALLOWED_FLAG ,
    HIDE_TABLE_FOR_VIEW_FLAG ,
    DISPLAY_ORDER ,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TABLE_ROUTE_ID,
    X_SHADOW_TABLE_ROUTE_ID,
    X_FROM_CLAUSE,
    X_TABLE_ALIAS,
    X_WHERE_CLAUSE,
    X_OBJECT_VERSION_NUMBER,
    X_DISPLAY_NAME,
    X_MAP_REQUIRED_FLAG ,
    X_SELECT_ALLOWED_FLAG ,
    X_HIDE_TABLE_FOR_VIEW_FLAG ,
    X_DISPLAY_ORDER ,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PQH_TABLE_ROUTE_TL (
    TABLE_ROUTE_ID,
    DISPLAY_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TABLE_ROUTE_ID,
    X_DISPLAY_NAME,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PQH_TABLE_ROUTE_TL T
    where T.TABLE_ROUTE_ID = X_TABLE_ROUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  exception when others then
   l_x_rowid := null;
  raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_TABLE_ROUTE_ID in NUMBER,
  X_SHADOW_TABLE_ROUTE_ID in NUMBER,
  X_FROM_CLAUSE in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      SHADOW_TABLE_ROUTE_ID,
      FROM_CLAUSE,
      TABLE_ALIAS,
      WHERE_CLAUSE,
      OBJECT_VERSION_NUMBER
    from PQH_TABLE_ROUTE
    where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID
    for update of TABLE_ROUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PQH_TABLE_ROUTE_TL
    where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TABLE_ROUTE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SHADOW_TABLE_ROUTE_ID = X_SHADOW_TABLE_ROUTE_ID)
           OR ((recinfo.SHADOW_TABLE_ROUTE_ID is null) AND (X_SHADOW_TABLE_ROUTE_ID is null)))
      AND ((recinfo.FROM_CLAUSE = X_FROM_CLAUSE)
           OR ((recinfo.FROM_CLAUSE is null) AND (X_FROM_CLAUSE is null)))
      AND ((recinfo.TABLE_ALIAS = X_TABLE_ALIAS)
           OR ((recinfo.TABLE_ALIAS is null) AND (X_TABLE_ALIAS is null)))
      AND ((recinfo.WHERE_CLAUSE = X_WHERE_CLAUSE)
           OR ((recinfo.WHERE_CLAUSE is null) AND (X_WHERE_CLAUSE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
               OR ((tlinfo.DISPLAY_NAME is null) AND (X_DISPLAY_NAME is null)))
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
  X_TABLE_ROUTE_ID in NUMBER,
  X_SHADOW_TABLE_ROUTE_ID in NUMBER,
  X_FROM_CLAUSE in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_MAP_REQUIRED_FLAG in VARCHAR2,
  X_SELECT_ALLOWED_FLAG in VARCHAR2,
  X_HIDE_TABLE_FOR_VIEW_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PQH_TABLE_ROUTE set
    SHADOW_TABLE_ROUTE_ID = X_SHADOW_TABLE_ROUTE_ID,
    FROM_CLAUSE = X_FROM_CLAUSE,
    TABLE_ALIAS = X_TABLE_ALIAS,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DISPLAY_NAME = X_DISPLAY_NAME,
    MAP_REQUIRED_FLAG = X_MAP_REQUIRED_FLAG ,
    SELECT_ALLOWED_FLAG = X_SELECT_ALLOWED_FLAG ,
    HIDE_TABLE_FOR_VIEW_FLAG = X_HIDE_TABLE_FOR_VIEW_FLAG ,
    DISPLAY_ORDER = X_DISPLAY_ORDER ,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID ;
-- TRT contains only seed Data and should be updated nevertheless.
--    and nvl(last_updated_by,-1) in (1,-1);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PQH_TABLE_ROUTE_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TABLE_ROUTE_ID in NUMBER
) is
begin
  delete from PQH_TABLE_ROUTE_TL
  where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PQH_TABLE_ROUTE
  where TABLE_ROUTE_ID = X_TABLE_ROUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PQH_TABLE_ROUTE_TL T
  where not exists
    (select NULL
    from PQH_TABLE_ROUTE B
    where B.TABLE_ROUTE_ID = T.TABLE_ROUTE_ID
    );

  update PQH_TABLE_ROUTE_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from PQH_TABLE_ROUTE_TL B
    where B.TABLE_ROUTE_ID = T.TABLE_ROUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TABLE_ROUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TABLE_ROUTE_ID,
      SUBT.LANGUAGE
    from PQH_TABLE_ROUTE_TL SUBB, PQH_TABLE_ROUTE_TL SUBT
    where SUBB.TABLE_ROUTE_ID = SUBT.TABLE_ROUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or (SUBB.DISPLAY_NAME is null and SUBT.DISPLAY_NAME is not null)
      or (SUBB.DISPLAY_NAME is not null and SUBT.DISPLAY_NAME is null)
  ));

  insert into PQH_TABLE_ROUTE_TL (
    TABLE_ROUTE_ID,
    DISPLAY_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TABLE_ROUTE_ID,
    B.DISPLAY_NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_TABLE_ROUTE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_TABLE_ROUTE_TL T
    where T.TABLE_ROUTE_ID = B.TABLE_ROUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



procedure LOAD_ROW (
  p_table_alias              IN VARCHAR2,
  p_shadow_table             IN VARCHAR2,
  p_from_clause              IN VARCHAR2,
  p_where_clause             IN VARCHAR2,
  p_display_name             IN VARCHAR2,
  p_map_required_flag        IN VARCHAR2,
  p_select_allowed_flag      IN VARCHAR2,
  p_hide_table_for_view_flag IN VARCHAR2,
  p_display_order            IN NUMBER,
  p_last_update_date         IN VARCHAR2,
  p_owner                    IN VARCHAR2
) is


l_table_route_id           pqh_table_route.table_route_id%TYPE;
l_shadow_table_route_id    pqh_table_route.shadow_table_route_id%TYPE;
l_from_clause              pqh_table_route.from_clause%TYPE;
l_table_alias              pqh_table_route.table_alias%TYPE;
l_where_clause             pqh_table_route.where_clause%TYPE;
l_display_name             pqh_table_route.display_name%TYPE;
l_rowid                    ROWID;
l_map_required_flag        pqh_table_route.map_required_flag%TYPE;
l_select_allowed_flag      pqh_table_route.select_allowed_flag%TYPE;
l_hide_table_for_view_flag pqh_table_route.hide_table_for_view_flag%TYPE;
l_display_order            pqh_table_route.display_order%TYPE;


l_created_by               pqh_table_route.created_by%TYPE;
l_last_updated_by          pqh_table_route.last_updated_by%TYPE;
l_creation_date            pqh_table_route.creation_date%TYPE;
l_last_update_date         pqh_table_route.last_update_date%TYPE;
l_last_update_login        pqh_table_route.last_update_login%TYPE;
--
l_last_upd_in_db           pqh_table_route.last_update_date%TYPE;
--
cursor csr_table_route_id is
select table_route_id,last_update_date
from pqh_table_route
where table_alias = p_table_alias;

cursor csr_shadow_table_route_id is
select table_route_id
from pqh_table_route
where table_alias = p_shadow_table;

begin

-- get ids for names

  OPEN csr_table_route_id;
   FETCH csr_table_route_id INTO l_table_route_id,l_last_upd_in_db;
  CLOSE csr_table_route_id;

  OPEN csr_shadow_table_route_id;
   FETCH csr_shadow_table_route_id INTO l_shadow_table_route_id;
  CLOSE csr_shadow_table_route_id;

--
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := -1;
  else
    l_created_by := 0;
    l_last_updated_by := -1;
  end if;
  **/

  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_login := 0;
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by := fnd_load_util.owner_id(p_owner);

  If l_table_route_id is not null then

   If l_last_update_date >  l_last_upd_in_db then
   UPDATE_ROW (
     X_TABLE_ROUTE_ID            =>  l_table_route_id,
     X_SHADOW_TABLE_ROUTE_ID     =>  l_shadow_table_route_id,
     X_FROM_CLAUSE               =>  p_from_clause,
     X_TABLE_ALIAS               =>  p_table_alias,
     X_WHERE_CLAUSE              =>  p_where_clause,
     X_OBJECT_VERSION_NUMBER     =>  1,
     X_DISPLAY_NAME              =>  p_display_name,
     X_MAP_REQUIRED_FLAG         =>  p_map_required_flag,
     X_SELECT_ALLOWED_FLAG       =>  p_select_allowed_flag,
     X_HIDE_TABLE_FOR_VIEW_FLAG  =>  p_hide_table_for_view_flag,
     X_DISPLAY_ORDER             =>  p_display_order,
     X_LAST_UPDATE_DATE          =>  l_last_update_date,
     X_LAST_UPDATED_BY           =>  l_last_updated_by,
     X_LAST_UPDATE_LOGIN         =>  l_last_update_login
    );
   End if;

   else
     -- select table_route_id into local variable.
        select pqh_table_route_s.nextval into l_table_route_id from dual;

       INSERT_ROW (
         X_ROWID                     =>  l_rowid,
         X_TABLE_ROUTE_ID            =>  l_table_route_id ,
         X_SHADOW_TABLE_ROUTE_ID     =>  l_shadow_table_route_id,
         X_FROM_CLAUSE               =>  p_from_clause,
         X_TABLE_ALIAS               =>  p_table_alias,
         X_WHERE_CLAUSE              =>  p_where_clause,
         X_OBJECT_VERSION_NUMBER     =>  1,
         X_DISPLAY_NAME              =>  p_display_name,
         X_MAP_REQUIRED_FLAG         =>  p_map_required_flag,
         X_SELECT_ALLOWED_FLAG       =>  p_select_allowed_flag,
         X_HIDE_TABLE_FOR_VIEW_FLAG  =>  p_hide_table_for_view_flag,
         X_DISPLAY_ORDER             =>  p_display_order,
         X_CREATION_DATE             =>  l_creation_date,
         X_CREATED_BY                =>  l_created_by,
         X_LAST_UPDATE_DATE          =>  l_last_update_date,
         X_LAST_UPDATED_BY           =>  l_last_updated_by,
         X_LAST_UPDATE_LOGIN         =>  l_last_update_login
       );
    End if;
  /**
  begin
   UPDATE_ROW (
     X_TABLE_ROUTE_ID            =>  l_table_route_id,
     X_SHADOW_TABLE_ROUTE_ID     =>  l_shadow_table_route_id,
     X_FROM_CLAUSE               =>  p_from_clause,
     X_TABLE_ALIAS               =>  p_table_alias,
     X_WHERE_CLAUSE              =>  p_where_clause,
     X_OBJECT_VERSION_NUMBER     =>  1,
     X_DISPLAY_NAME              =>  p_display_name,
     X_MAP_REQUIRED_FLAG         =>  p_map_required_flag,
     X_SELECT_ALLOWED_FLAG       =>  p_select_allowed_flag,
     X_HIDE_TABLE_FOR_VIEW_FLAG  =>  p_hide_table_for_view_flag,
     X_DISPLAY_ORDER             =>  p_display_order,
     X_LAST_UPDATE_DATE          =>  l_last_update_date,
     X_LAST_UPDATED_BY           =>  l_last_updated_by,
     X_LAST_UPDATE_LOGIN         =>  l_last_update_login
    );

  exception
     when NO_DATA_FOUND then
     -- select table_route_id into local variable.
        select pqh_table_route_s.nextval into l_table_route_id from dual;

       INSERT_ROW (
         X_ROWID                     =>  l_rowid,
         X_TABLE_ROUTE_ID            =>  l_table_route_id ,
         X_SHADOW_TABLE_ROUTE_ID     =>  l_shadow_table_route_id,
         X_FROM_CLAUSE               =>  p_from_clause,
         X_TABLE_ALIAS               =>  p_table_alias,
         X_WHERE_CLAUSE              =>  p_where_clause,
         X_OBJECT_VERSION_NUMBER     =>  1,
         X_DISPLAY_NAME              =>  p_display_name,
         X_MAP_REQUIRED_FLAG         =>  p_map_required_flag,
         X_SELECT_ALLOWED_FLAG       =>  p_select_allowed_flag,
         X_HIDE_TABLE_FOR_VIEW_FLAG  =>  p_hide_table_for_view_flag,
         X_DISPLAY_ORDER             =>  p_display_order,
         X_CREATION_DATE             =>  l_creation_date,
         X_CREATED_BY                =>  l_created_by,
         X_LAST_UPDATE_DATE          =>  l_last_update_date,
         X_LAST_UPDATED_BY           =>  l_last_updated_by,
         X_LAST_UPDATE_LOGIN         =>  l_last_update_login
       );
  end;
  **/

end LOAD_ROW;



procedure TRANSLATE_ROW (
    p_table_alias               in varchar2,
    p_display_name              in varchar2,
    p_owner                     in varchar2) is

cursor csr_table_route_id is
 select table_route_id
 from pqh_table_route
 where table_alias = p_table_alias;

l_table_route_id         pqh_table_route.table_route_id%TYPE;
l_created_by             pqh_table_route.created_by%TYPE;
l_last_updated_by        pqh_table_route.last_updated_by%TYPE;
l_creation_date          pqh_table_route.creation_date%TYPE;
l_last_update_date       pqh_table_route.last_update_date%TYPE;
l_last_update_login      pqh_table_route.last_update_login%TYPE;


begin
-- get table_route_id
  OPEN csr_table_route_id;
   FETCH csr_table_route_id INTO l_table_route_id;
  CLOSE csr_table_route_id;
--
-- populate WHO columns
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := -1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;

  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  l_last_updated_by := fnd_load_util.owner_id(p_owner);

    update pqh_table_route_tl
    set display_name      = p_display_name ,
        last_update_date  = l_last_update_date,
        last_updated_by   = l_last_updated_by,
        last_update_login = l_last_update_login,
        source_lang = USERENV('LANG')
    where USERENV('LANG') in (language,source_lang)
    and table_route_id  = l_table_route_id ;
--
end translate_row;

-- Added for R12 Seed Data versioning
--
procedure LOAD_SEED_ROW (
  p_upload_mode              IN VARCHAR2,
  p_table_alias              IN VARCHAR2,
  p_shadow_table             IN VARCHAR2,
  p_from_clause              IN VARCHAR2,
  p_where_clause             IN VARCHAR2,
  p_display_name             IN VARCHAR2,
  p_map_required_flag        IN VARCHAR2,
  p_select_allowed_flag      IN VARCHAR2,
  p_hide_table_for_view_flag IN VARCHAR2,
  p_display_order            IN NUMBER,
  p_last_update_date         IN VARCHAR2,
  p_owner                    IN VARCHAR2
) is
--
l_data_migrator_mode varchar2(1);
--
Begin
--
   l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';

       if (p_upload_mode = 'NLS') then
         PQH_TABLE_ROUTE_PKG.translate_row (
             p_table_alias    => p_table_alias,
             p_display_name   => p_display_name,
             p_owner          => p_owner );
       else
        pqh_table_route_pkg.load_row
            ( p_table_alias              => p_table_alias,
              p_shadow_table             => p_shadow_table,
              p_from_clause              => p_from_clause,
              p_where_clause             => p_where_clause,
              p_display_name             => p_display_name,
              p_map_required_flag        => p_map_required_flag,
              p_select_allowed_flag      => p_select_allowed_flag,
              p_hide_table_for_view_flag => p_hide_table_for_view_flag,
              p_display_order            => p_display_order,
              p_last_update_date         => p_last_update_date,
              p_owner                    => p_owner );
      end if;
   hr_general.g_data_migrator_mode := l_data_migrator_mode;

End;
--
end PQH_TABLE_ROUTE_PKG;

/
