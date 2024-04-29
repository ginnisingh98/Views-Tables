--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_RANKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_RANKS_PKG" as
/* #$Header: asxtrnkb.pls 115.10 2002/11/19 22:24:11 chchandr ship $ */

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

procedure INSERT_ROW (
  X_RANK_ID in OUT NOCOPY NUMBER,
  X_MIN_SCORE in NUMBER,
  X_MAX_SCORE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  /*cursor C is select ROWID from AS_SALES_LEAD_RANKS_B
    where RANK_ID = X_RANK_ID
    ;
  l_rowid number;
   */
begin
  insert into AS_SALES_LEAD_RANKS_B (
    RANK_ID,
    MIN_SCORE,
    MAX_SCORE,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RANK_ID,
    X_MIN_SCORE,
    X_MAX_SCORE,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AS_SALES_LEAD_RANKS_TL (
    RANK_ID,
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
    X_RANK_ID,
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
    from AS_SALES_LEAD_RANKS_TL T
    where T.RANK_ID = X_RANK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

    /*
  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
     */
end INSERT_ROW;

procedure LOCK_ROW (
  X_RANK_ID in NUMBER,
  X_MIN_SCORE in NUMBER,
  X_MAX_SCORE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_MEANING in VARCHAR2
) is
  cursor c is select
      MIN_SCORE,
      MAX_SCORE,
      ENABLED_FLAG
    from AS_SALES_LEAD_RANKS_B
    where RANK_ID = X_RANK_ID
    for update of RANK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AS_SALES_LEAD_RANKS_TL
    where RANK_ID = X_RANK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RANK_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ((recinfo.MIN_SCORE = X_MIN_SCORE)
      AND (recinfo.MAX_SCORE = X_MAX_SCORE)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_RANK_ID in NUMBER,
  X_MIN_SCORE in NUMBER,
  X_MAX_SCORE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AS_SALES_LEAD_RANKS_B set
    MIN_SCORE = X_MIN_SCORE,
    MAX_SCORE = X_MAX_SCORE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RANK_ID = X_RANK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AS_SALES_LEAD_RANKS_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RANK_ID = X_RANK_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RANK_ID in NUMBER
) is
begin
  delete from AS_SALES_LEAD_RANKS_TL
  where RANK_ID = X_RANK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AS_SALES_LEAD_RANKS_B
  where RANK_ID = X_RANK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AS_SALES_LEAD_RANKS_TL T
  where not exists
    (select NULL
    from AS_SALES_LEAD_RANKS_B B
    where B.RANK_ID = T.RANK_ID
    );

  update AS_SALES_LEAD_RANKS_TL T set (
      MEANING
    ) = (select
      B.MEANING
    from AS_SALES_LEAD_RANKS_TL B
    where B.RANK_ID = T.RANK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RANK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RANK_ID,
      SUBT.LANGUAGE
    from AS_SALES_LEAD_RANKS_TL SUBB, AS_SALES_LEAD_RANKS_TL SUBT
    where SUBB.RANK_ID = SUBT.RANK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
  ));

  insert into AS_SALES_LEAD_RANKS_TL (
    --SECURITY_GROUP_ID,
    RANK_ID,
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
   -- B.SECURITY_GROUP_ID,
    B.RANK_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.MEANING,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AS_SALES_LEAD_RANKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_SALES_LEAD_RANKS_TL T
    where T.RANK_ID = B.RANK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Load_Row (
        X_RANK_ID in OUT NOCOPY NUMBER,
        X_MIN_SCORE in NUMBER,
        X_MAX_SCORE in NUMBER,
        X_ENABLED_FLAG in VARCHAR2,
        X_MEANING in VARCHAR2,
        X_DESCRIPTION IN VARCHAR2,
        X_OWNER in VARCHAR2)
IS
    user_id            number := 0;
    row_id             varchar2(64);

    -- FFANG 112700 FOR bug 1505582
    CURSOR c_get_last_updated (c_rank_id NUMBER) IS
        SELECT last_updated_by
        FROM AS_SALES_LEAD_RANKS_B
        WHERE rank_id = c_rank_id;
    l_last_updated_by  NUMBER;
    -- END FFANG 112700

BEGIN
    -- FFANG 112700 FOR bug 1505582
    -- If last_updated_by is not 1, means this record has been updated by
    -- customer, we should not overwrite it.
    OPEN c_get_last_updated (x_RANK_ID);
    FETCH c_get_last_updated INTO l_last_updated_by;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN
        if (X_OWNER = 'SEED') then
            user_id := 1;
        end if;

        Update_Row(x_RANK_ID            => x_RANK_ID,
                   x_MIN_SCORE          => x_MIN_SCORE,
                   x_MAX_SCORE          => x_MAX_SCORE,
                   x_enabled_flag       => x_enabled_flag,
                   x_meaning            => x_meaning,
                   x_description        => x_description,
                   X_LAST_UPDATE_DATE   => sysdate,
                   X_LAST_UPDATED_BY    => user_id,
                   X_LAST_UPDATE_LOGIN  => 0
                   );
    END IF;

    EXCEPTION
        when no_data_found then
            Insert_Row(x_RANK_ID            => x_RANK_ID,
                       x_MIN_SCORE          => x_MIN_SCORE,
                       x_MAX_SCORE          => x_MAX_SCORE,
                       x_enabled_flag       => x_enabled_flag,
                       x_meaning            => x_meaning,
                       x_description        => x_description,
                       x_creation_date      => sysdate,
                       x_created_by         => 0,
                       X_LAST_UPDATE_DATE   => sysdate,
                       X_LAST_UPDATED_BY    => user_id,
                       X_LAST_UPDATE_LOGIN  => 0
                       );
END load_row;



  PROCEDURE translate_row (
                P_sales_lead_rank_id IN NUMBER,
                P_meaning            IN VARCHAR2,
                P_owner              IN VARCHAR2) IS
  BEGIN

      -- only UPDATE rows that have not been altered by user
      UPDATE AS_SALES_LEAD_RANKS_TL SET
        meaning = p_meaning,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', -1, 0),
        last_update_login = 0
      WHERE rank_id = P_sales_lead_rank_id
      AND   userenv('LANG') IN (language, source_lang);
  END translate_row;
end AS_SALES_LEAD_RANKS_PKG;

/
