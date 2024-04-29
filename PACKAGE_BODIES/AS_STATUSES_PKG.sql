--------------------------------------------------------
--  DDL for Package Body AS_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_STATUSES_PKG" as
/* #$Header: asxtstab.pls 120.4 2007/03/16 08:13:57 snsarava ship $ */

    G_SCHEMA_NAME   VARCHAR2(32) := null;

    G_INDEX_SUFFIX1       CONSTANT    VARCHAR2(4) :=  '_MT1';
    G_INDEX_SUFFIX2       CONSTANT    VARCHAR2(4) :=  '_MT2';

--*****************************************************************************
-- Declarations
--
PROCEDURE Create_Temp_Index(p_table   IN VARCHAR2,
                      p_index_columns IN VARCHAR2,
                      p_index_suffix  IN VARCHAR2);
PROCEDURE Drop_Temp_Index(p_table IN VARCHAR2,
                          p_index_suffix IN VARCHAR2);
PROCEDURE Load_Schema_Name;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_OPP_FLAG in VARCHAR2,
  X_OPP_OPEN_STATUS_FLAG in VARCHAR2,
  X_OPP_DECISION_DATE_FLAG in VARCHAR2,
  X_STATUS_RANK in NUMBER,
  X_FORECAST_ROLLUP_FLAG in VARCHAR2,
  X_WIN_LOSS_INDICATOR in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AS_STATUSES_B
    where STATUS_CODE = X_STATUS_CODE
    ;
begin
  insert into AS_STATUSES_B (
    STATUS_CODE,
    ENABLED_FLAG,
    LEAD_FLAG,
    OPP_FLAG,
    OPP_OPEN_STATUS_FLAG,
    OPP_DECISION_DATE_FLAG,
    STATUS_RANK,
    FORECAST_ROLLUP_FLAG,
    WIN_LOSS_INDICATOR,
    USAGE_INDICATOR,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_STATUS_CODE,
    X_ENABLED_FLAG,
    X_LEAD_FLAG,
    X_OPP_FLAG,
    X_OPP_OPEN_STATUS_FLAG,
    X_OPP_DECISION_DATE_FLAG,
    X_STATUS_RANK,
    X_FORECAST_ROLLUP_FLAG,
    X_WIN_LOSS_INDICATOR,
    X_USAGE_INDICATOR,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AS_STATUSES_TL (
    STATUS_CODE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MEANING,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_STATUS_CODE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_MEANING,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AS_STATUSES_TL T
    where T.STATUS_CODE = X_STATUS_CODE
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
  X_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_OPP_FLAG in VARCHAR2,
  X_OPP_OPEN_STATUS_FLAG in VARCHAR2,
  X_OPP_DECISION_DATE_FLAG in VARCHAR2,
  X_STATUS_RANK in NUMBER,
  X_FORECAST_ROLLUP_FLAG in VARCHAR2,
  X_WIN_LOSS_INDICATOR in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      LEAD_FLAG,
      OPP_FLAG,
      OPP_OPEN_STATUS_FLAG,
      OPP_DECISION_DATE_FLAG,
      STATUS_RANK,
      FORECAST_ROLLUP_FLAG,
      WIN_LOSS_INDICATOR,
      USAGE_INDICATOR,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from AS_STATUSES_B
    where STATUS_CODE = X_STATUS_CODE
    for update of STATUS_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AS_STATUSES_TL
    where STATUS_CODE = X_STATUS_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STATUS_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.LEAD_FLAG = X_LEAD_FLAG)
           OR ((recinfo.LEAD_FLAG is null) AND (X_LEAD_FLAG is null)))
      AND ((recinfo.OPP_FLAG = X_OPP_FLAG)
           OR ((recinfo.OPP_FLAG is null) AND (X_OPP_FLAG is null)))
      AND ((recinfo.OPP_OPEN_STATUS_FLAG = X_OPP_OPEN_STATUS_FLAG)
           OR ((recinfo.OPP_OPEN_STATUS_FLAG is null) AND (X_OPP_OPEN_STATUS_FLAG is null)))
      AND ((recinfo.OPP_DECISION_DATE_FLAG = X_OPP_DECISION_DATE_FLAG)
           OR ((recinfo.OPP_DECISION_DATE_FLAG is null) AND (X_OPP_DECISION_DATE_FLAG is null)))
      AND ((recinfo.STATUS_RANK = X_STATUS_RANK)
           OR ((recinfo.STATUS_RANK is null) AND (X_STATUS_RANK is null)))
      AND ((recinfo.FORECAST_ROLLUP_FLAG = X_FORECAST_ROLLUP_FLAG)
           OR ((recinfo.FORECAST_ROLLUP_FLAG is null) AND (X_FORECAST_ROLLUP_FLAG is null)))
      AND ((recinfo.WIN_LOSS_INDICATOR = X_WIN_LOSS_INDICATOR)
           OR ((recinfo.WIN_LOSS_INDICATOR is null) AND (X_WIN_LOSS_INDICATOR is null)))
      AND ((recinfo.USAGE_INDICATOR = X_USAGE_INDICATOR)
           OR ((recinfo.USAGE_INDICATOR is null) AND (X_USAGE_INDICATOR is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.MEANING = X_MEANING)
               OR ((tlinfo.MEANING is null) AND (X_MEANING is null)))
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
  X_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_OPP_FLAG in VARCHAR2,
  X_OPP_OPEN_STATUS_FLAG in VARCHAR2,
  X_OPP_DECISION_DATE_FLAG in VARCHAR2,
  X_STATUS_RANK in NUMBER,
  X_FORECAST_ROLLUP_FLAG in VARCHAR2,
  X_WIN_LOSS_INDICATOR in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
 l_old_opp_open_status_flag VARCHAR2(1);
 l_request_id  NUMBER;
 l_module CONSTANT VARCHAR2(255) := 'as.plsql.stapk.UPDATE_ROW';
begin

  --Fetch the existing open_status_flag value from as_statuses_b.
   SELECT opp_open_status_flag INTO l_old_opp_open_status_flag
     FROM AS_STATUSES_B
    WHERE ltrim(nls_upper(STATUS_CODE)) = nls_upper(X_STATUS_CODE);

  update AS_STATUSES_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    LEAD_FLAG = X_LEAD_FLAG,
    OPP_FLAG = X_OPP_FLAG,
    OPP_OPEN_STATUS_FLAG = X_OPP_OPEN_STATUS_FLAG,
    OPP_DECISION_DATE_FLAG = X_OPP_DECISION_DATE_FLAG,
    STATUS_RANK = X_STATUS_RANK,
    FORECAST_ROLLUP_FLAG = X_FORECAST_ROLLUP_FLAG,
    WIN_LOSS_INDICATOR = X_WIN_LOSS_INDICATOR,
    USAGE_INDICATOR = X_USAGE_INDICATOR,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AS_STATUSES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_CODE = X_STATUS_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_CODE in VARCHAR2
) is
begin
  delete from AS_STATUSES_TL
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AS_STATUSES_B
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_OPP_FLAG in VARCHAR2,
  X_OPP_OPEN_STATUS_FLAG in VARCHAR2,
  X_OPP_DECISION_DATE_FLAG in VARCHAR2,
  X_STATUS_RANK in NUMBER,
  X_FORECAST_ROLLUP_FLAG in VARCHAR2,
  X_WIN_LOSS_INDICATOR in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CUSTOM in VARCHAR2,
  X_OWNER   in VARCHAR2
)
IS
begin
  declare
     user_id            number := 0;
     row_id             varchar2(64);

  cursor custom_exist(p_status_code VARCHAR2) is
    select 'Y'
    from AS_STATUSES_B
    where last_updated_by <> 1
    and status_code = p_STATUS_CODE;

  l_custom_exist varchar2(1) := 'N';


  begin
  If nvl(X_CUSTOM,'NONCUSTOM') = 'FORCE'
  then l_custom_exist := 'N';
  else
  OPEN custom_exist(X_STATUS_CODE);
  FETCH custom_exist into l_custom_exist;
  CLOSE custom_exist;
  end if;
  IF nvl(l_custom_exist, 'N') = 'N' THEN

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     begin
      AS_STATUSES_PKG.UPDATE_ROW(
          X_STATUS_CODE               => X_STATUS_CODE,
          X_ENABLED_FLAG              => X_ENABLED_FLAG,
          X_LEAD_FLAG                 => X_LEAD_FLAG,
          X_OPP_FLAG                  => X_OPP_FLAG,
          X_OPP_OPEN_STATUS_FLAG      => X_OPP_OPEN_STATUS_FLAG,
          X_OPP_DECISION_DATE_FLAG    => X_OPP_DECISION_DATE_FLAG,
          X_STATUS_RANK               => X_STATUS_RANK,
          X_FORECAST_ROLLUP_FLAG      => X_FORECAST_ROLLUP_FLAG,
          X_WIN_LOSS_INDICATOR       => X_WIN_LOSS_INDICATOR,
          X_USAGE_INDICATOR          => X_USAGE_INDICATOR,
          X_ATTRIBUTE_CATEGORY        => X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1           => X_ATTRIBUTE1,
          X_ATTRIBUTE2           => X_ATTRIBUTE2,
          X_ATTRIBUTE3           => X_ATTRIBUTE3,
          X_ATTRIBUTE4           => X_ATTRIBUTE4,
          X_ATTRIBUTE5           => X_ATTRIBUTE5,
          X_ATTRIBUTE6           => X_ATTRIBUTE6,
          X_ATTRIBUTE7           => X_ATTRIBUTE7,
          X_ATTRIBUTE8           => X_ATTRIBUTE8,
          X_ATTRIBUTE9           => X_ATTRIBUTE9,
          X_ATTRIBUTE10               => X_ATTRIBUTE10,
          X_ATTRIBUTE11               => X_ATTRIBUTE11,
          X_ATTRIBUTE12               => X_ATTRIBUTE12,
          X_ATTRIBUTE13               => X_ATTRIBUTE13,
          X_ATTRIBUTE14               => X_ATTRIBUTE14,
          X_ATTRIBUTE15               => X_ATTRIBUTE15,
          X_MEANING                   => X_MEANING,
          X_DESCRIPTION               => X_DESCRIPTION,
          X_LAST_UPDATE_DATE         => sysdate,
          X_LAST_UPDATED_BY          => user_id,
          X_LAST_UPDATE_LOGIN        => 0
          );

     exception
       when NO_DATA_FOUND then
      AS_STATUSES_PKG.INSERT_ROW(
       X_ROWID                       => row_id,
          X_STATUS_CODE                 => X_STATUS_CODE,
          X_ENABLED_FLAG                => X_ENABLED_FLAG,
          X_LEAD_FLAG                   => X_LEAD_FLAG,
          X_OPP_FLAG                    => X_OPP_FLAG,
          X_OPP_OPEN_STATUS_FLAG        => X_OPP_OPEN_STATUS_FLAG,
          X_OPP_DECISION_DATE_FLAG      => X_OPP_DECISION_DATE_FLAG,
          X_STATUS_RANK                 => X_STATUS_RANK,
          X_FORECAST_ROLLUP_FLAG        => X_FORECAST_ROLLUP_FLAG,
          X_WIN_LOSS_INDICATOR          => X_WIN_LOSS_INDICATOR,
          X_USAGE_INDICATOR             => X_USAGE_INDICATOR,
          X_ATTRIBUTE_CATEGORY          => X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1             => X_ATTRIBUTE1,
          X_ATTRIBUTE2             => X_ATTRIBUTE2,
          X_ATTRIBUTE3             => X_ATTRIBUTE3,
          X_ATTRIBUTE4             => X_ATTRIBUTE4,
          X_ATTRIBUTE5             => X_ATTRIBUTE5,
          X_ATTRIBUTE6             => X_ATTRIBUTE6,
          X_ATTRIBUTE7             => X_ATTRIBUTE7,
          X_ATTRIBUTE8             => X_ATTRIBUTE8,
          X_ATTRIBUTE9             => X_ATTRIBUTE9,
          X_ATTRIBUTE10                 => X_ATTRIBUTE10,
          X_ATTRIBUTE11                 => X_ATTRIBUTE11,
          X_ATTRIBUTE12                 => X_ATTRIBUTE12,
          X_ATTRIBUTE13                 => X_ATTRIBUTE13,
          X_ATTRIBUTE14                 => X_ATTRIBUTE14,
          X_ATTRIBUTE15                 => X_ATTRIBUTE15,
          X_MEANING                     => X_MEANING,
          X_DESCRIPTION                 => X_DESCRIPTION,
       X_CREATION_DATE               => sysdate,
       X_CREATED_BY                  => 0,
          X_LAST_UPDATE_DATE           => sysdate,
          X_LAST_UPDATED_BY            => user_id,
          X_LAST_UPDATE_LOGIN          => 0
      );

     end;

  END IF;

  end;
end LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AS_STATUSES_TL T
  where not exists
    (select NULL
    from AS_STATUSES_B B
    where B.STATUS_CODE = T.STATUS_CODE
    );

  update AS_STATUSES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from AS_STATUSES_TL B
    where B.STATUS_CODE = T.STATUS_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STATUS_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STATUS_CODE,
      SUBT.LANGUAGE
    from AS_STATUSES_TL SUBB, AS_STATUSES_TL SUBT
    where SUBB.STATUS_CODE = SUBT.STATUS_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or (SUBB.MEANING is null and SUBT.MEANING is not null)
      or (SUBB.MEANING is not null and SUBT.MEANING is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AS_STATUSES_TL (
    STATUS_CODE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MEANING,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STATUS_CODE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.MEANING,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AS_STATUSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_STATUSES_TL T
    where T.STATUS_CODE = B.STATUS_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_STATUS_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
begin
  -- only update rows that have not been altered by user
    update AS_STATUSES_TL
      set description = X_DESCRIPTION,
         meaning = X_MEANING,
         source_lang = userenv('LANG'),
         last_update_date = sysdate,
         last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
         last_update_login = 0
         where status_code = X_STATUS_CODE
        and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;




PROCEDURE PRE_UPDATE(
  ERRBUF   OUT  NOCOPY  VARCHAR2,
  RETCODE  OUT  NOCOPY  VARCHAR2) IS
  l_status BOOLEAN;
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.stapk.PRE_UPDATE';
BEGIN
    -- Load the schema name first
    Load_Schema_Name;

    --Create temporary indexes for leads
    Create_Temp_Index('AS_SALES_LEADS','SALES_LEAD_ID,STATUS_CODE,CLOSE_REASON',G_INDEX_SUFFIX1);
    Create_Temp_Index('AS_ACCESSES_ALL_ALL','ACCESS_ID,DELETE_FLAG,SALES_LEAD_ID',G_INDEX_SUFFIX1);

    --Create temporary indexes for opportunities
    Create_Temp_Index('AS_LEADS_ALL','LEAD_ID,STATUS,CLOSE_REASON',G_INDEX_SUFFIX2);
    Create_Temp_Index('AS_ACCESSES_ALL_ALL','ACCESS_ID,DELETE_FLAG,LEAD_ID',G_INDEX_SUFFIX2);
EXCEPTION
    WHEN others THEN
        ERRBUF := SQLERRM;
        RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK;
        Write_Log(l_module, 1, 'Exception: Problem in index creation.');
        Write_Log(l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
END PRE_UPDATE;

PROCEDURE POST_UPDATE(
  ERRBUF   OUT  NOCOPY  VARCHAR2,
  RETCODE  OUT  NOCOPY  VARCHAR2) IS
BEGIN
 -- Drop temporary index for Leads
 Drop_Temp_Index('AS_SALES_LEADS',G_INDEX_SUFFIX1);
 Drop_Temp_Index('AS_ACCESSES_ALL_ALL',G_INDEX_SUFFIX1);

 -- Drop temporary index for Opportunities
 Drop_Temp_Index('AS_LEADS_ALL',G_INDEX_SUFFIX2);
 Drop_Temp_Index('AS_ACCESSES_ALL_ALL',G_INDEX_SUFFIX2);
EXCEPTION when others then
  null;
END POST_UPDATE;

PROCEDURE Write_Log(p_module varchar2, p_which number, p_mssg  varchar2) IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
BEGIN
 IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(p_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, p_mssg);
 ELSE
    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);
  END IF;
END Write_Log;


PROCEDURE Load_Schema_Name IS
    l_status            VARCHAR2(2);
    l_industry          VARCHAR2(2);
    l_oracle_schema     VARCHAR2(32) := 'OSM';
    l_schema_return     BOOLEAN;
BEGIN
  if (G_SCHEMA_NAME is null) then
      l_schema_return := FND_INSTALLATION.get_app_info('AS', l_status, l_industry, l_oracle_schema);
      G_SCHEMA_NAME := l_oracle_schema;
  end if;
END;

PROCEDURE Create_Temp_Index(p_table   IN VARCHAR2,
                      p_index_columns IN VARCHAR2,
                      p_index_suffix  IN VARCHAR2) IS
       l_check_tspace_exist varchar2(100);
       l_index_tablespace varchar2(100);
       l_sql_stmt         varchar2(2000);
       l_user             varchar2(2000);
       l_index_name       varchar2(100);
        l_dop             NUMBER;



begin

       SELECT MIN(TO_NUMBER(v.value))
       INTO l_dop
       FROM v$parameter v
       WHERE v.name = 'parallel_max_servers'
       OR v.name = 'cpu_count';




       --execute immediate 'alter session set events ''10046 trace name context forever, level 12''';

       -----------------
       -- Create index--
       -----------------

       l_user := USER;

       -- Name for temporary index created for migration
       l_index_name := p_table || p_index_suffix;

       AD_TSPACE_UTIL.get_tablespace_name('AS', 'TRANSACTION_INDEXES','N',l_check_tspace_exist,l_index_tablespace);

       l_sql_stmt :=    'create index ' || l_index_name || ' on '
                     || G_SCHEMA_NAME||'.'
                     || p_table || '(' || p_index_columns || ') '
                     ||' tablespace ' || l_index_tablespace || '  nologging '
                     ||'parallel '||l_dop;
       execute immediate l_sql_stmt;

       --------------------
       -- convert to no||--
       --------------------
       l_sql_stmt := 'alter index '|| l_user ||'.' || l_index_name || ' noparallel ';
       execute immediate l_sql_stmt;


       -----------------
       -- Gather Stats--
       -----------------
       --Code commented for performance bug#5802537-- by lester
       --dbms_stats.gather_index_stats(l_user,l_index_name,estimate_percent => 10);
END Create_Temp_Index;

PROCEDURE Drop_Temp_Index(p_table  IN VARCHAR2,
                          p_index_suffix IN VARCHAR2) IS
       l_sql_stmt         varchar2(2000);
       l_index_name       varchar2(100);
       l_user             varchar2(2000);
begin
       -----------------
       -- Drop index  --
       -----------------
       l_user := USER;

       -- Name for temporary index created for migration
       l_index_name := p_table || p_index_suffix;

       l_sql_stmt := 'drop index ' || l_user||'.' || l_index_name || ' ';

       execute immediate l_sql_stmt;
END Drop_Temp_Index;

PROCEDURE update_accesses_Main
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           x_open_flag   IN VARCHAR2,
           x_status_code IN VARCHAR2,
           p_num_workers IN NUMBER,
           p_batch_size  IN NUMBER,
           p_debug_flag  IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'update_accesses_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'as.plsql.as_statuses_pkg.update_accesses_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;
  l_batch_size                   CONSTANT NUMBER := 10000;

  CURSOR c1 IS
  select AS_ACCESSES_S.nextval
  from dual;

  CURSOR Get_AC_Min_Id IS
  select  min(access_id)
  from    as_accesses_all_all;

BEGIN

  --
  -- If this is first time parent is called, then split the rows
  -- among workers and put the parent in paused state
  --
  IF (fnd_conc_global.request_data IS NULL) THEN

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;


    --
    -- Get maximum number of possible rows in as_leads_all
    --

    -- Initialize start ID value
    l_start_id := 0;

    open Get_AC_Min_Id;
    fetch Get_AC_Min_Id into l_start_id;
    close Get_AC_Min_Id;

    OPEN c1;
    FETCH c1 INTO l_max_num_rows;
    CLOSE c1;

    --
    -- Compute row range to be assigned to each worker
    --
    l_rows_per_worker := ROUND((l_max_num_rows -l_start_id) /p_num_workers) + 1;

    --
    -- Assign rows to each worker
    --




    FOR i IN 1..p_num_workers LOOP

      -- Initialize end ID value
      l_end_id := l_start_id + l_rows_per_worker;

      IF (p_debug_flag = 'Y' AND
         FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                           'Submitting child:' || 'Worker ID=' || i ||
                           ' ,Start ID =' || l_start_id ||
                           ',End ID =' || l_end_id);
      END IF;



      -- Submit the request
      l_req_id :=
        fnd_request.submit_request
        (
         application => 'AS',
         program     => 'ASXADFLOS',
         description => null,
         start_time  => sysdate,
         sub_request => true,
         argument1   => x_open_flag,
         argument2   => x_status_code,
         argument3   => l_start_id,
         argument4   => l_end_id,
         argument5   => NVL(p_batch_size,10000),
         argument6   => p_debug_flag,
         argument7   => CHR(0),
         argument8   => CHR(0),
         argument9   => CHR(0),
         argument10  => CHR(0),
         argument11  => CHR(0),
         argument12  => CHR(0),
         argument13  => CHR(0),
         argument14  => CHR(0),
         argument15  => CHR(0),
         argument16  => CHR(0),
         argument17  => CHR(0),
         argument18  => CHR(0),
         argument19  => CHR(0),
         argument20  => CHR(0),
         argument21  => CHR(0),
         argument22  => CHR(0),
         argument23  => CHR(0),
         argument24  => CHR(0),
         argument25  => CHR(0),
         argument26  => CHR(0),
         argument27  => CHR(0),
         argument28  => CHR(0),
         argument29  => CHR(0),
         argument30  => CHR(0),
         argument31  => CHR(0),
         argument32  => CHR(0),
         argument33  => CHR(0),
         argument34  => CHR(0),
         argument35  => CHR(0),
         argument36  => CHR(0),
         argument37  => CHR(0),
         argument38  => CHR(0),
         argument39  => CHR(0),
         argument40  => CHR(0),
         argument41  => CHR(0),
         argument42  => CHR(0),
         argument43  => CHR(0),
         argument44  => CHR(0),
         argument45  => CHR(0),
         argument46  => CHR(0),
         argument47  => CHR(0),
         argument48  => CHR(0),
         argument49  => CHR(0),
         argument50  => CHR(0),
         argument51  => CHR(0),
         argument52  => CHR(0),
         argument53  => CHR(0),
         argument54  => CHR(0),
         argument55  => CHR(0),
         argument56  => CHR(0),
         argument57  => CHR(0),
         argument58  => CHR(0),
         argument59  => CHR(0),
         argument60  => CHR(0),
         argument61  => CHR(0),
         argument62  => CHR(0),
         argument63  => CHR(0),
         argument64  => CHR(0),
         argument65  => CHR(0),
         argument66  => CHR(0),
         argument67  => CHR(0),
         argument68  => CHR(0),
         argument69  => CHR(0),
         argument70  => CHR(0),
         argument71  => CHR(0),
         argument72  => CHR(0),
         argument73  => CHR(0),
         argument74  => CHR(0),
         argument75  => CHR(0),
         argument76  => CHR(0),
         argument77  => CHR(0),
         argument78  => CHR(0),
         argument79  => CHR(0),
         argument80  => CHR(0),
         argument81  => CHR(0),
         argument82  => CHR(0),
         argument83  => CHR(0),
         argument84  => CHR(0),
         argument85  => CHR(0),
         argument86  => CHR(0),
         argument87  => CHR(0),
         argument88  => CHR(0),
         argument89  => CHR(0),
         argument90  => CHR(0),
         argument91  => CHR(0),
         argument92  => CHR(0),
         argument93  => CHR(0),
         argument94  => CHR(0),
         argument95  => CHR(0),
         argument96  => CHR(0),
         argument97  => CHR(0),
         argument98  => CHR(0),
         argument99  => CHR(0),
         argument100  => CHR(0)
        );

      --
      -- If request submission failed, exit with error.
      --
      IF (l_req_id = 0) THEN

        errbuf := fnd_message.get;
        retcode := 2;
        RETURN;

      END IF;

      -- Set start ID value
      l_start_id := l_end_id ;

    END LOOP; -- end i

    --
    -- After submitting request for all workers, put the parent
    -- in paused state. When all children are done, the parent
    -- would be called again, and then it will terminate
    --
    fnd_conc_global.set_req_globals
    (
     conc_status         => 'PAUSED',
     request_data        => to_char(l_req_id)
    -- conc_restart_time   => to_char(sysdate)
    -- release_sub_request => 'N'
    );

  ELSE

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;


    errbuf := 'Migration completed';
    retcode := 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Done:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

  END IF;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK;

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name, true);
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                      l_api_name||':'||sqlcode||':'||sqlerrm);
    END IF;

END update_accesses_Main;



procedure UPDATE_ACCESSES_SUB(
   ERRBUF   	OUT NOCOPY   VARCHAR2,
   RETCODE  	OUT NOCOPY   VARCHAR2,
   x_open_flag   IN VARCHAR2,
   x_status_code IN VARCHAR2,
   p_start_id 	 IN VARCHAR2,
   p_end_id 	 IN VARCHAR2,
   p_batch_size  IN NUMBER,
   p_debug_flag  IN VARCHAR2
)
IS
    l_count             NUMBER    := 0;
    l_min_id            NUMBER    := 0;
    l_max_id            NUMBER    := 0;
    l_debug             BOOLEAN   := false;
    l_last_updated_by   NUMBER    := fnd_global.user_id;
    l_last_update_login NUMBER    := fnd_global.conc_login_id;
    G_BATCH_SIZE        NUMBER    ;
    l_lead_flag         VARCHAR2(1);
    l_opp_flag         VARCHAR2(1);
    l_status            BOOLEAN;


    CURSOR Get_flag_from_Input(c_in_param_1 VARCHAR2,c_in_param_2 VARCHAR2) IS
    select NVL(LEAD_FLAG,'N'),NVL(OPP_FLAG,'N')
      from AS_STATUSES_B
     where status_code = c_in_param_2
       and UPPER(opp_open_status_flag) = UPPER(c_in_param_1);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.stapk.UPDATE_ACCESSES_SUB';

BEGIN

    G_BATCH_SIZE := NVL(p_batch_size,10000);

    IF Upper(X_STATUS_CODE) <> 'ALL' AND UPPER(NVL(X_OPEN_FLAG,'X')) NOT IN ('Y','N') THEN
      Write_log (l_module, 1, 'Invalid input for Status Flag!');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF Upper(X_STATUS_CODE) <> 'ALL' THEN
      Open Get_flag_from_Input(X_OPEN_FLAG,X_STATUS_CODE);
      Fetch Get_flag_from_Input INTO l_lead_flag,l_opp_flag;
      IF (Get_flag_from_Input%NOTFOUND) THEN
          Write_log (l_module, 1, 'Combination of Status Code and Open Flag is not valid! Please note that the status code is case sensitive.');
          Close Get_flag_from_Input;
          RAISE FND_API.G_EXC_ERROR;
      ELSE
          Close Get_flag_from_Input;
      END IF;
    END IF;

    --Get Min,Max Ids

    l_min_id := p_start_id;
    l_max_id := p_end_id;

    IF (p_debug_flag = 'Y') THEN
    	l_debug := TRUE;
    ELSE
    	l_debug := FALSE;
    END IF;


    if (l_debug) Then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Minimum Id  - Max id for as_accesses_all_all for this worker :' || l_min_id ||'  to  '||l_max_id);
    end if;



    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        if (l_debug) Then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Current loop count:' || l_count);
        end if;
        -- update statements here
        IF Upper(X_STATUS_CODE) <> 'ALL' THEN
          UPDATE /*+ INDEX(acc AS_ACCESSES_ALL_ALL_MT1)*/ AS_ACCESSES_ALL acc
             SET object_version_number =  nvl(object_version_number,0) + 1,
                         acc.OPEN_FLAG = Upper(X_OPEN_FLAG),
                         acc.last_update_date = sysdate,
                         acc.last_updated_by = l_last_updated_by,
                         acc.last_update_login = l_last_update_login
           WHERE acc.ACCESS_ID >= l_count
             AND acc.ACCESS_ID < l_count+G_BATCH_SIZE
              AND acc.ACCESS_ID < l_max_id
             AND (l_lead_flag = 'Y' AND EXISTS
                                    ( SELECT /*+ INDEX(slds AS_SALES_LEADS_MT1)*/ 1
                                        FROM AS_SALES_LEADS slds
                                       WHERE slds.sales_lead_id = acc.sales_lead_id
                                         AND slds.status_code  = X_STATUS_CODE
                                         AND acc.sales_lead_id is not null )
                 )
             AND acc.sales_lead_id is not null;


          UPDATE /*+ INDEX(acc AS_ACCESSES_ALL_ALL_MT2)*/ AS_ACCESSES_ALL acc
             SET object_version_number =  nvl(object_version_number,0) + 1,
                         acc.OPEN_FLAG = Upper(X_OPEN_FLAG),
                         acc.last_update_date = sysdate,
                         acc.last_updated_by = l_last_updated_by,
                         acc.last_update_login = l_last_update_login
           WHERE acc.ACCESS_ID >= l_count
             AND acc.ACCESS_ID < l_count+G_BATCH_SIZE
             AND acc.ACCESS_ID < l_max_id
             AND (l_opp_flag = 'Y' AND EXISTS
                                    ( SELECT /*+ INDEX(lds AS_LEADS_ALL_MT2)*/ 1
                                        FROM AS_LEADS_ALL lds
                                       WHERE lds.lead_id = acc.lead_id
                                         AND lds.status  = X_STATUS_CODE
                                         AND acc.lead_id is not null ))
             AND acc.lead_id is not null;

        ELSE
          UPDATE /*+ INDEX(acc AS_ACCESSES_ALL_ALL_MT1)*/ AS_ACCESSES_ALL acc
             SET object_version_number =  nvl(object_version_number,0) + 1,
                         acc.OPEN_FLAG = (SELECT /*+ INDEX(slds AS_SALES_LEADS_MT1)*/ st.opp_open_status_flag
                                              FROM AS_STATUSES_B st,AS_SALES_LEADS slds
                                             WHERE st.status_code = slds.status_code
                                               AND slds.sales_lead_id = acc.sales_lead_id
                                               AND acc.sales_lead_id is not null
                                               AND st.lead_flag = 'Y'),
                         acc.last_update_date = sysdate,
                         acc.last_updated_by = l_last_updated_by,
                         acc.last_update_login = l_last_update_login
           WHERE acc.ACCESS_ID >= l_count
             AND acc.ACCESS_ID < l_count+G_BATCH_SIZE
             AND acc.ACCESS_ID < l_max_id
             AND acc.sales_lead_id is not null;



          UPDATE /*+ INDEX(acc AS_ACCESSES_ALL_ALL_MT2)*/ AS_ACCESSES_ALL acc
             SET object_version_number =  nvl(object_version_number,0) + 1,
                         acc.OPEN_FLAG = (SELECT /*+ INDEX(lds AS_LEADS_ALL_MT2)*/ st.opp_open_status_flag
                                              FROM AS_STATUSES_B st,AS_LEADS_ALL lds
                                             WHERE st.status_code = lds.status
                                               AND lds.lead_id = acc.lead_id
                                               AND acc.lead_id is not null
                                               AND st.opp_flag = 'Y'),
                         acc.last_update_date = sysdate,
                         acc.last_updated_by = l_last_updated_by,
                         acc.last_update_login = l_last_update_login
           WHERE acc.ACCESS_ID >= l_count
             AND acc.ACCESS_ID < l_count+G_BATCH_SIZE
             AND acc.ACCESS_ID < l_max_id
             AND acc.lead_id is not null;
        END IF;
        -- end update statements here
    commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;


    if l_debug then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Update of denormed open flag in as_accesses_all_all (for leads and opps) finished successfully');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'for range :'|| l_min_id ||'  to  '||l_max_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ERRBUF := ERRBUF || sqlerrm;
         RETCODE := FND_API.G_RET_STS_ERROR;
         ROLLBACK;
         Write_log (l_module, 1, 'Error in as_statuses_pkg.update_oppty_accesses');
         Write_log (l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                   ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ERRBUF := ERRBUF||sqlerrm;
         RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK;
         Write_Log(l_module, 1, 'Unexpected error in as_statuses_pkg.update_oppty_accesses');
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
    WHEN others THEN
        ERRBUF := SQLERRM;
        RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK;
        Write_Log(l_module, 1, 'Exception: others in as_statuses_pkg.update_oppty_accesses');
        Write_Log(l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
end UPDATE_ACCESSES_SUB;




PROCEDURE update_leads_Main
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           x_open_flag   IN VARCHAR2,
           x_status_code IN VARCHAR2,
           p_num_workers IN NUMBER,
           p_batch_size  IN NUMBER,
           p_debug_flag  IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'update_leads_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'as.plsql.as_statuses_pkg.update_leads_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;
  l_batch_size                   CONSTANT NUMBER := 10000;

  CURSOR Get_SL_Next_Val IS
  select AS_SALES_LEADS_S.nextval
  from dual;

  CURSOR Get_SL_Min_Id IS
  select  min(sales_lead_id)
  from    as_sales_leads;

BEGIN

  --
  -- If this is first time parent is called, then split the rows
  -- among workers and put the parent in paused state
  --
  IF (fnd_conc_global.request_data IS NULL) THEN

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;


    --
    -- Get maximum number of possible rows in as_leads_all
    --

    -- Initialize start ID value
    l_start_id := 0;

    open Get_SL_Min_Id;
    fetch Get_SL_Min_Id into l_start_id;
    close Get_SL_Min_Id;

    OPEN Get_SL_Next_Val;
    FETCH Get_SL_Next_Val INTO l_max_num_rows;
    CLOSE Get_SL_Next_Val;

    --
    -- Compute row range to be assigned to each worker
    --
    l_rows_per_worker := ROUND((l_max_num_rows -l_start_id) /p_num_workers) + 1;

    --
    -- Assign rows to each worker
    --




    FOR i IN 1..p_num_workers LOOP

      -- Initialize end ID value
      l_end_id := l_start_id + l_rows_per_worker;


      IF (p_debug_flag = 'Y' AND
               FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                                 'Submitting child:' || 'Worker ID=' || i ||
                                 ' ,Start ID =' || l_start_id ||
                                 ',End ID =' || l_end_id);
      END IF;

      -- Submit the request
      l_req_id :=
        fnd_request.submit_request
        (
         application => 'AS',
         program     => 'ASXADFL',
         description => null,
         start_time  => sysdate,
         sub_request => true,
         argument1   => x_open_flag,
         argument2   => x_status_code,
         argument3   => l_start_id,
         argument4   => l_end_id,
         argument5   => NVL(p_batch_size,10000),
         argument6   => p_debug_flag,
         argument7   => CHR(0),
         argument8   => CHR(0),
         argument9   => CHR(0),
         argument10  => CHR(0),
         argument11  => CHR(0),
         argument12  => CHR(0),
         argument13  => CHR(0),
         argument14  => CHR(0),
         argument15  => CHR(0),
         argument16  => CHR(0),
         argument17  => CHR(0),
         argument18  => CHR(0),
         argument19  => CHR(0),
         argument20  => CHR(0),
         argument21  => CHR(0),
         argument22  => CHR(0),
         argument23  => CHR(0),
         argument24  => CHR(0),
         argument25  => CHR(0),
         argument26  => CHR(0),
         argument27  => CHR(0),
         argument28  => CHR(0),
         argument29  => CHR(0),
         argument30  => CHR(0),
         argument31  => CHR(0),
         argument32  => CHR(0),
         argument33  => CHR(0),
         argument34  => CHR(0),
         argument35  => CHR(0),
         argument36  => CHR(0),
         argument37  => CHR(0),
         argument38  => CHR(0),
         argument39  => CHR(0),
         argument40  => CHR(0),
         argument41  => CHR(0),
         argument42  => CHR(0),
         argument43  => CHR(0),
         argument44  => CHR(0),
         argument45  => CHR(0),
         argument46  => CHR(0),
         argument47  => CHR(0),
         argument48  => CHR(0),
         argument49  => CHR(0),
         argument50  => CHR(0),
         argument51  => CHR(0),
         argument52  => CHR(0),
         argument53  => CHR(0),
         argument54  => CHR(0),
         argument55  => CHR(0),
         argument56  => CHR(0),
         argument57  => CHR(0),
         argument58  => CHR(0),
         argument59  => CHR(0),
         argument60  => CHR(0),
         argument61  => CHR(0),
         argument62  => CHR(0),
         argument63  => CHR(0),
         argument64  => CHR(0),
         argument65  => CHR(0),
         argument66  => CHR(0),
         argument67  => CHR(0),
         argument68  => CHR(0),
         argument69  => CHR(0),
         argument70  => CHR(0),
         argument71  => CHR(0),
         argument72  => CHR(0),
         argument73  => CHR(0),
         argument74  => CHR(0),
         argument75  => CHR(0),
         argument76  => CHR(0),
         argument77  => CHR(0),
         argument78  => CHR(0),
         argument79  => CHR(0),
         argument80  => CHR(0),
         argument81  => CHR(0),
         argument82  => CHR(0),
         argument83  => CHR(0),
         argument84  => CHR(0),
         argument85  => CHR(0),
         argument86  => CHR(0),
         argument87  => CHR(0),
         argument88  => CHR(0),
         argument89  => CHR(0),
         argument90  => CHR(0),
         argument91  => CHR(0),
         argument92  => CHR(0),
         argument93  => CHR(0),
         argument94  => CHR(0),
         argument95  => CHR(0),
         argument96  => CHR(0),
         argument97  => CHR(0),
         argument98  => CHR(0),
         argument99  => CHR(0),
         argument100  => CHR(0)
        );

      --
      -- If request submission failed, exit with error.
      --
      IF (l_req_id = 0) THEN

        errbuf := fnd_message.get;
        retcode := 2;
        RETURN;

      END IF;

      -- Set start ID value
      l_start_id := l_end_id ;

    END LOOP; -- end i

    --
    -- After submitting request for all workers, put the parent
    -- in paused state. When all children are done, the parent
    -- would be called again, and then it will terminate
    --
    fnd_conc_global.set_req_globals
    (
     conc_status         => 'PAUSED',
     request_data        => to_char(l_req_id)
    -- conc_restart_time   => to_char(sysdate)
    -- release_sub_request => 'N'
    );

  ELSE

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;


    errbuf := 'Migration completed';
    retcode := 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Done:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

  END IF;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK;

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name, true);
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                      l_api_name||':'||sqlcode||':'||sqlerrm);
    END IF;

END update_leads_Main;

procedure UPDATE_LEADS_ACCESSES(ERRBUF   OUT NOCOPY   VARCHAR2,
   RETCODE  OUT NOCOPY   VARCHAR2,
   x_open_flag   IN VARCHAR2,
   x_status_code IN VARCHAR2,
   p_start_id 	 IN VARCHAR2,
   p_end_id 	 IN VARCHAR2,
   p_batch_size  IN NUMBER,
   p_debug_flag  IN VARCHAR2)
IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_debug  BOOLEAN := false;
    l_last_updated_by NUMBER:= fnd_global.user_id;
    l_last_update_login NUMBER:= fnd_global.conc_login_id;
    G_BATCH_SIZE NUMBER := 10000;
    l_lead_flag VARCHAR2(1);
    l_status BOOLEAN;



    CURSOR Get_SL_Min_Id IS
    select  min(sales_lead_id)
    from  as_sales_leads;

    CURSOR Get_SL_Next_Val IS
    select AS_SALES_LEADS_S.nextval
    from dual;

    CURSOR Get_flag_from_Input(c_in_param_1 VARCHAR2,c_in_param_2 VARCHAR2) IS
    select NVL(LEAD_FLAG,'N')
      from AS_STATUSES_B
     where status_code = c_in_param_2
       and UPPER(opp_open_status_flag) = UPPER(c_in_param_1);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.stapk.UPDATE_LEADS_ACCESSES';

BEGIN

    IF Upper(X_STATUS_CODE) <> 'ALL' AND UPPER(NVL(X_OPEN_FLAG,'X')) NOT IN ('Y','N') THEN
      Write_log (l_module, 1, 'Invalid input for Status Flag!');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF Upper(X_STATUS_CODE) <> 'ALL' THEN
      Open Get_flag_from_Input(X_OPEN_FLAG,X_STATUS_CODE);
      Fetch Get_flag_from_Input INTO l_lead_flag;
      IF (Get_flag_from_Input%NOTFOUND) THEN
          Write_log (l_module, 1, 'Combination of Status Code and Open Flag is not valid! Please note that the status code is case sensitive.');
          Close Get_flag_from_Input;
          RAISE FND_API.G_EXC_ERROR;
      ELSE
          Close Get_flag_from_Input;
      END IF;
    END IF;



    IF (p_debug_flag = 'Y') THEN
    	l_debug := TRUE;
    ELSE
    	l_debug := FALSE;
    END IF;






    --Start updating sales leads table
     IF l_lead_flag = 'Y' OR Upper(X_STATUS_CODE) = 'ALL' THEN
         --Get Min,Max Ids
         l_min_id := p_start_id;
         l_max_id := p_end_id;
         G_BATCH_SIZE := NVL(p_batch_size,10000);



    if (l_debug) Then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Minimum Id  - Max id for leads for this worker :' || l_min_id ||'  to  '||l_max_id);
    end if;

         -- Initialize counter
         l_count := l_min_id;

         while (l_count <= l_max_id)
         loop
             if (l_debug) Then
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Current loop count:' || l_count);
             end if;
             -- update statements for sales leads here
             If Upper(X_STATUS_CODE) = 'ALL' THEN
              -- added decode for converted_to_opportunity fix for bug#3931530
              UPDATE /*+ INDEX(sld AS_SALES_LEADS_MT1)*/ AS_SALES_LEADS sld
                     SET (sld.STATUS_OPEN_FLAG , sld.CLOSE_REASON) =
                             (SELECT opp_open_status_flag,
                                 DECODE(opp_open_status_flag,'Y',NULL,'N',
                                        DECODE(st.status_code,'CONVERTED_TO_OPPORTUNITY','CONVERTED_TO_OPPORTUNITY',
                                                NVL(sld.close_reason,'NOT_SPECIFIED')
                                                )
                                        )
                            FROM AS_STATUSES_B st
                               WHERE st.status_code = sld.status_code
                                 AND st.lead_flag = 'Y')
                       , sld.last_update_date = sysdate
                       , sld.last_updated_by = l_last_updated_by
                       , sld.last_update_login = l_last_update_login
                   WHERE sld.sales_lead_id >= l_count
                     AND sld.sales_lead_id < l_count+G_BATCH_SIZE
                     AND sld.sales_lead_id < l_max_id
                     AND sld.status_code is not null;
             ELSE
             -- added decode for converted_to_opportunity fix for bug#3931530
                 UPDATE /*+ INDEX(sld AS_SALES_LEADS_MT1)*/ AS_SALES_LEADS sld
                    SET sld.STATUS_OPEN_FLAG = Upper(X_OPEN_FLAG)
                      , sld.CLOSE_REASON = DECODE(Upper(X_OPEN_FLAG),'Y',NULL,'N',
                                                 DECODE(X_STATUS_CODE,'CONVERTED_TO_OPPORTUNITY','CONVERTED_TO_OPPORTUNITY',
                                                        NVL(sld.close_reason,'NOT_SPECIFIED')
                                                       )
                                                  )
                      , sld.last_update_date = sysdate
                      , sld.last_updated_by = l_last_updated_by
                      , sld.last_update_login = l_last_update_login
                  WHERE sld.sales_lead_id >= l_count
                    AND sld.sales_lead_id < l_count+G_BATCH_SIZE
                    AND sld.sales_lead_id < l_max_id
                    AND sld.STATUS_CODE = X_STATUS_CODE
                    AND sld.status_code is not null;
             END IF;
             -- end update statements for sales leads here
         commit;

             l_count := l_count + G_BATCH_SIZE;
         end loop;
         commit;

         if l_debug then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Update of denormed open flag in sales leads finished successfully');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        end if;
    END IF; -- Only if l_lead_flag is Y



 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ERRBUF := ERRBUF || sqlerrm;
         RETCODE := FND_API.G_RET_STS_ERROR;
         ROLLBACK;
         Write_log (l_module, 1, 'Error in as_statuses_pkg.update_leads_accesses');
         Write_log (l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                   ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ERRBUF := ERRBUF||sqlerrm;
         RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK;
         Write_Log(l_module, 1, 'Unexpected error in as_statuses_pkg.update_leads_accesses');
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
    WHEN others THEN
        ERRBUF := SQLERRM;
        RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK;
        Write_Log(l_module, 1, 'Exception: others in as_statuses_pkg.update_leads_accesses');
        Write_Log(l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
end UPDATE_LEADS_ACCESSES;


PROCEDURE update_oppty_Main
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           x_open_flag   IN VARCHAR2,
           x_status_code IN VARCHAR2,
           p_num_workers IN NUMBER,
           p_batch_size  IN NUMBER,
           p_debug_flag  IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'update_oppty_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'as.plsql.as_statuses_pkg.update_oppty_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;
  l_batch_size                   CONSTANT NUMBER := 10000;

  CURSOR Get_SL_Next_Val IS
  select AS_LEADS_S.nextval
  from dual;

  CURSOR Get_SL_Min_Id IS
  select  min(lead_id)
  from    as_leads_all;

BEGIN

  --
  -- If this is first time parent is called, then split the rows
  -- among workers and put the parent in paused state
  --
  IF (fnd_conc_global.request_data IS NULL) THEN

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;


    --
    -- Get maximum number of possible rows in as_leads_all
    --

    -- Initialize start ID value
    l_start_id := 0;

    open Get_SL_Min_Id;
    fetch Get_SL_Min_Id into l_start_id;
    close Get_SL_Min_Id;

    OPEN Get_SL_Next_Val;
    FETCH Get_SL_Next_Val INTO l_max_num_rows;
    CLOSE Get_SL_Next_Val;

    --
    -- Compute row range to be assigned to each worker
    --
    l_rows_per_worker := ROUND((l_max_num_rows -l_start_id) /p_num_workers) + 1;

    --
    -- Assign rows to each worker
    --




    FOR i IN 1..p_num_workers LOOP

      -- Initialize end ID value
      l_end_id := l_start_id + l_rows_per_worker;

      IF (p_debug_flag = 'Y' AND
               FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                                 'Submitting child:' || 'Worker ID=' || i ||
                                 ' ,Start ID =' || l_start_id ||
                                 ',End ID =' || l_end_id);
      END IF;

      -- Submit the request
      l_req_id :=
        fnd_request.submit_request
        (
         application => 'AS',
         program     => 'ASXADFO',
         description => null,
         start_time  => sysdate,
         sub_request => true,
         argument1   => x_open_flag,
         argument2   => x_status_code,
         argument3   => l_start_id,
         argument4   => l_end_id,
         argument5   => NVL(p_batch_size,10000),
         argument6   => p_debug_flag,
         argument7   => CHR(0),
         argument8   => CHR(0),
         argument9   => CHR(0),
         argument10  => CHR(0),
         argument11  => CHR(0),
         argument12  => CHR(0),
         argument13  => CHR(0),
         argument14  => CHR(0),
         argument15  => CHR(0),
         argument16  => CHR(0),
         argument17  => CHR(0),
         argument18  => CHR(0),
         argument19  => CHR(0),
         argument20  => CHR(0),
         argument21  => CHR(0),
         argument22  => CHR(0),
         argument23  => CHR(0),
         argument24  => CHR(0),
         argument25  => CHR(0),
         argument26  => CHR(0),
         argument27  => CHR(0),
         argument28  => CHR(0),
         argument29  => CHR(0),
         argument30  => CHR(0),
         argument31  => CHR(0),
         argument32  => CHR(0),
         argument33  => CHR(0),
         argument34  => CHR(0),
         argument35  => CHR(0),
         argument36  => CHR(0),
         argument37  => CHR(0),
         argument38  => CHR(0),
         argument39  => CHR(0),
         argument40  => CHR(0),
         argument41  => CHR(0),
         argument42  => CHR(0),
         argument43  => CHR(0),
         argument44  => CHR(0),
         argument45  => CHR(0),
         argument46  => CHR(0),
         argument47  => CHR(0),
         argument48  => CHR(0),
         argument49  => CHR(0),
         argument50  => CHR(0),
         argument51  => CHR(0),
         argument52  => CHR(0),
         argument53  => CHR(0),
         argument54  => CHR(0),
         argument55  => CHR(0),
         argument56  => CHR(0),
         argument57  => CHR(0),
         argument58  => CHR(0),
         argument59  => CHR(0),
         argument60  => CHR(0),
         argument61  => CHR(0),
         argument62  => CHR(0),
         argument63  => CHR(0),
         argument64  => CHR(0),
         argument65  => CHR(0),
         argument66  => CHR(0),
         argument67  => CHR(0),
         argument68  => CHR(0),
         argument69  => CHR(0),
         argument70  => CHR(0),
         argument71  => CHR(0),
         argument72  => CHR(0),
         argument73  => CHR(0),
         argument74  => CHR(0),
         argument75  => CHR(0),
         argument76  => CHR(0),
         argument77  => CHR(0),
         argument78  => CHR(0),
         argument79  => CHR(0),
         argument80  => CHR(0),
         argument81  => CHR(0),
         argument82  => CHR(0),
         argument83  => CHR(0),
         argument84  => CHR(0),
         argument85  => CHR(0),
         argument86  => CHR(0),
         argument87  => CHR(0),
         argument88  => CHR(0),
         argument89  => CHR(0),
         argument90  => CHR(0),
         argument91  => CHR(0),
         argument92  => CHR(0),
         argument93  => CHR(0),
         argument94  => CHR(0),
         argument95  => CHR(0),
         argument96  => CHR(0),
         argument97  => CHR(0),
         argument98  => CHR(0),
         argument99  => CHR(0),
         argument100  => CHR(0)
        );

      --
      -- If request submission failed, exit with error.
      --
      IF (l_req_id = 0) THEN

        errbuf := fnd_message.get;
        retcode := 2;
        RETURN;

      END IF;

      -- Set start ID value
      l_start_id := l_end_id ;

    END LOOP; -- end i

    --
    -- After submitting request for all workers, put the parent
    -- in paused state. When all children are done, the parent
    -- would be called again, and then it will terminate
    --
    fnd_conc_global.set_req_globals
    (
     conc_status         => 'PAUSED',
     request_data        => to_char(l_req_id)
    -- conc_restart_time   => to_char(sysdate)
    -- release_sub_request => 'N'
    );

  ELSE

    -- Log
    IF (p_debug_flag = 'Y'  AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     ' Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag='||p_debug_flag);

    END IF;


    errbuf := 'Migration completed';
    retcode := 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Done:' || 'p_num_workers=' || p_num_workers ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

  END IF;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK;

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name, true);
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                      l_api_name||':'||sqlcode||':'||sqlerrm);
    END IF;

END update_oppty_Main;


procedure UPDATE_OPPTY_ACCESSES(ERRBUF   OUT NOCOPY   VARCHAR2,
   RETCODE  OUT NOCOPY   VARCHAR2,
   x_open_flag   IN VARCHAR2,
   x_status_code IN VARCHAR2,
   p_start_id 	 IN VARCHAR2,
   p_end_id 	 IN VARCHAR2,
   p_batch_size  IN NUMBER,
   p_debug_flag  IN VARCHAR2)
IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_debug  BOOLEAN := false;
    l_last_updated_by NUMBER:= fnd_global.user_id;
    l_last_update_login NUMBER:= fnd_global.conc_login_id;
    G_BATCH_SIZE NUMBER := 10000;
    l_opp_flag  VARCHAR2(1);
    l_status BOOLEAN;


    CURSOR Get_L_Min_Id IS
    select  min(lead_id)
    from  as_leads_all;

    CURSOR Get_L_Next_Val IS
    select AS_LEADS_S.nextval
    from dual;


    CURSOR Get_flag_from_Input(c_in_param_1 VARCHAR2,c_in_param_2 VARCHAR2) IS
    select NVL(OPP_FLAG,'N')
      from AS_STATUSES_B
     where status_code = c_in_param_2
       and UPPER(opp_open_status_flag) = UPPER(c_in_param_1);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.stapk.UPDATE_OPPTY_ACCESSES';

BEGIN

    IF Upper(X_STATUS_CODE) <> 'ALL' AND UPPER(NVL(X_OPEN_FLAG,'X')) NOT IN ('Y','N') THEN
      Write_log (l_module, 1, 'Invalid input for Status Flag!');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF Upper(X_STATUS_CODE) <> 'ALL' THEN
      Open Get_flag_from_Input(X_OPEN_FLAG,X_STATUS_CODE);
      Fetch Get_flag_from_Input INTO l_opp_flag;
      IF (Get_flag_from_Input%NOTFOUND) THEN
          Write_log (l_module, 1, 'Combination of Status Code and Open Flag is not valid!');
          Close Get_flag_from_Input;
          RAISE FND_API.G_EXC_ERROR;
      ELSE
          Close Get_flag_from_Input;
      END IF;
    END IF;

    IF (p_debug_flag = 'Y') THEN
    	l_debug := TRUE;
    ELSE
    	l_debug := FALSE;
    END IF;





    --Start updating oppty table
    IF l_opp_flag = 'Y' OR Upper(X_STATUS_CODE) = 'ALL' THEN

         --Get Min,Max Ids
         l_min_id := p_start_id;
         l_max_id := p_end_id;
         G_BATCH_SIZE := NVL(p_batch_size,10000);

    	 IF (l_debug) THEN
        	FND_FILE.PUT_LINE(FND_FILE.LOG,'Minimum Id  - Max id for opportunity for this worker :' || l_min_id ||'  to  '||l_max_id);
    	 END IF;


         -- Initialize counter
         l_count := l_min_id;

         while (l_count <= l_max_id)
         loop
             if (l_debug) Then
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Current loop count:' || l_count);
             end if;
             -- update statements for opptys here
             If Upper(X_STATUS_CODE) = 'ALL' THEN
                 execute immediate 'UPDATE /*+ INDEX(ld AS_LEADS_ALL_MT2)*/ AS_LEADS_ALL ld
                     SET ld.close_reason = (DECODE((SELECT opp_open_status_flag
                                          FROM AS_STATUSES_B st
                                                     WHERE st.status_code = ld.status
                                                       AND st.opp_flag = ''Y''),''Y'',NULL,''N'',nvl(ld.CLOSE_REASON,''NOT_SPECIFIED'')))
                       , ld.last_update_date = sysdate
                       , ld.last_updated_by = :l_last_updated_by
                       , ld.last_update_login = :l_last_update_login
                   WHERE ld.lead_id >= :l_count
                     AND ld.lead_id < :l_count1+:G_BATCH_SIZE
                     AND ld.lead_id < :l_max_id
                     AND ld.status is not null' using l_last_updated_by,l_last_update_login,l_count,l_count,G_BATCH_SIZE,l_max_id ;
             ELSIF Upper(X_OPEN_FLAG) = 'Y' THEN
                 execute immediate 'UPDATE /*+ INDEX(ld AS_LEADS_ALL_MT2)*/ AS_LEADS_ALL ld
                    SET ld.close_reason = null
                      , ld.last_update_date = sysdate
                      , ld.last_updated_by = :l_last_updated_by
                      , ld.last_update_login = :l_last_update_login
                  WHERE ld.lead_id >= :l_count
                    AND ld.lead_id < :l_count1+:G_BATCH_SIZE
                    AND ld.lead_id < :l_max_id
                    AND ld.status = :X_STATUS_CODE
                    AND ld.status is not null
                    AND ld.close_reason is not null' using l_last_updated_by,l_last_update_login,l_count,l_count,G_BATCH_SIZE,l_max_id,X_STATUS_CODE ;
             ELSIF Upper(X_OPEN_FLAG) = 'N' THEN
                 execute immediate 'UPDATE /*+ INDEX(ld AS_LEADS_ALL_MT2)*/ AS_LEADS_ALL ld
                    SET ld.close_reason = ''NOT_SPECIFIED''
                      , ld.last_update_date = sysdate
                      , ld.last_updated_by = :l_last_updated_by
                      , ld.last_update_login = :l_last_update_login
                  WHERE ld.lead_id >= :l_count
                    AND ld.lead_id < :l_count1+:G_BATCH_SIZE
                    AND ld.lead_id < :l_max_id
                    AND ld.status = :X_STATUS_CODE
                    AND ld.status is not null
                    AND ld.close_reason is null' using l_last_updated_by,l_last_update_login,l_count,l_count,G_BATCH_SIZE,l_max_id,X_STATUS_CODE ;
             END IF;
             -- end update statements for leads here
         commit;

             l_count := l_count + G_BATCH_SIZE;
         end loop;
         commit;

         if l_debug then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Update of close reason in opptys finished successfully');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        end if;
    END IF; -- Only if l_opp_flag is Y



 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ERRBUF := ERRBUF || sqlerrm;
         RETCODE := FND_API.G_RET_STS_ERROR;
         ROLLBACK;
         Write_log (l_module, 1, 'Error in as_statuses_pkg.update_oppty_accesses');
         Write_log (l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                   ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ERRBUF := ERRBUF||sqlerrm;
         RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK;
         Write_Log(l_module, 1, 'Unexpected error in as_statuses_pkg.update_oppty_accesses');
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
    WHEN others THEN
        ERRBUF := SQLERRM;
        RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK;
        Write_Log(l_module, 1, 'Exception: others in as_statuses_pkg.update_oppty_accesses');
        Write_Log(l_module, 1, 'SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));
         l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
         IF l_status = TRUE THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
         END IF ;
end UPDATE_OPPTY_ACCESSES;

end AS_STATUSES_PKG;

/
