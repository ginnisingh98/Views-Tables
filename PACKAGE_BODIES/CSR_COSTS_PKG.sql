--------------------------------------------------------
--  DDL for Package Body CSR_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSR_COSTS_PKG" as
/*$Header: CSRSIPCB.pls 115.13 2002/11/22 13:01:39 jgrondel ship $
 +========================================================================+
 |                 Copyright (c) 1999 Oracle Corporation                  |
 |                    Redwood Shores, California, USA                     |
 |                         All rights reserved.                           |
 +========================================================================+
 Name
 ----
 CSR_COSTS_PKG

 Purpose
 -------
 Insert, update, delete or lock tables belonging to view CSR_COSTS_VL:
 - base table CSR_COSTS_ALL_B, and
 - translation table CSR_COSTS_ALL_TL.
 Restore data integrity to a corrupted base/translation pair.

 History
 -------
 10-DEC-1999 E.Kerkhoven       First creation
  3-JAN-2000 M. van Teeseling  Translate_row and load_row added
 13-NOV-2002 J. van Grondelle  Bug 2664009.
                               Added NOCOPY hint to procedure
                               out-parameters.
 +========================================================================+
*/
  procedure insert_row
  (
    p_row_id             IN OUT NOCOPY varchar2
  , p_cost_id            IN OUT NOCOPY number
  , p_name               IN varchar2
  , p_value              IN number
  , p_description        IN varchar2
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
    cursor c_cost ( p_cost_id number )
    is
      select row_id
      from csr_costs_vl
      where cost_id = p_cost_id;

  begin

    if p_cost_id is null then
      select csr_costs_all_b_s1.nextval
      into p_cost_id
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

    insert into csr_costs_all_b
    (
      cost_id
    , name
    , value
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
      p_cost_id
    , p_name
    , p_value
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

    insert into csr_costs_all_tl
    (
      cost_id
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang
    )
    select p_cost_id
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
          from csr_costs_all_tl t
          where t.cost_id  = p_cost_id
          and   t.language = l.language_code );

    open c_cost ( p_cost_id );
    fetch c_cost into p_row_id;
    if c_cost%notfound
    then
      close c_cost;
      raise NO_DATA_FOUND;
    end if;
    close c_cost;
  end insert_row;

  procedure lock_row
  (
    p_cost_id            IN number
  , p_name               IN varchar2
  , p_value              IN number
  , p_description        IN varchar2
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
    cursor c_cost
    is
      select *
      from csr_costs_vl
      where cost_id = p_cost_id
      for update nowait;

    l_rec c_cost%rowtype;

  begin
    open c_cost;
    fetch c_cost into l_rec;

    if c_cost%notfound
    then
      close c_cost;
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_cost;

    if l_rec.name <> rtrim(p_name)
    or l_rec.value <> p_value
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
    p_cost_id            IN number
  , p_name               IN varchar2
  , p_value              IN number
  , p_description        IN varchar2
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

    update csr_costs_all_b
    set name               = p_name
    ,   value              = p_value
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
    where cost_id = p_cost_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;

    update csr_costs_all_tl
    set description       = p_description
    ,   last_update_date  = p_last_update_date
    ,   last_updated_by   = p_last_updated_by
    ,   last_update_login = p_last_update_login
    ,   source_lang       = userenv('lang')
    where cost_id = p_cost_id
    and userenv('lang') in (language, source_lang);

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;
  end update_row;

  procedure delete_row
  (
    p_cost_id IN number
  )
  is
  begin
    delete from csr_costs_all_tl
    where cost_id = p_cost_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;

    delete from csr_costs_all_b
    where cost_id = p_cost_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;
  end delete_row;

  procedure add_language
  is
  begin
    delete from csr_costs_all_tl t
    where not exists
          ( select ''
            from csr_costs_all_b b
            where b.cost_id = t.cost_id );

    update csr_costs_all_tl t
    set description =
        ( select b.description
          from csr_costs_all_tl b
          where b.cost_id  = t.cost_id
          and   b.language = t.source_lang )
    where ( t.cost_id, t.language ) in
          ( select subt.cost_id
            ,      subt.language
            from csr_costs_all_tl subb
            ,    csr_costs_all_tl subt
            where subb.cost_id  = subt.cost_id
            and   subb.language = subt.source_lang
            and   ( subb.description <> subt.description
                 or ( subb.description is null
                  and subt.description is not null )
                 or ( subb.description is not null
                  and subt.description is null ) ) );

    insert into csr_costs_all_tl
    ( cost_id
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang
    )
    select b.cost_id
    ,      b.description
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    from csr_costs_all_tl b
    ,    fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   b.language = userenv('LANG')
    and not exists
        ( select null
          from csr_costs_all_tl t
          where t.cost_id  = b.cost_id
          and   t.language = l.language_code );
  end add_language;

  procedure translate_row
  (
    p_cost_id           IN varchar2
  , p_owner             IN varchar2
  , p_description       IN varchar2
  )
  is
  begin
    update CSR_COSTS_ALL_TL
    set description = p_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where cost_id = to_number(p_cost_id)
    and userenv('LANG') in (language, source_lang);
  end translate_row;

  procedure load_row
  (
    p_cost_id            IN varchar2
  , p_name               IN varchar2
  , p_value              IN varchar2
  , p_description        IN varchar2
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
    l_cost_id     number       := to_number(p_cost_id);
    l_update_date date         := sysdate;
    l_row_id      varchar2(64);
    l_user_id     number       := 0;
  begin
    if (p_owner = 'SEED')
    then
      l_user_id := 1;
    end if;

    update_row
    (
      p_cost_id           => l_cost_id
    , p_name              => p_name
    , p_value             => to_number(p_value)
    , p_description       => p_description
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
      , p_cost_id            => l_cost_id
      , p_name               => p_name
      , p_value              => to_number(p_value)
      , p_description        => p_description
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

end CSR_COSTS_PKG;

/
