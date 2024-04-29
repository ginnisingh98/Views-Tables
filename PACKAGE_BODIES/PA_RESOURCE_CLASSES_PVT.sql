--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_CLASSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_CLASSES_PVT" as
/* $Header: PARRCLVB.pls 120.0 2005/05/30 16:37:31 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                           in out NOCOPY ROWID,
  P_RESOURCE_CLASS_ID               in NUMBER,
  P_RESOURCE_CLASS_CODE             in VARCHAR2,
  P_RESOURCE_CLASS_SEQ              in NUMBER,
  P_NAME                            in VARCHAR2,
  P_DESCRIPTION                     in VARCHAR2,
  P_CREATION_DATE                   in DATE     ,
  P_CREATED_BY                      in NUMBER   ,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER
) is

  l_resource_class_id pa_resource_classes_b.resource_class_id%type;


  cursor C is select ROWID from pa_resource_classes_b
    where resource_class_id = l_resource_class_id;
begin

  select nvl(P_RESOURCE_CLASS_ID,PA_RESOURCE_CLASSES_S.nextval)
  into   l_resource_class_id
  from   dual;

  insert into pa_resource_classes_b (
    RESOURCE_CLASS_ID             ,
    RESOURCE_CLASS_CODE           ,
    RESOURCE_CLASS_SEQ            ,
    CREATION_DATE                 ,
    CREATED_BY                    ,
    LAST_UPDATE_DATE              ,
    LAST_UPDATED_BY               ,
    LAST_UPDATE_LOGIN
  ) values (
    L_RESOURCE_CLASS_ID                  ,
    P_RESOURCE_CLASS_CODE                ,
    P_RESOURCE_CLASS_SEQ                 ,
    P_CREATION_DATE                      ,
    P_CREATED_BY                         ,
    P_LAST_UPDATE_DATE                   ,
    P_LAST_UPDATED_BY                    ,
    P_LAST_UPDATE_LOGIN
  );

  insert into pa_resource_classes_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RESOURCE_CLASS_ID,
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
    L_RESOURCE_CLASS_ID,
    P_NAME,
    P_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PA_RESOURCE_CLASSES_TL T
    where T.RESOURCE_CLASS_ID = L_RESOURCE_CLASS_ID
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
  P_RESOURCE_CLASS_ID                  in NUMBER
 ) is
  cursor c is select
      RESOURCE_CLASS_CODE
    from pa_resource_classes_b
    where RESOURCE_CLASS_ID = P_RESOURCE_CLASS_ID
    for update of RESOURCE_CLASS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from pa_resource_classes_tl
    where RESOURCE_CLASS_ID = P_RESOURCE_CLASS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RESOURCE_CLASS_ID nowait;
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
  P_RESOURCE_CLASS_ID               in NUMBER,
  P_RESOURCE_CLASS_CODE             in VARCHAR2,
  P_RESOURCE_CLASS_SEQ              in NUMBER,
  P_NAME                            in VARCHAR2,
  P_DESCRIPTION                     in VARCHAR2,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER
) is
begin
  update pa_resource_classes_b set
    RESOURCE_CLASS_CODE    = P_RESOURCE_CLASS_CODE,
    RESOURCE_CLASS_SEQ     = P_RESOURCE_CLASS_SEQ,
    LAST_UPDATE_DATE       = P_LAST_UPDATE_DATE               ,
    LAST_UPDATED_BY        = P_LAST_UPDATED_BY                ,
    LAST_UPDATE_LOGIN      = P_LAST_UPDATE_LOGIN
  where RESOURCE_CLASS_ID              = P_RESOURCE_CLASS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update pa_resource_classes_tl set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RESOURCE_CLASS_ID              = P_RESOURCE_CLASS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_RESOURCE_CLASS_ID in NUMBER
) is
begin
  delete from pa_resource_classes_tl
  where RESOURCE_CLASS_ID = P_RESOURCE_CLASS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from pa_resource_classes_b
  where RESOURCE_CLASS_ID = P_RESOURCE_CLASS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from pa_resource_classes_tl T
  where not exists
    (select NULL
    from pa_resource_classes_b B
    where B.RESOURCE_CLASS_ID = T.RESOURCE_CLASS_ID
    );

  update pa_resource_classes_tl T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from pa_resource_classes_tl B
    where B.RESOURCE_CLASS_ID = T.RESOURCE_CLASS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RESOURCE_CLASS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RESOURCE_CLASS_ID,
      SUBT.LANGUAGE
    from pa_resource_classes_tl SUBB, pa_resource_classes_tl SUBT
    where SUBB.RESOURCE_CLASS_ID = SUBT.RESOURCE_CLASS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into pa_resource_classes_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RESOURCE_CLASS_ID,
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
    B.RESOURCE_CLASS_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from pa_resource_classes_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from pa_resource_classes_tl T
    where T.RESOURCE_CLASS_ID = B.RESOURCE_CLASS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  P_RESOURCE_CLASS_ID                 in NUMBER   ,
  P_OWNER                             in VARCHAR2 ,
  P_NAME                              in VARCHAR2 ,
  P_DESCRIPTION                       in VARCHAR2
) is
begin

  update pa_resource_classes_tl set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(P_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG') --For bug 4129599
  where RESOURCE_CLASS_ID = P_RESOURCE_CLASS_ID
  /*Bug4129599- Changes Start */
  and   userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--          (select LANGUAGE_CODE from FND_LANGUAGES where INSTALLED_FLAG = 'B');
  /*Bug4129599- Changes End */

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW(
  P_RESOURCE_CLASS_ID               in NUMBER,
  P_RESOURCE_CLASS_CODE             in VARCHAR2,
  P_RESOURCE_CLASS_SEQ              in NUMBER,
  P_NAME                            in VARCHAR2,
  P_DESCRIPTION                     in VARCHAR2,
  P_OWNER                           in VARCHAR2
) is

  user_id NUMBER;
  l_rowid VARCHAR2(64);

begin

  if (P_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id :=0;
  end if;

  PA_RESOURCE_CLASSES_PVT.UPDATE_ROW (
    P_RESOURCE_CLASS_ID                 =>    P_RESOURCE_CLASS_ID   ,
    P_RESOURCE_CLASS_CODE               =>    P_RESOURCE_CLASS_CODE ,
    P_RESOURCE_CLASS_SEQ                =>    P_RESOURCE_CLASS_SEQ  ,
    P_NAME                              =>    P_NAME                ,
    P_DESCRIPTION                       =>    P_DESCRIPTION         ,
    P_LAST_UPDATE_DATE                  =>    sysdate               ,
    P_LAST_UPDATED_BY                   =>    user_id               ,
    P_LAST_UPDATE_LOGIN                 =>    0                     );

  EXCEPTION
    WHEN no_data_found then
        PA_RESOURCE_CLASSES_PVT.INSERT_ROW (
    X_ROWID                           =>  l_rowid               ,
    P_RESOURCE_CLASS_ID               =>  P_RESOURCE_CLASS_ID   ,
    P_RESOURCE_CLASS_CODE             =>  P_RESOURCE_CLASS_CODE ,
    P_RESOURCE_CLASS_SEQ              =>  P_RESOURCE_CLASS_SEQ  ,
    P_NAME                            =>  P_NAME                ,
    P_DESCRIPTION                     =>  P_DESCRIPTION         ,
    P_CREATION_DATE                   =>  sysdate               ,
    P_CREATED_BY                      =>  user_id               ,
    P_LAST_UPDATE_DATE                =>  sysdate               ,
    P_LAST_UPDATED_BY                 =>  user_id               ,
    P_LAST_UPDATE_LOGIN               =>  0                     );
end LOAD_ROW;

end PA_RESOURCE_CLASSES_PVT;

/
