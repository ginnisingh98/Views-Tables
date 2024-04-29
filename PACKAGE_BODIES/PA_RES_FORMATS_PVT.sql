--------------------------------------------------------
--  DDL for Package Body PA_RES_FORMATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_FORMATS_PVT" as
/* $Header: PARFMTVB.pls 120.0 2005/05/30 09:50:49 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY ROWID,
  P_RES_FORMAT_ID             in NUMBER,
  P_RESOURCE_FORMAT_SEQ       in NUMBER,
  P_RESOURCE_CLASS_ID         in NUMBER,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_ENABLED_FLAG     in VARCHAR2,
  P_RESOURCE_TYPE_DISP_CHARS  in NUMBER,
  P_ORGN_ENABLED_FLAG         in VARCHAR2,
  P_ORGN_DISP_CHARS           in NUMBER,
  P_FIN_CAT_ENABLED_FLAG      in VARCHAR2,
  P_FIN_CAT_DISP_CHARS        in NUMBER,
  P_INCURRED_BY_ENABLED_FLAG  in VARCHAR2,
  P_INCURRED_BY_DISP_CHARS    in NUMBER,
  P_SUPPLIER_ENABLED_FLAG     in VARCHAR2,
  P_SUPPLIER_DISP_CHARS       in NUMBER,
  P_ROLE_ENABLED_FLAG         in VARCHAR2,
  P_ROLE_DISP_CHARS           in NUMBER,
  P_RESOURCE_CLASS_FLAG       in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_CREATION_DATE             in DATE    ,
  P_CREATED_BY                in NUMBER  ,
  P_LAST_UPDATE_DATE          in DATE    ,
  P_LAST_UPDATED_BY           in NUMBER  ,
  P_LAST_UPDATE_LOGIN         in NUMBER
) is

  l_res_format_id pa_res_formats_b.res_format_id%type;


  cursor C is select ROWID from pa_res_formats_b
    where res_format_id = l_res_format_id;
begin

  select nvl(P_RES_FORMAT_ID,PA_RES_FORMATS_S.nextval)
  into   l_res_format_id
  from   dual;

  insert into pa_res_formats_b (
    RES_FORMAT_ID              ,
    RESOURCE_FORMAT_SEQ        ,
    RESOURCE_CLASS_ID          ,
    RES_TYPE_ID                ,
    RES_TYPE_ENABLED_FLAG      ,
    RESOURCE_TYPE_DISP_CHARS   ,
    ORGN_ENABLED_FLAG          ,
    ORGN_DISP_CHARS            ,
    FIN_CAT_ENABLED_FLAG       ,
    FIN_CAT_DISP_CHARS         ,
    INCURRED_BY_ENABLED_FLAG   ,
    INCURRED_BY_DISP_CHARS     ,
    SUPPLIER_ENABLED_FLAG      ,
    SUPPLIER_DISP_CHARS        ,
    ROLE_ENABLED_FLAG          ,
    ROLE_DISP_CHARS            ,
    RESOURCE_CLASS_FLAG        ,
    CREATION_DATE              ,
    CREATED_BY                 ,
    LAST_UPDATE_DATE           ,
    LAST_UPDATED_BY            ,
    LAST_UPDATE_LOGIN
  ) values (
    L_RES_FORMAT_ID            ,
    P_RESOURCE_FORMAT_SEQ      ,
    P_RESOURCE_CLASS_ID        ,
    P_RES_TYPE_ID              ,
    P_RES_TYPE_ENABLED_FLAG    ,
    P_RESOURCE_TYPE_DISP_CHARS ,
    P_ORGN_ENABLED_FLAG        ,
    P_ORGN_DISP_CHARS          ,
    P_FIN_CAT_ENABLED_FLAG     ,
    P_FIN_CAT_DISP_CHARS       ,
    P_INCURRED_BY_ENABLED_FLAG ,
    P_INCURRED_BY_DISP_CHARS   ,
    P_SUPPLIER_ENABLED_FLAG    ,
    P_SUPPLIER_DISP_CHARS      ,
    P_ROLE_ENABLED_FLAG        ,
    P_ROLE_DISP_CHARS          ,
    P_RESOURCE_CLASS_FLAG      ,
    P_CREATION_DATE            ,
    P_CREATED_BY               ,
    P_LAST_UPDATE_DATE         ,
    P_LAST_UPDATED_BY          ,
    P_LAST_UPDATE_LOGIN
  );

  insert into pa_res_formats_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RES_FORMAT_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_LAST_UPDATE_LOGIN,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    L_RES_FORMAT_ID,
    P_NAME,
    P_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from pa_res_formats_tl T
    where T.RES_FORMAT_ID = L_RES_FORMAT_ID
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
  P_RES_FORMAT_ID                  in NUMBER
 ) is
  cursor c is select
    RESOURCE_FORMAT_SEQ        ,
    RESOURCE_CLASS_ID          ,
    RES_TYPE_ID                ,
    RES_TYPE_ENABLED_FLAG      ,
    RESOURCE_TYPE_DISP_CHARS   ,
    ORGN_ENABLED_FLAG          ,
    ORGN_DISP_CHARS            ,
    FIN_CAT_ENABLED_FLAG       ,
    FIN_CAT_DISP_CHARS         ,
    INCURRED_BY_ENABLED_FLAG   ,
    INCURRED_BY_DISP_CHARS     ,
    SUPPLIER_ENABLED_FLAG      ,
    SUPPLIER_DISP_CHARS        ,
    ROLE_ENABLED_FLAG          ,
    ROLE_DISP_CHARS            ,
    RESOURCE_CLASS_FLAG
    from pa_res_formats_b
    where RES_FORMAT_ID = P_RES_FORMAT_ID
    for update of RES_FORMAT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from pa_res_formats_tl
    where RES_FORMAT_ID = P_RES_FORMAT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RES_FORMAT_ID nowait;
begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  return;

end LOCK_ROW;

procedure UPDATE_ROW (
  P_RES_FORMAT_ID             in NUMBER,
  P_RESOURCE_FORMAT_SEQ       in NUMBER,
  P_RESOURCE_CLASS_ID         in NUMBER,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_ENABLED_FLAG     in VARCHAR2,
  P_RESOURCE_TYPE_DISP_CHARS  in NUMBER,
  P_ORGN_ENABLED_FLAG         in VARCHAR2,
  P_ORGN_DISP_CHARS           in NUMBER,
  P_FIN_CAT_ENABLED_FLAG      in VARCHAR2,
  P_FIN_CAT_DISP_CHARS        in NUMBER,
  P_INCURRED_BY_ENABLED_FLAG  in VARCHAR2,
  P_INCURRED_BY_DISP_CHARS    in NUMBER,
  P_SUPPLIER_ENABLED_FLAG     in VARCHAR2,
  P_SUPPLIER_DISP_CHARS       in NUMBER,
  P_ROLE_ENABLED_FLAG         in VARCHAR2,
  P_ROLE_DISP_CHARS           in NUMBER,
  P_RESOURCE_CLASS_FLAG       in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_LAST_UPDATE_DATE          in DATE    ,
  P_LAST_UPDATED_BY           in NUMBER  ,
  P_LAST_UPDATE_LOGIN         in NUMBER
) is
begin
  update pa_res_formats_b set
    RESOURCE_FORMAT_SEQ        = P_RESOURCE_FORMAT_SEQ,
    RESOURCE_CLASS_ID          = P_RESOURCE_CLASS_ID,
    RES_TYPE_ID                = P_RES_TYPE_ID,
    RES_TYPE_ENABLED_FLAG      = P_RES_TYPE_ENABLED_FLAG,
    RESOURCE_TYPE_DISP_CHARS   = P_RESOURCE_TYPE_DISP_CHARS,
    ORGN_ENABLED_FLAG          = P_ORGN_ENABLED_FLAG,
    ORGN_DISP_CHARS            = P_ORGN_DISP_CHARS,
    FIN_CAT_ENABLED_FLAG       = P_FIN_CAT_ENABLED_FLAG,
    FIN_CAT_DISP_CHARS         = P_FIN_CAT_DISP_CHARS,
    INCURRED_BY_ENABLED_FLAG   = P_INCURRED_BY_ENABLED_FLAG,
    INCURRED_BY_DISP_CHARS     = P_INCURRED_BY_DISP_CHARS,
    SUPPLIER_ENABLED_FLAG      = P_SUPPLIER_ENABLED_FLAG,
    SUPPLIER_DISP_CHARS        = P_SUPPLIER_DISP_CHARS,
    ROLE_ENABLED_FLAG          = P_ROLE_ENABLED_FLAG,
    ROLE_DISP_CHARS            = P_ROLE_DISP_CHARS,
    RESOURCE_CLASS_FLAG        = P_RESOURCE_CLASS_FLAG,
    LAST_UPDATE_DATE           = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY            = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN          = P_LAST_UPDATE_LOGIN
  where res_format_id          = P_RES_FORMAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update pa_res_formats_tl set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RES_FORMAT_ID              = P_RES_FORMAT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_RES_FORMAT_ID in NUMBER
) is
begin
  delete from pa_res_formats_tl
  where RES_FORMAT_ID = P_RES_FORMAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from pa_res_formats_b
  where RES_FORMAT_ID = P_RES_FORMAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from pa_res_formats_tl T
  where not exists
    (select NULL
    from PA_RES_FORMATS_B B
    where B.RES_FORMAT_ID = T.res_format_id
    );

  update pa_res_formats_tl T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from pa_res_formats_tl B
    where B.RES_FORMAT_ID = T.RES_FORMAT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RES_FORMAT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RES_FORMAT_ID,
      SUBT.LANGUAGE
    from pa_res_formats_tl SUBB, pa_res_formats_tl SUBT
    where SUBB.RES_FORMAT_ID = SUBT.RES_FORMAT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into pa_res_formats_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    res_format_id,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.RES_FORMAT_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from pa_res_formats_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from pa_res_formats_tl T
    where T.RES_FORMAT_ID = B.RES_FORMAT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  P_RES_FORMAT_ID               in NUMBER   ,
  P_OWNER                       in VARCHAR2 ,
  P_NAME                        in VARCHAR2 ,
  P_DESCRIPTION                 in VARCHAR2
) is
begin

  update pa_res_formats_tl set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(P_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG') --For bug 4129599
  where res_format_id = P_RES_FORMAT_ID
  /*Bug4129599- Changes Start */
  and   userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--        (select LANGUAGE_CODE from FND_LANGUAGES where INSTALLED_FLAG = 'B');
  /*Bug4129599- Changes End */

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW(
  P_RES_FORMAT_ID             in NUMBER,
  P_RESOURCE_FORMAT_SEQ       in NUMBER,
  P_RESOURCE_CLASS_ID         in NUMBER,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_ENABLED_FLAG     in VARCHAR2,
  P_RESOURCE_TYPE_DISP_CHARS  in NUMBER,
  P_ORGN_ENABLED_FLAG         in VARCHAR2,
  P_ORGN_DISP_CHARS           in NUMBER,
  P_FIN_CAT_ENABLED_FLAG      in VARCHAR2,
  P_FIN_CAT_DISP_CHARS        in NUMBER,
  P_INCURRED_BY_ENABLED_FLAG  in VARCHAR2,
  P_INCURRED_BY_DISP_CHARS    in NUMBER,
  P_SUPPLIER_ENABLED_FLAG     in VARCHAR2,
  P_SUPPLIER_DISP_CHARS       in NUMBER,
  P_ROLE_ENABLED_FLAG         in VARCHAR2,
  P_ROLE_DISP_CHARS           in NUMBER,
  P_RESOURCE_CLASS_FLAG       in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_OWNER                     in VARCHAR2
) is

  user_id NUMBER;
  l_rowid VARCHAR2(64);

begin

  if (P_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id :=0;
  end if;

  pa_res_formats_pvt.UPDATE_ROW (
    P_RES_FORMAT_ID                => P_RES_FORMAT_ID   ,
    P_RESOURCE_FORMAT_SEQ          => P_RESOURCE_FORMAT_SEQ,
    P_RESOURCE_CLASS_ID            => P_RESOURCE_CLASS_ID,
    P_RES_TYPE_ID                  => P_RES_TYPE_ID,
    P_RES_TYPE_ENABLED_FLAG        => P_RES_TYPE_ENABLED_FLAG,
    P_RESOURCE_TYPE_DISP_CHARS     => P_RESOURCE_TYPE_DISP_CHARS,
    P_ORGN_ENABLED_FLAG            => P_ORGN_ENABLED_FLAG,
    P_ORGN_DISP_CHARS              => P_ORGN_DISP_CHARS,
    P_FIN_CAT_ENABLED_FLAG         => P_FIN_CAT_ENABLED_FLAG,
    P_FIN_CAT_DISP_CHARS           => P_FIN_CAT_DISP_CHARS,
    P_INCURRED_BY_ENABLED_FLAG     => P_INCURRED_BY_ENABLED_FLAG,
    P_INCURRED_BY_DISP_CHARS       => P_INCURRED_BY_DISP_CHARS,
    P_SUPPLIER_ENABLED_FLAG        => P_SUPPLIER_ENABLED_FLAG,
    P_SUPPLIER_DISP_CHARS          => P_SUPPLIER_DISP_CHARS,
    P_ROLE_ENABLED_FLAG            => P_ROLE_ENABLED_FLAG,
    P_ROLE_DISP_CHARS              => P_ROLE_DISP_CHARS,
    P_RESOURCE_CLASS_FLAG          => P_RESOURCE_CLASS_FLAG,
    P_NAME                         => P_NAME          ,
    P_DESCRIPTION                  => P_DESCRIPTION   ,
    P_LAST_UPDATE_DATE             => sysdate         ,
    P_LAST_UPDATED_BY              => user_id         ,
    P_LAST_UPDATE_LOGIN            => 0               );

  EXCEPTION
    WHEN no_data_found then
        pa_res_formats_pvt.INSERT_ROW (
    X_ROWID                     => l_rowid         ,
    P_RES_FORMAT_ID             => P_RES_FORMAT_ID   ,
    P_RESOURCE_FORMAT_SEQ       => P_RESOURCE_FORMAT_SEQ,
    P_RESOURCE_CLASS_ID         => P_RESOURCE_CLASS_ID,
    P_RES_TYPE_ID               => P_RES_TYPE_ID,
    P_RES_TYPE_ENABLED_FLAG     => P_RES_TYPE_ENABLED_FLAG,
    P_RESOURCE_TYPE_DISP_CHARS  => P_RESOURCE_TYPE_DISP_CHARS,
    P_ORGN_ENABLED_FLAG         => P_ORGN_ENABLED_FLAG,
    P_ORGN_DISP_CHARS           => P_ORGN_DISP_CHARS,
    P_FIN_CAT_ENABLED_FLAG      => P_FIN_CAT_ENABLED_FLAG,
    P_FIN_CAT_DISP_CHARS        => P_FIN_CAT_DISP_CHARS,
    P_INCURRED_BY_ENABLED_FLAG  => P_INCURRED_BY_ENABLED_FLAG,
    P_INCURRED_BY_DISP_CHARS    => P_INCURRED_BY_DISP_CHARS,
    P_SUPPLIER_ENABLED_FLAG     => P_SUPPLIER_ENABLED_FLAG,
    P_SUPPLIER_DISP_CHARS       => P_SUPPLIER_DISP_CHARS,
    P_ROLE_ENABLED_FLAG         => P_ROLE_ENABLED_FLAG,
    P_ROLE_DISP_CHARS           => P_ROLE_DISP_CHARS,
    P_RESOURCE_CLASS_FLAG       => P_RESOURCE_CLASS_FLAG,
    P_NAME                      => P_NAME          ,
    P_DESCRIPTION               => P_DESCRIPTION   ,
    P_CREATION_DATE             => sysdate         ,
    P_CREATED_BY                => user_id         ,
    P_LAST_UPDATE_DATE          => sysdate         ,
    P_LAST_UPDATED_BY           => user_id         ,
    P_LAST_UPDATE_LOGIN         => 0               );
end LOAD_ROW;

end pa_res_formats_pvt;

/
