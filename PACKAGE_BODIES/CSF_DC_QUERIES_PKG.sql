--------------------------------------------------------
--  DDL for Package Body CSF_DC_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DC_QUERIES_PKG" as
/* $Header: CSFDCQTB.pls 120.0 2005/05/25 10:55:06 appldev noship $ */

  procedure insert_row
  ( p_row_id                IN OUT NOCOPY varchar2
  , p_query_id              IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_name                  IN varchar2
  , p_description           IN varchar2
  , p_where_clause          IN varchar2
  , p_user_id               IN number
  , p_seeded_flag           IN varchar2
  , p_start_date_active     IN date
  , p_end_date_active       IN date
  )
  is

    cursor c_rowid ( p_query_id number )
    is
      select row_id
      from csf_dc_queries_vl
      where query_id = p_query_id;

  begin

    if p_query_id is null then
      select csf_dc_queries_s.nextval
      into p_query_id
      from dual;
    end if;

    if p_created_by is null then
      p_created_by        := fnd_global.user_id;
    end if;

    if p_last_updated_by is null then
      p_last_updated_by   := fnd_global.user_id;
    end if;

    if p_last_update_login is null then
      p_last_update_login := fnd_global.login_id;
    end if;

    if p_creation_date is null then
      p_creation_date     := sysdate;
    end if;

    if p_last_update_date is null then
      p_last_update_date  := sysdate;
    end if;

    insert into csf_dc_queries_b
    ( query_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , object_version_number
    , where_clause
    , user_id
    , seeded_flag
    , start_date_active
    , end_date_active
    )
    values
    ( p_query_id
    , p_created_by
    , p_creation_date
    , p_last_updated_by
    , p_last_update_date
    , p_last_update_login
    , p_object_version_number
    , p_where_clause
    , p_user_id
    , p_seeded_flag
    , p_start_date_active
    , p_end_date_active
    );

    insert into csf_dc_queries_tl
    ( query_id
    , language
    , source_lang
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , name
    , description
    )
    select
      p_query_id
    , l.language_code
    , userenv('LANG')
    , p_created_by
    , p_creation_date
    , p_last_updated_by
    , p_last_update_date
    , p_last_update_login
    , p_name
    , p_description
    from fnd_languages l
    where l.installed_flag in ('I','B')
    and not exists
        ( select ''
          from csf_dc_queries_tl t
          where t.query_id  = p_query_id
          and   t.language = l.language_code );

    open c_rowid ( p_query_id );
    fetch c_rowid into p_row_id;
    if c_rowid%notfound
    then
      close c_rowid;
      raise NO_DATA_FOUND;
    end if;
    close c_rowid;

  end insert_row;

  procedure update_row
  ( p_query_id              IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_name                  IN varchar2
  , p_description           IN varchar2
  , p_where_clause          IN varchar2
  , p_user_id               IN number
  , p_seeded_flag           IN varchar2
  , p_start_date_active     IN date
  , p_end_date_active       IN date
  )
  is
  begin

    if p_last_updated_by is null then
      p_last_updated_by   := fnd_global.user_id;
    end if;

    if p_last_update_login is null then
      p_last_update_login := fnd_global.login_id;
    end if;

    if p_last_update_date is null then
      p_last_update_date  := sysdate;
    end if;

    update csf_dc_queries_b
    set last_updated_by        = p_last_updated_by
    ,   last_update_date       = p_last_update_date
    ,   last_update_login      = p_last_update_login
    ,   object_version_number  = p_object_version_number
    ,   where_clause           = p_where_clause
    ,   user_id                = p_user_id
    ,   seeded_flag            = p_seeded_flag
    ,   start_date_active      = p_start_date_active
    ,   end_date_active        = p_end_date_active
    where query_id = p_query_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;

    update csf_dc_queries_tl
    set source_lang            = userenv('LANG')
    ,   last_updated_by        = p_last_updated_by
    ,   last_update_date       = p_last_update_date
    ,   last_update_login      = p_last_update_login
    ,   name                   = p_name
    ,   description            = p_description
    where query_id = p_query_id
    and   userenv('lang') in (language, source_lang);

  end update_row;

  procedure translate_row
  (
    p_query_id          IN varchar2
  , p_owner             IN varchar2
  , p_name              IN varchar2
  , p_description       IN varchar2
  )
  is
  begin
    update csf_dc_queries_tl
    set description = p_description,
        name = p_name,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where query_id = p_query_id
    and userenv('LANG') in (language, source_lang);
  end translate_row;

  procedure load_row
  ( p_query_id              IN varchar2
  , p_owner                 IN varchar2
  , p_object_version_number IN varchar2
  , p_name                  IN varchar2
  , p_description           IN varchar2
  , p_where_clause          IN varchar2
  , p_user_id               IN varchar2
  , p_seeded_flag           IN varchar2
  , p_start_date_active     IN varchar2
  , p_end_date_active       IN varchar2
  )
  is
    l_query_id              number;
    l_object_version_number number;
    l_update_date           date;
    l_row_id                varchar2(64);
    l_user                  number;

  begin
    l_query_id               := to_number(p_query_id);
    l_object_version_number  := to_number(p_object_version_number);
    l_update_date            := sysdate;
    l_user                   := 0;

    if (p_owner = 'SEED')
    then
      l_user := 1;
    end if;

    update_row
    ( p_query_id               => l_query_id
    , p_created_by             => l_user
    , p_creation_date          => l_update_date
    , p_last_updated_by        => l_user
    , p_last_update_date       => l_update_date
    , p_last_update_login      => l_user
    , p_object_version_number  => l_object_version_number
    , p_name                   => p_name
    , p_description            => p_description
    , p_where_clause           => p_where_clause
    , p_user_id                => to_number(p_user_id)
    , p_seeded_flag            => p_seeded_flag
    , p_start_date_active      => to_date(p_start_date_active,'DD/MM/RRRR')
    , p_end_date_active        => to_date(p_end_date_active,'DD/MM/RRRR')
    );
  exception
    when NO_DATA_FOUND then
      insert_row
      ( p_row_id                 => l_row_id
      , p_query_id               => l_query_id
      , p_created_by             => l_user
      , p_creation_date          => l_update_date
      , p_last_updated_by        => l_user
      , p_last_update_date       => l_update_date
      , p_last_update_login      => l_user
      , p_object_version_number  => l_object_version_number
      , p_name                   => p_name
      , p_description            => p_description
      , p_where_clause           => p_where_clause
      , p_user_id                => to_number(p_user_id)
      , p_seeded_flag            => p_seeded_flag
      , p_start_date_active      => to_date(p_start_date_active,'DD/MM/RRRR')
      , p_end_date_active        => to_date(p_end_date_active,'DD/MM/RRRR')
      );
  end load_row;


  PROCEDURE add_language
  IS
  BEGIN

    DELETE FROM csf_dc_queries_tl t
    WHERE NOT EXISTS
         (SELECT ''
          FROM   csf_dc_queries_tl tl
          WHERE  tl.query_id = t.query_id
         );

    UPDATE csf_dc_queries_tl t SET (  name , description) =
                                   ( SELECT  tl.name, tl.description
                                     FROM    csf_dc_queries_tl tl
                                     WHERE   tl.query_id = t.query_id
                                     AND     tl.language = t.source_lang)
    WHERE   (t.query_id, t.language) IN
      (SELECT  subt.query_id, subt.language
       FROM    csf_dc_queries_tl subb, csf_dc_queries_tl subt
       WHERE   subb.query_id = subt.query_id
       AND     subb.language = subt.source_lang
       AND     (subb.name <> subt.name
       OR      subb.description <> subt.description
       OR      (subb.description is null and subt.description is not null)
       OR      (subb.description is not null and subt.description is null))
       );

    INSERT INTO csf_dc_queries_tl
    ( query_id
    , description
    , name
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang
    )
    SELECT b.query_id
    ,      b.description
    ,      b.name
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    FROM csf_dc_queries_tl b
    ,    fnd_languages l
    WHERE l.installed_flag in ('I', 'B')
    AND   b.language = userenv('LANG')
    AND   NOT EXISTS
                   ( SELECT NULL
                     FROM   csf_dc_queries_tl t
                     WHERE  t.query_id  = b.query_id
                     AND    t.language = l.language_code );
  END add_language;

end CSF_DC_QUERIES_PKG;

/
