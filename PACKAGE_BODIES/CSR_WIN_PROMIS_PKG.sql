--------------------------------------------------------
--  DDL for Package Body CSR_WIN_PROMIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSR_WIN_PROMIS_PKG" as
/*$Header: CSRSIPWB.pls 120.1 2006/03/30 21:13:00 venjayar noship $
 +========================================================================+
 |                 Copyright (c) 1999 Oracle Corporation                  |
 |                    Redwood Shores, California, USA                     |
 |                         All rights reserved.                           |
 +========================================================================+
 Name
 ----
 CSR_WIN_PROMIS_PKG

 Purpose
 -------
 Insert, update, delete or lock tables belonging to view CSR_WIN_PROMIS_VL:
 - base table CSR_WIN_PROMIS_ALL_B, and
 - translation table CSR_WIN_PROMIS_ALL_TL.
 Check uniqueness of columns NAME and START/END_TIME combinations. Restore
 data integrity to a corrupted base/translation pair.

 History
 -------
 10-DEC-1999 E.Kerkhoven       First creation
  3-JAN-2000 M. van Teeseling  Translate_row and load_row added
 13-NOV-2002 J. van Grondelle  Bug 2664009.
                               Added NOCOPY hint to procedure
                               out-parameters.
 +========================================================================+
*/
  procedure check_unique
  (
    p_win_promis_id IN varchar2
  , p_name          IN varchar2
  , p_start_time    IN date
  , p_end_time      IN date
  )
  is
    cursor c_name
    is
      select ''
      from csr_win_promis_all_tl
      where ( p_win_promis_id is null
           or win_promis_id <> p_win_promis_id )
      and userenv('LANG') in (language, source_lang)
      and upper(name) = upper(p_name);

    cursor c_time
    is
      select ''
      from csr_win_promis_all_b
      where ( p_win_promis_id is null
           or win_promis_id <> p_win_promis_id )
      and ( to_char(start_time,'hh24:mi') = to_char(p_start_time,'hh24:mi')
        and to_char(end_time,'hh24:mi')   = to_char(p_end_time,'hh24:mi') );

    l_check number;
  begin
    open c_name;
    fetch c_name into l_check;
    if c_name%found
    then
      close c_name;
      fnd_message.set_name('CSR','PARS_PROM_NAME_NOT_UNIQUE');
      fnd_message.set_token('NAME',p_name);
      app_exception.raise_exception;
    end if;
    close c_name;

    open c_time;
    fetch c_time into l_check;
    if c_time%found
    then
      close c_time;
      fnd_message.set_name('CSR','PARS_PROM_TIME_NOT_UNIQUE');
      fnd_message.set_token('START',to_char(p_start_time,'hh24:mi'));
      fnd_message.set_token('END'  ,to_char(p_end_time,'hh24:mi'));
      app_exception.raise_exception;
    end if;
    close c_time;
  end check_unique;

  procedure insert_row
  (
    p_row_id             IN OUT NOCOPY varchar2
  , p_win_promis_id      IN OUT NOCOPY number
  , p_name               IN varchar2
  , p_description        IN varchar2
  , p_start_time         IN date
  , p_end_time           IN date
  , p_created_by         IN OUT NOCOPY number
  , p_creation_date      IN OUT NOCOPY date
  , p_last_updated_by    IN OUT NOCOPY number
  , p_last_update_date   IN OUT NOCOPY date
  , p_last_update_login  IN OUT NOCOPY number
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  , p_org_id             IN number
  )
  is
    cursor c_prom ( p_prom_id number )
    is
      select row_id
      from csr_win_promis_vl
      where win_promis_id = p_prom_id;

  begin

    if p_win_promis_id is null then
      select csr_win_promis_all_b_s1.nextval
      into p_win_promis_id
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

    insert into csr_win_promis_all_b
    (
      win_promis_id
    , start_time
    , end_time
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute_category
    , org_id
    )
    values
    (
      p_win_promis_id
    , p_start_time
    , p_end_time
    , p_created_by
    , p_creation_date
    , p_last_updated_by
    , p_last_update_date
    , p_last_update_login
    , p_attribute1
    , p_attribute2
    , p_attribute3
    , p_attribute4
    , p_attribute5
    , p_attribute6
    , p_attribute7
    , p_attribute8
    , p_attribute9
    , p_attribute10
    , p_attribute11
    , p_attribute12
    , p_attribute13
    , p_attribute14
    , p_attribute15
    , p_attribute_category
    , p_org_id
    );

    insert into csr_win_promis_all_tl
    (
      win_promis_id
    , name
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang
    )
    select p_win_promis_id
    ,      p_name
    ,      p_description
    ,      p_created_by
    ,      p_creation_date
    ,      p_last_updated_by
    ,      p_last_update_date
    ,      p_last_update_login
    ,      l.language_code
    ,      userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I','B')
    and not exists
        ( select ''
          from csr_win_promis_all_tl t
          where t.win_promis_id = p_win_promis_id
          and   t.language      = l.language_code );

    open c_prom ( p_win_promis_id );
    fetch c_prom into p_row_id;
    if c_prom%notfound
    then
      close c_prom;
      raise NO_DATA_FOUND;
    end if;
    close c_prom;
  end insert_row;

  procedure lock_row
  (
    p_win_promis_id      IN number
  , p_name               IN varchar2
  , p_description        IN varchar2
  , p_start_time         IN date
  , p_end_time           IN date
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  )
  is
    cursor c_prom
    is
      select *
      from csr_win_promis_vl
      where win_promis_id = p_win_promis_id
      for update nowait;

    l_rec c_prom%rowtype;

  begin
    open c_prom;
    fetch c_prom into l_rec;

    if c_prom%notfound
    then
      close c_prom;
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_prom;

    if to_char(l_rec.start_time,'hh24 mi') <> to_char(p_start_time,'hh24 mi')
    or to_char(l_rec.end_time  ,'hh24 mi') <> to_char(p_end_time  ,'hh24 mi')
    or l_rec.name <> rtrim(p_name)
    or not csr_utilities.compare_values(rtrim(p_description),l_rec.description)
    or not csr_utilities.compare_values(rtrim(p_attribute1),l_rec.attribute1)
    or not csr_utilities.compare_values(rtrim(p_attribute2),l_rec.attribute2)
    or not csr_utilities.compare_values(rtrim(p_attribute3),l_rec.attribute3)
    or not csr_utilities.compare_values(rtrim(p_attribute4),l_rec.attribute4)
    or not csr_utilities.compare_values(rtrim(p_attribute5),l_rec.attribute5)
    or not csr_utilities.compare_values(rtrim(p_attribute6),l_rec.attribute6)
    or not csr_utilities.compare_values(rtrim(p_attribute7),l_rec.attribute7)
    or not csr_utilities.compare_values(rtrim(p_attribute8),l_rec.attribute8)
    or not csr_utilities.compare_values(rtrim(p_attribute9),l_rec.attribute9)
    or not csr_utilities.compare_values(rtrim(p_attribute10),l_rec.attribute10)
    or not csr_utilities.compare_values(rtrim(p_attribute11),l_rec.attribute11)
    or not csr_utilities.compare_values(rtrim(p_attribute12),l_rec.attribute12)
    or not csr_utilities.compare_values(rtrim(p_attribute13),l_rec.attribute13)
    or not csr_utilities.compare_values(rtrim(p_attribute14),l_rec.attribute14)
    or not csr_utilities.compare_values(rtrim(p_attribute15),l_rec.attribute15)
    or not csr_utilities.compare_values(rtrim(p_attribute_category),
                                        l_rec.attribute_category)
    then
      fnd_message.set_name('FND','FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end lock_row;

  procedure update_row
  (
    p_win_promis_id      IN number
  , p_name               IN varchar2
  , p_description        IN varchar2
  , p_start_time         IN date
  , p_end_time           IN date
  , p_last_updated_by    IN OUT NOCOPY number
  , p_last_update_date   IN OUT NOCOPY date
  , p_last_update_login  IN OUT NOCOPY number
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
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

    update csr_win_promis_all_b
    set start_time         = p_start_time
    ,   end_time           = p_end_time
    ,   last_update_date   = p_last_update_date
    ,   last_updated_by    = p_last_updated_by
    ,   last_update_login  = p_last_update_login
    ,   attribute1         = p_attribute1
    ,   attribute2         = p_attribute2
    ,   attribute3         = p_attribute3
    ,   attribute4         = p_attribute4
    ,   attribute5         = p_attribute5
    ,   attribute6         = p_attribute6
    ,   attribute7         = p_attribute7
    ,   attribute8         = p_attribute8
    ,   attribute9         = p_attribute9
    ,   attribute10        = p_attribute10
    ,   attribute11        = p_attribute11
    ,   attribute12        = p_attribute12
    ,   attribute13        = p_attribute13
    ,   attribute14        = p_attribute14
    ,   attribute15        = p_attribute15
    ,   attribute_category = p_attribute_category
    where win_promis_id = p_win_promis_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;

    update csr_win_promis_all_tl
    set name              = p_name
    ,   description       = p_description
    ,   last_update_date  = p_last_update_date
    ,   last_updated_by   = p_last_updated_by
    ,   last_update_login = p_last_update_login
    ,   source_lang       = userenv('lang')
    where win_promis_id = p_win_promis_id
    and userenv('lang') in (language, source_lang);

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;
  end update_row;

  procedure delete_row
  (
    p_win_promis_id IN number
  )
  is
  begin
    delete from csr_win_promis_all_tl
    where win_promis_id = p_win_promis_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;

    delete from csr_win_promis_all_b
    where win_promis_id = p_win_promis_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;
  end delete_row;

  procedure add_language
  is
  begin
    delete from csr_win_promis_all_tl t
    where not exists
          ( select ''
            from csr_win_promis_all_b b
            where b.win_promis_id = t.win_promis_id );

    update csr_win_promis_all_tl t
    set ( name, description ) =
        ( select b.name
          ,      b.description
          from csr_win_promis_all_tl b
          where b.win_promis_id = t.win_promis_id
          and   b.language      = t.source_lang )
    where ( t.win_promis_id, t.language ) in
          ( select subt.win_promis_id
            ,      subt.language
            from csr_win_promis_all_tl subb
            ,    csr_win_promis_all_tl subt
            where subb.win_promis_id = subt.win_promis_id
            and   subb.language      = subt.source_lang
            and   ( subb.name <> subt.name
                 or subb.description <> subt.description
                 or ( subb.description is null
                  and subt.description is not null )
                 or ( subb.description is not null
                  and subt.description is null ) ) );

    insert into csr_win_promis_all_tl
    ( win_promis_id
    , name
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang
    )
    select b.win_promis_id
    ,      b.name
    ,      b.description
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    from csr_win_promis_all_tl b
    ,    fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   b.language = userenv('LANG')
    and not exists
        ( select null
          from csr_win_promis_all_tl t
          where t.win_promis_id = b.win_promis_id
          and   t.language      = l.language_code );
  end add_language;

  procedure translate_row
  (
    p_win_promis_id     IN varchar2
  , p_name              IN varchar2
  , p_description       IN varchar2
  , p_owner             IN varchar2
  )
  is
  begin
    update CSR_WIN_PROMIS_ALL_TL
    set name = p_name,
        description = p_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where win_promis_id = to_number(p_win_promis_id)
    and userenv('LANG') in (language, source_lang);
  end translate_row;

  procedure load_row
  (
    p_win_promis_id      IN varchar2
  , p_name               IN varchar2
  , p_description        IN varchar2
  , p_start_time         IN varchar2
  , p_end_time           IN varchar2
  , p_owner              IN varchar2
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  , p_org_id             IN varchar2
  )
  is
    l_win_promis_id     number := to_number(p_win_promis_id);
    l_update_date       date   := sysdate;
    l_row_id            varchar2(64);
    l_user_id           number := 0;
  begin
    if (p_owner = 'SEED')
    then
      l_user_id := 1;
    end if;

    update_row
    (
      p_win_promis_id     => l_win_promis_id
    , p_name              => p_name
    , p_description       => p_description
    , p_start_time        => to_date(p_start_time, 'HH24:MI')
    , p_end_time          => to_date(p_end_time, 'HH24:MI')
    , p_last_updated_by   => l_user_id
    , p_last_update_date  => l_update_date
    , p_last_update_login => l_user_id
    , p_attribute1        => p_attribute1
    , p_attribute2        => p_attribute2
    , p_attribute3        => p_attribute3
    , p_attribute4        => p_attribute4
    , p_attribute5        => p_attribute5
    , p_attribute6        => p_attribute6
    , p_attribute7        => p_attribute7
    , p_attribute8        => p_attribute8
    , p_attribute9        => p_attribute9
    , p_attribute10       => p_attribute10
    , p_attribute11       => p_attribute11
    , p_attribute12       => p_attribute12
    , p_attribute13       => p_attribute13
    , p_attribute14       => p_attribute14
    , p_attribute15       => p_attribute15
    , p_attribute_category => p_attribute_category
    );
  exception
    when NO_DATA_FOUND then
      insert_row
      (
        p_row_id             => l_row_id
      , p_win_promis_id      => l_win_promis_id
      , p_name               => p_name
      , p_description        => p_description
      , p_start_time         => to_date(p_start_time, 'HH24:MI')
      , p_end_time           => to_date(p_end_time, 'HH24:MI')
      , p_created_by         => l_user_id
      , p_creation_date      => l_update_date
      , p_last_updated_by    => l_user_id
      , p_last_update_date   => l_update_date
      , p_last_update_login  => l_user_id
      , p_attribute1         => p_attribute1
      , p_attribute2         => p_attribute2
      , p_attribute3         => p_attribute3
      , p_attribute4         => p_attribute4
      , p_attribute5         => p_attribute5
      , p_attribute6         => p_attribute6
      , p_attribute7         => p_attribute7
      , p_attribute8         => p_attribute8
      , p_attribute9         => p_attribute9
      , p_attribute10        => p_attribute10
      , p_attribute11        => p_attribute11
      , p_attribute12        => p_attribute12
      , p_attribute13        => p_attribute13
      , p_attribute14        => p_attribute14
      , p_attribute15        => p_attribute15
      , p_attribute_category => p_attribute_category
      , p_org_id             => to_number(p_org_id)
      );
  end load_row;

end CSR_WIN_PROMIS_PKG;

/
