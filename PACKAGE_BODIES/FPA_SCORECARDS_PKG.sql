--------------------------------------------------------
--  DDL for Package Body FPA_SCORECARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_SCORECARDS_PKG" as
/* $Header: FPASSCRB.pls 120.3 2005/09/29 13:59:49 ashariff noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PROJECT_ID in NUMBER,
  X_STRATEGIC_OBJ_ID in NUMBER,
  X_SCENARIO_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FPA_SCORECARDS_TL
    where PROJECT_ID = X_PROJECT_ID
    and STRATEGIC_OBJ_ID = X_STRATEGIC_OBJ_ID
    and SCENARIO_ID = X_SCENARIO_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into FPA_SCORECARDS_TL (
    PROJECT_ID,
    STRATEGIC_OBJ_ID,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SCENARIO_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PROJECT_ID,
    X_STRATEGIC_OBJ_ID,
    X_COMMENTS,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_SCENARIO_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FPA_SCORECARDS_TL T
    where T.PROJECT_ID = X_PROJECT_ID
    and T.STRATEGIC_OBJ_ID = X_STRATEGIC_OBJ_ID
    and T.SCENARIO_ID = X_SCENARIO_ID
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
  X_PROJECT_ID in NUMBER,
  X_STRATEGIC_OBJ_ID in NUMBER,
  X_SCENARIO_ID in NUMBER,
  X_COMMENTS in VARCHAR2
) is
  cursor c1 is select
      COMMENTS,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FPA_SCORECARDS_TL
    where PROJECT_ID = X_PROJECT_ID
    and STRATEGIC_OBJ_ID = X_STRATEGIC_OBJ_ID
    and SCENARIO_ID = X_SCENARIO_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROJECT_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.COMMENTS = X_COMMENTS)
               OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null)))
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
  X_PROJECT_ID in NUMBER,
  X_STRATEGIC_OBJ_ID in NUMBER,
  X_SCENARIO_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FPA_SCORECARDS_TL set
    COMMENTS = X_COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROJECT_ID = X_PROJECT_ID
  and STRATEGIC_OBJ_ID = X_STRATEGIC_OBJ_ID
  and SCENARIO_ID = X_SCENARIO_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROJECT_ID in NUMBER,
  X_STRATEGIC_OBJ_ID in NUMBER,
  X_SCENARIO_ID in NUMBER
) is
begin
  delete from FPA_SCORECARDS_TL
  where PROJECT_ID = X_PROJECT_ID
  and STRATEGIC_OBJ_ID = X_STRATEGIC_OBJ_ID
  and SCENARIO_ID = X_SCENARIO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update FPA_SCORECARDS_TL T set (
      COMMENTS
    ) = (select
      B.COMMENTS
    from FPA_SCORECARDS_TL B
    where B.PROJECT_ID = T.PROJECT_ID
    and B.STRATEGIC_OBJ_ID = T.STRATEGIC_OBJ_ID
    and B.SCENARIO_ID = T.SCENARIO_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROJECT_ID,
      T.STRATEGIC_OBJ_ID,
      T.SCENARIO_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PROJECT_ID,
      SUBT.STRATEGIC_OBJ_ID,
      SUBT.SCENARIO_ID,
      SUBT.LANGUAGE
    from FPA_SCORECARDS_TL SUBB, FPA_SCORECARDS_TL SUBT
    where SUBB.PROJECT_ID = SUBT.PROJECT_ID
    and SUBB.STRATEGIC_OBJ_ID = SUBT.STRATEGIC_OBJ_ID
    and SUBB.SCENARIO_ID = SUBT.SCENARIO_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.COMMENTS <> SUBT.COMMENTS
      or (SUBB.COMMENTS is null and SUBT.COMMENTS is not null)
      or (SUBB.COMMENTS is not null and SUBT.COMMENTS is null)
  ));

  insert into FPA_SCORECARDS_TL (
    PROJECT_ID,
    STRATEGIC_OBJ_ID,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SCENARIO_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PROJECT_ID,
    B.STRATEGIC_OBJ_ID,
    B.COMMENTS,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SCENARIO_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FPA_SCORECARDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FPA_SCORECARDS_TL T
    where T.PROJECT_ID = B.PROJECT_ID
    and T.STRATEGIC_OBJ_ID = B.STRATEGIC_OBJ_ID
    and T.SCENARIO_ID = B.SCENARIO_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
  P_PROJECT_ID in NUMBER,
  P_STRATEGIC_OBJ_ID in NUMBER,
  P_SCENARIO_ID in NUMBER,
  P_COMMENTS in VARCHAR2,
  P_OWNER in VARCHAR2
) is
begin

  update fpa_scorecards_tl set
    COMMENTS = P_COMMENTS,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(P_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where PROJECT_ID = P_PROJECT_ID
  and STRATEGIC_OBJ_ID = P_STRATEGIC_OBJ_ID
  and SCENARIO_ID = P_SCENARIO_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW(
  P_PROJECT_ID in NUMBER,
  P_STRATEGIC_OBJ_ID in NUMBER,
  P_SCENARIO_ID in NUMBER,
  P_COMMENTS in VARCHAR2,
  P_OWNER in VARCHAR2
) is

  user_id NUMBER;
  l_rowid VARCHAR2(64);

begin

  if (P_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id :=0;
  end if;

  FPA_SCORECARDS_PKG.UPDATE_ROW (
    X_PROJECT_ID                 =>    P_PROJECT_ID,
    X_STRATEGIC_OBJ_ID           =>    P_STRATEGIC_OBJ_ID,
    X_SCENARIO_ID                =>    P_SCENARIO_ID,
    X_COMMENTS                   =>    P_COMMENTS,
    X_LAST_UPDATE_DATE           =>    sysdate,
    X_LAST_UPDATED_BY            =>    user_id,
    X_LAST_UPDATE_LOGIN          =>    0);

  EXCEPTION
    WHEN no_data_found then
        FPA_SCORECARDS_PKG.INSERT_ROW (
    X_ROWID                           =>  l_rowid,
    X_PROJECT_ID                      =>  P_PROJECT_ID,
    X_STRATEGIC_OBJ_ID                =>  P_STRATEGIC_OBJ_ID,
    X_SCENARIO_ID                     =>  P_SCENARIO_ID,
    X_COMMENTS                        =>  P_COMMENTS,
    X_CREATION_DATE                   =>  sysdate               ,
    X_CREATED_BY                      =>  user_id               ,
    X_LAST_UPDATE_DATE                =>  sysdate               ,
    X_LAST_UPDATED_BY                 =>  user_id               ,
    X_LAST_UPDATE_LOGIN               =>  0                     );
end LOAD_ROW;




end FPA_SCORECARDS_PKG;

/
