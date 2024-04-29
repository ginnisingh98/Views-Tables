--------------------------------------------------------
--  DDL for Package Body FND_OAM_DS_ALGOS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DS_ALGOS_PKG" as
/* $Header: AFOAMDSALGOB.pls 120.3 2006/01/17 11:43 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DS_ALGOS_PKG.';

   -- When algorithms are resolved, we cache the details of that resolution locally
   -- because it's common to re-use algorithms many times in one configuration import.
   -- Only cache the raw algo text to prevent the query, don't cache it with substitutions
   -- because the substitutions shouldn't repeat.
   TYPE b_algo_cache_entry_type IS RECORD
      (
       is_valid                 BOOLEAN         := FALSE,
       used_algo_id             NUMBER          := NULL,
       datatype                 VARCHAR2(30)    := NULL,
       raw_algo_text            VARCHAR2(4000)  := NULL,
       weight_modifier          NUMBER          := NULL
       );

   TYPE b_algo_cache_type IS TABLE OF b_algo_cache_entry_type INDEX BY BINARY_INTEGER;
   b_algo_cache         b_algo_cache_type;

   --cache for queried default algorithms, datatype->algo_id
   TYPE b_default_algo_cache_type IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
   b_default_algo_cache         b_default_algo_cache_type;

   --#########################################
   --  Substitition Token-related constants --
   --#########################################

   -- This is the token identifying delimiter, present before and after a token
   B_TOK_DELIM                  CONSTANT VARCHAR2(3) := '%';

   -- These are the substitution tokens we accept
   B_TOKEN_TABLE_OWNER          CONSTANT VARCHAR2(60) := B_TOK_DELIM||'table_owner'||B_TOK_DELIM;
   B_TOKEN_TABLE_NAME           CONSTANT VARCHAR2(60) := B_TOK_DELIM||'table_name'||B_TOK_DELIM;
   B_TOKEN_COLUMN_NAME          CONSTANT VARCHAR2(60) := B_TOK_DELIM||'column_name'||B_TOK_DELIM;

   -- This is the substitution token state
   --b_token_table_initialized  BOOLEAN := FALSE;
   --TYPE b_token_table_type IS TABLE OF VARCHAR2(60);
   --b_token_table              b_token_table_type;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION GET_ALGO_ID(p_display_name  IN VARCHAR2)
      RETURN NUMBER
   IS
      l_algo_id         NUMBER;
   BEGIN
      --don't allow the name NULL
      IF p_display_name IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      SELECT algo_id
         INTO l_algo_id
         FROM fnd_oam_ds_algos_tl
         WHERE display_name = p_display_name
         AND language = USERENV('LANG');

      RETURN l_algo_id;
   END;

   -- Private
   -- Given some raw algorithm text, perform substitutions on all known substitution tokens
   PROCEDURE REPLACE_SUBSTITUTION_TOKENS(p_raw_algo_text        IN VARCHAR2,
                                         p_table_owner          IN VARCHAR2,
                                         p_table_name           IN VARCHAR2,
                                         p_column_name          IN VARCHAR2,
                                         x_new_algo_text        OUT NOCOPY VARCHAR2)
   IS
      l_text    VARCHAR2(4000) := p_raw_algo_text;
   BEGIN
      -- issue each of the replace statements, this needs to be changed when new tokens are added
      -- if the new text is beyond the l_text max length, let the exception bubble up
      l_text := REPLACE(l_text, B_TOKEN_TABLE_OWNER, p_table_owner);
      l_text := REPLACE(l_text, B_TOKEN_TABLE_NAME, p_table_name);
      l_text := REPLACE(l_text, B_TOKEN_COLUMN_NAME, p_column_name);

      x_new_algo_text := l_text;
   END;

   -- Private
   -- Creates and caches a new algo_cache_entry_type when we found a bad algo definition
   PROCEDURE ADD_BAD_ALGO_CACHE_ENTRY(p_algo_id         IN NUMBER)
   IS
      l_entry   b_algo_cache_entry_type;
   BEGIN
      l_entry.is_valid          := FALSE;

      b_algo_cache(p_algo_id) := l_entry;
   END;

   -- Private
   -- Creates and caches a new, valid algo_cache_entry_type
   PROCEDURE ADD_ALGO_CACHE_ENTRY(p_algo_id             IN NUMBER,
                                  p_used_algo_id        IN NUMBER,
                                  p_datatype            IN VARCHAR2,
                                  p_raw_algo_text       IN VARCHAR2,
                                  p_weight_modifier     IN NUMBER)
   IS
      l_entry   b_algo_cache_entry_type;
   BEGIN
      l_entry.used_algo_id      := p_used_algo_id;
      l_entry.datatype          := p_datatype;
      l_entry.raw_algo_text     := p_raw_algo_text;
      l_entry.weight_modifier   := p_weight_modifier;
      l_entry.is_valid          := TRUE;

      b_algo_cache(p_algo_id) := l_entry;
   END;

   -- Public
   PROCEDURE RESOLVE_ALGO_ID(p_algo_id                  IN NUMBER,
                             p_table_owner              IN VARCHAR2 DEFAULT NULL,
                             p_table_name               IN VARCHAR2 DEFAULT NULL,
                             p_column_name              IN VARCHAR2 DEFAULT NULL,
                             x_new_column_value         OUT NOCOPY VARCHAR2,
                             x_weight_modifier          OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'RESOLVE_ALGO_ID';

      l_current_algo_id         NUMBER;
      l_use_algo_id             NUMBER;
      l_datatype                VARCHAR2(30);
      l_raw_algo_text           VARCHAR2(4000);
      l_weight_modifier         NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --see if the algo misses the cache, if so find it's base definition and add it
      IF NOT b_algo_cache.EXISTS(p_algo_id) THEN
         fnd_oam_debug.log(1, l_ctxt, 'Uncached... finding root algo_id.');
         --loop the fetch to resolve the chain of use_algo_id references
         l_current_algo_id := p_algo_id;
         WHILE TRUE LOOP
            fnd_oam_debug.log(1, l_ctxt, 'Querying details for algo_id: '||l_current_algo_id);
            --fetch attributes corresponding to the current algo id
            BEGIN
               SELECT use_algo_id, datatype, algo_text, weight_modifier
                  INTO l_use_algo_id, l_datatype, l_raw_algo_text, l_weight_modifier
                  FROM fnd_oam_ds_algos_b
                  WHERE algo_id = l_current_algo_id
                  AND SYSDATE BETWEEN NVL(START_DATE, SYSDATE) AND NVL(END_DATE, SYSDATE);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --if the lookup fails, store that failure in the cache
                  fnd_oam_debug.log(3, l_ctxt, 'Failed to query algo_id from ds_algos_b - no data found.');
                  ADD_BAD_ALGO_CACHE_ENTRY(p_algo_id => p_algo_id);
                  RAISE;
            END;

            --if there's no queried use_algo_id, we have our definition
            IF l_use_algo_id IS NULL THEN
               fnd_oam_debug.log(1, l_ctxt, 'Caching base algo_id: '||l_current_algo_id);
               ADD_ALGO_CACHE_ENTRY(p_algo_id           => p_algo_id,
                                    p_used_algo_id      => l_current_algo_id,
                                    p_datatype          => l_datatype,
                                    p_raw_algo_text     => l_raw_algo_text,
                                    p_weight_modifier   => l_weight_modifier);
               EXIT;
            ELSE
               l_current_algo_id := l_use_algo_id;
            END IF;
         END LOOP;
      END IF;

      --at this point we should be guaranteed that the algo is in the cache, see if its valid
      IF NOT b_algo_cache.EXISTS(p_algo_id) OR NOT b_algo_cache(p_algo_id).is_valid THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --we have a valid algo cache entry, make the new column value using any necessary substitutions
      REPLACE_SUBSTITUTION_TOKENS(b_algo_cache(p_algo_id).raw_algo_text,
                                  p_table_owner,
                                  p_table_name,
                                  p_column_name,
                                  x_new_column_value);
      x_weight_modifier := b_algo_cache(p_algo_id).weight_modifier;

      -- Success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN VALUE_ERROR THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE GET_DEFAULT_ALGO_FOR_DATATYPE(p_datatype   IN VARCHAR2,
                                           x_algo_id    OUT NOCOPY NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_DEFAULT_ALGO_FOR_DATATYPE';

      l_id              NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --see if we've already queried this datatype
      IF b_default_algo_cache.EXISTS(p_datatype) THEN
         --if we cached the algo_id NULL, we cached failure
         l_id := b_default_algo_cache(p_datatype);
         IF l_id IS NULL THEN
            RAISE NO_DATA_FOUND;
         END IF;
      ELSE
         fnd_oam_debug.log(1, l_ctxt, 'Querying default for datatype "'||p_datatype||'"...');

         --do the query, automatically throws NO_DATA_FOUND/TOO_MANY_ROWS if less than or greater than one row
         BEGIN
            SELECT algo_id
               INTO l_id
               FROM fnd_oam_ds_algos_b
               WHERE datatype = p_datatype
               AND default_for_datatype_flag = FND_API.G_TRUE;

            --cache the result
            fnd_oam_debug.log(1, l_ctxt, 'Found id: '||l_id);
            b_default_algo_cache(p_datatype) := l_id;
         EXCEPTION
            WHEN OTHERS THEN
               --cache failure
               fnd_oam_debug.log(3, l_ctxt, 'Failed to find a default: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
               b_default_algo_cache(p_datatype) := NULL;
               RAISE;
         END;
      END IF;

      x_algo_id := l_id;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN TOO_MANY_ROWS THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;


  --PROCEDURES REQUIRED BY FNDLOADER

  procedure LOAD_ROW (
      X_ALGO_ID             in NUMBER,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_OWNER               in VARCHAR2,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2) IS
  begin

     FND_OAM_DS_ALGOS_PKG.LOAD_ROW (
       X_ALGO_ID => X_ALGO_ID,
       X_START_DATE => X_START_DATE,
       X_END_DATE => X_END_DATE,
       X_USE_ALGO_ID => X_USE_ALGO_ID,
       X_DEFAULT_FOR_DATATYPE_FLAG => X_DEFAULT_FOR_DATATYPE_FLAG,
       X_DATATYPE => X_DATATYPE,
       X_ALGO_TEXT => X_ALGO_TEXT,
       X_WEIGHT_MODIFIER => X_WEIGHT_MODIFIER,
       X_OWNER       => X_OWNER,
       X_DISPLAY_NAME => X_DISPLAY_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       X_LAST_UPDATE_DATE => '');

  end LOAD_ROW;

  procedure LOAD_ROW (
      X_ALGO_ID             in NUMBER,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_OWNER               in VARCHAR2,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      x_custom_mode         in varchar2,
      X_LAST_UPDATE_DATE    in varchar2)
    is
      malgo_id number;
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
    begin

      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(x_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      begin
        -- check if this algorithm id already exists.
        select algo_id, LAST_UPDATED_BY, LAST_UPDATE_DATE
        into malgo_id, db_luby, db_ludate
        from   fnd_oam_ds_algos_b
    where  algo_id = to_number(X_ALGO_ID);

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_DS_ALGOS_PKG.UPDATE_ROW (
          X_ALGO_ID => malgo_id,
          X_START_DATE => X_START_DATE,
          X_END_DATE => X_END_DATE,
          X_USE_ALGO_ID => X_USE_ALGO_ID,
          X_DEFAULT_FOR_DATATYPE_FLAG => X_DEFAULT_FOR_DATATYPE_FLAG,
          X_DATATYPE => X_DATATYPE,
          X_ALGO_TEXT => X_ALGO_TEXT,
          X_WEIGHT_MODIFIER => X_WEIGHT_MODIFIER,
          X_DISPLAY_NAME => X_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATE_LOGIN => 0 );

        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_DS_ALGOS_PKG.INSERT_ROW (
          X_ROWID => row_id,
          X_ALGO_ID => X_ALGO_ID,
          X_START_DATE => X_START_DATE,
          X_END_DATE => X_END_DATE,
          X_USE_ALGO_ID => X_USE_ALGO_ID,
          X_DEFAULT_FOR_DATATYPE_FLAG => X_DEFAULT_FOR_DATATYPE_FLAG,
          X_DATATYPE => X_DATATYPE,
          X_ALGO_TEXT => X_ALGO_TEXT,
          X_WEIGHT_MODIFIER => X_WEIGHT_MODIFIER,
          X_DISPLAY_NAME => X_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;

  end LOAD_ROW;

  --TRANSLATE ROW

   procedure TRANSLATE_ROW (
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_OWNER               in  VARCHAR2)
  is
  begin

  FND_OAM_DS_ALGOS_PKG.translate_row(
    X_ALGO_ID => X_ALGO_ID,
    X_DISPLAY_NAME => X_DISPLAY_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => '',
    X_LAST_UPDATE_DATE => '');

  end TRANSLATE_ROW;

  procedure TRANSLATE_ROW (
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_OWNER               in  VARCHAR2,
      X_CUSTOM_MODE                   in        VARCHAR2,
      X_LAST_UPDATE_DATE          in    VARCHAR2)
  IS

      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db

  begin

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    begin
      select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      from fnd_oam_ds_algos_tl
      where algo_id = to_number(X_ALGO_ID)
      and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_oam_ds_algos_tl set
          display_name    = nvl(X_DISPLAY_NAME, display_name),
          description         = nvl(X_DESCRIPTION, description),
          source_lang         = userenv('LANG'),
          last_update_date    = f_ludate,
          last_updated_by     = f_luby,
          last_update_login   = 0
        where algo_id = to_number(X_ALGO_ID)
          and userenv('LANG') in (language, source_lang);
      end if;
    exception
      when no_data_found then
        null;
    end;

  end TRANSLATE_ROW;


  --INSERT ROW
  procedure INSERT_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER)
 is
  cursor C is select ROWID from FND_OAM_DS_ALGOS_B
    where ALGO_ID = X_ALGO_ID;
begin
  insert into FND_OAM_DS_ALGOS_B (
        ALGO_ID,
        START_DATE,
        END_DATE,
  USE_ALGO_ID,
  DEFAULT_FOR_DATATYPE_FLAG,
  DATATYPE,
  ALGO_TEXT,
  WEIGHT_MODIFIER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
  ) values (
        X_ALGO_ID,
        X_START_DATE,
        X_END_DATE,
  X_USE_ALGO_ID,
  X_DEFAULT_FOR_DATATYPE_FLAG,
  X_DATATYPE,
  X_ALGO_TEXT,
  X_WEIGHT_MODIFIER,
        X_CREATED_BY,
        X_CREATION_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN
  );

  insert into FND_OAM_DS_ALGOS_TL (
        ALGO_ID,
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
        X_ALGO_ID,
  X_DISPLAY_NAME,
        X_DESCRIPTION,
        X_CREATED_BY,
        X_CREATION_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_DS_ALGOS_TL T
    where T.ALGO_ID = X_ALGO_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

   --LOCK ROW

  procedure LOCK_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER
) is
  cursor c is select
        ALGO_ID,
        START_DATE,
        END_DATE,
  USE_ALGO_ID,
  DEFAULT_FOR_DATATYPE_FLAG,
  DATATYPE,
  ALGO_TEXT,
  WEIGHT_MODIFIER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    from FND_OAM_DS_ALGOS_B
    where ALGO_ID = X_ALGO_ID
    for update of ALGO_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OAM_DS_ALGOS_TL
    where ALGO_ID = X_ALGO_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ALGO_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.USE_ALGO_ID = X_USE_ALGO_ID)
           OR ((recinfo.USE_ALGO_ID is null) AND (X_USE_ALGO_ID is null)))
      AND ((recinfo.DEFAULT_FOR_DATATYPE_FLAG = X_DEFAULT_FOR_DATATYPE_FLAG)
           OR ((recinfo.DEFAULT_FOR_DATATYPE_FLAG is null) AND (X_DEFAULT_FOR_DATATYPE_FLAG is null)))
      AND ((recinfo.DATATYPE = X_DATATYPE)
           OR ((recinfo.DATATYPE is null) AND (X_DATATYPE is null)))
      AND ((recinfo.ALGO_TEXT = X_ALGO_TEXT)
           OR ((recinfo.ALGO_TEXT is null) AND (X_ALGO_TEXT is null)))
      AND ((recinfo.WEIGHT_MODIFIER = X_WEIGHT_MODIFIER)
           OR ((recinfo.WEIGHT_MODIFIER is null) AND (X_WEIGHT_MODIFIER is null)))
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

--UPDATE ROW

  procedure UPDATE_ROW (
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER
) is
begin
  update FND_OAM_DS_ALGOS_B set
      START_DATE = X_START_DATE,
      END_DATE = X_END_DATE,
      USE_ALGO_ID = X_USE_ALGO_ID,
      DEFAULT_FOR_DATATYPE_FLAG = X_DEFAULT_FOR_DATATYPE_FLAG,
      DATATYPE = X_DATATYPE,
      ALGO_TEXT = X_ALGO_TEXT,
      WEIGHT_MODIFIER = X_WEIGHT_MODIFIER,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ALGO_ID = X_ALGO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OAM_DS_ALGOS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ALGO_ID = X_ALGO_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


  --DELETE ROW

  procedure DELETE_ROW (
      X_ALGO_ID           in NUMBER
) is
begin
  delete from FND_OAM_DS_ALGOS_TL
  where ALGO_ID = X_ALGO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OAM_DS_ALGOS_B
  where ALGO_ID = X_ALGO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


  --ADD LANGUAGE

procedure ADD_LANGUAGE
is
begin
  delete from FND_OAM_DS_ALGOS_TL T
  where not exists
    (select NULL
    from FND_OAM_DS_ALGOS_B B
    where B.ALGO_ID = T.ALGO_ID
    );

  update FND_OAM_DS_ALGOS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_OAM_DS_ALGOS_TL B
    where B.ALGO_ID = T.ALGO_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ALGO_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ALGO_ID,
      SUBT.LANGUAGE
    from FND_OAM_DS_ALGOS_TL SUBB, FND_OAM_DS_ALGOS_TL SUBT
    where SUBB.ALGO_ID = SUBT.ALGO_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_OAM_DS_ALGOS_TL (
    ALGO_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ALGO_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_DS_ALGOS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_DS_ALGOS_TL T
    where T.ALGO_ID = B.ALGO_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


  --TRANSLATE ROW

  procedure TRANSLATE_ROW
  (
      x_ALGO_ID             in NUMBER,
      x_DISPLAY_NAME        in varchar2,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER)
is
begin

UPDATE FND_OAM_DS_ALGOS_TL SET
  DISPLAY_NAME  = nvl(x_DISPLAY_NAME,DISPLAY_NAME),
  last_update_date        = nvl(x_last_update_date,sysdate),
  last_updated_by         = x_last_updated_by,
  last_update_login       = 0,
  source_lang             = userenv('LANG')
WHERE ALGO_ID      = x_ALGO_ID
AND userenv('LANG') in (LANGUAGE,SOURCE_LANG);

  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;

end TRANSLATE_ROW;
 --END OF PROCEDURES REQUIRED BY FNDLOADER.

END FND_OAM_DS_ALGOS_PKG;

/
