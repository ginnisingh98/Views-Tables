--------------------------------------------------------
--  DDL for Package Body CSF_SKILLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_SKILLS_PKG" AS
/* $Header: CSFPSKLB.pls 120.1 2006/03/01 02:00:51 ipananil noship $ */

  -- ---------------------------------
  -- private global package variables
  -- ---------------------------------
  g_user_id  number;
  g_login_id number;

  -- ---------------------------------
  -- public API's
  -- ---------------------------------
  PROCEDURE load_skill_type
  ( p_skill_type_id         in number
  , p_rating_scale_id       in number
  , p_start_date_active     in date
  , p_end_date_active       in date
  , p_last_update_date      in date
  , p_seeded_flag           in varchar2
  , p_key_column            in varchar2
  , p_data_column           in varchar2
  , p_name_number_column    in varchar2
  , p_from_clause           in varchar2
  , p_where_clause          in varchar2
  , p_order_by_clause       in varchar2
  , p_object_version_number in number
  , p_attribute1            in varchar2
  , p_attribute2            in varchar2
  , p_attribute3            in varchar2
  , p_attribute4            in varchar2
  , p_attribute5            in varchar2
  , p_attribute6            in varchar2
  , p_attribute7            in varchar2
  , p_attribute8            in varchar2
  , p_attribute9            in varchar2
  , p_attribute10           in varchar2
  , p_attribute11           in varchar2
  , p_attribute12           in varchar2
  , p_attribute13           in varchar2
  , p_attribute14           in varchar2
  , p_attribute15           in varchar2
  , p_attribute_category    in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2 )
  IS
    cursor skillType_cur (b_skill_type_id number) is
      select skill_type_id, last_update_date
      from csf_skill_types_b
      where skill_type_id = b_skill_type_id;

    l_skill_type_id    number;
    l_last_update_date date;
    l_rowid            varchar2(100);
    l_obj_ver          number;
  BEGIN
    open skillType_cur ( p_skill_type_id );
    fetch skillType_cur into l_skill_type_id, l_last_update_date;
    if skillType_cur%NOTFOUND then
      l_skill_type_id := p_skill_type_id;
      create_skill_type( l_rowid
                       , l_skill_type_id
                       , p_rating_scale_id
                       , p_start_date_active
                       , p_end_date_active
                       , p_seeded_flag
                       , p_key_column
                       , p_data_column
                       , p_name_number_column
                       , p_from_clause
                       , p_where_clause
                       , p_order_by_clause
                       , l_obj_ver
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
                       , p_name
                       , p_description);
    else
      if p_last_update_date >= l_last_update_date then
        update csf_skill_types_b
        set rating_scale_id       = p_rating_scale_id
        ,   start_date_active     = p_start_date_active
        ,   end_date_active       = p_end_date_active
        ,   seeded_flag           = p_seeded_flag
        ,   object_version_number = object_version_number + 1
        ,   key_column            = p_key_column
        ,   data_column           = p_data_column
        ,   name_number_column    = p_name_number_column
        ,   from_clause           = p_from_clause
        ,   where_clause          = p_where_clause
        ,   order_by_clause       = p_order_by_clause
        ,   attribute1            = p_attribute1
        ,   attribute2            = p_attribute2
        ,   attribute3            = p_attribute3
        ,   attribute4            = p_attribute4
        ,   attribute5            = p_attribute5
        ,   attribute6            = p_attribute6
        ,   attribute7            = p_attribute7
        ,   attribute8            = p_attribute8
        ,   attribute9            = p_attribute9
        ,   attribute10           = p_attribute10
        ,   attribute11           = p_attribute11
        ,   attribute12           = p_attribute12
        ,   attribute13           = p_attribute13
        ,   attribute14           = p_attribute14
        ,   attribute15           = p_attribute15
        ,   attribute_category    = p_attribute_category
        ,   last_update_date      = p_last_update_date
        ,   last_updated_by       = g_user_id
        ,   last_update_login     = g_login_id
        where skill_type_id = l_skill_type_id;

        update csf_skill_types_tl
        set name              = p_name
        ,   description       = p_description
        ,   last_update_date  = p_last_update_date
        ,   last_updated_by   = g_user_id
        ,   last_update_login = g_login_id
        ,   source_lang       = userenv('LANG')
        where skill_type_id = l_skill_type_id
        and   userenv('LANG') in (language, source_lang);
      end if;
    end if;
    close skillType_cur;
  END load_skill_type;


  PROCEDURE create_skill_type
  ( x_rowid                 in out nocopy varchar2
  , x_skill_type_id         in out nocopy number
  , x_rating_scale_id       in number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_key_column            in varchar2 default null
  , x_data_column           in varchar2 default null
  , x_name_number_column    in varchar2 default null
  , x_from_clause           in varchar2 default null
  , x_where_clause          in varchar2 default null
  , x_order_by_clause       in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_rowid
    is
      select rowid
      from csf_skill_types_b
      where skill_type_id = x_skill_type_id;

    -- cursor to check for duplicate skill type
    cursor c_dup_task_type is
      select 1
        from csf_skill_types_tl a, csf_skill_types_b b
       where a.skill_type_id = b.skill_type_id
         and upper (rtrim (ltrim (name))) = upper (rtrim (ltrim (x_name)))
         and language = userenv ('lang');

    l_dummy_var	number;


    l_key_column         varchar2(200);
    l_data_column        varchar2(2000);
    l_name_number_column varchar2(200);
    l_from_clause        varchar2(2000);
    l_where_clause       varchar2(2000);
    l_order_by_clause    varchar2(200);

  BEGIN
    if x_skill_type_id is null
    then
      select csf_skill_types_b_s1.nextval
      into x_skill_type_id
      from dual;
    else
      -- Checks if record to be inserted already exists.
      -- If it does, do nothing (RETURN), else, continue.
      open c_rowid;
      fetch c_rowid into x_rowid;
      if c_rowid%found
      then
        close c_rowid;
        return;
      end if;
      close c_rowid;
    end if;

    -- check for duplicate skill type
    open c_dup_task_type;
    fetch c_dup_task_type into l_dummy_var;

    if l_dummy_var is not null then
      close c_dup_task_type;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_SKILLTYPE');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_dup_task_type;

    if x_object_version_number is null
    then
      x_object_version_number := 1;
    end if;

    if x_key_column is null
    then
      l_key_column := 'skill_id';
    else
      l_key_column := x_key_column;
    end if;

    if x_data_column is null
    then
      l_data_column := 'skill_id id, description';
    else
      l_data_column := x_data_column;
    end if;

    if x_name_number_column is null
    then
      l_name_number_column := 'name';
    else
      l_name_number_column := x_name_number_column;
    end if;

    if x_from_clause is null
    then
      l_from_clause := 'csf_skills_vl';
    else
      l_from_clause := x_from_clause;
    end if;

    if x_where_clause is null
    then
      l_where_clause :=
      'sysdate >= trunc(start_date_active) '||
      'and (sysdate <= trunc(end_date_active)+1 or end_date_active is null) '||
      'and skill_type_id = to_number('||to_char(x_skill_type_id)||')';
    else
      l_where_clause := x_where_clause;
    end if;

    if x_order_by_clause is null
    then
      l_order_by_clause := 'name';
    else
      l_order_by_clause := x_order_by_clause;
    end if;

    insert into csf_skill_types_b
    ( skill_type_id
    , rating_scale_id
    , start_date_active
    , end_date_active
    , seeded_flag
    , key_column
    , data_column
    , name_number_column
    , from_clause
    , where_clause
    , order_by_clause
    , object_version_number
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
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login )
    values
    ( x_skill_type_id
    , x_rating_scale_id
    , x_start_date_active
    , x_end_date_active
    , nvl(x_seeded_flag, 'N')
    , l_key_column
    , l_data_column
    , l_name_number_column
    , l_from_clause
    , l_where_clause
    , l_order_by_clause
    , x_object_version_number
    , x_attribute1
    , x_attribute2
    , x_attribute3
    , x_attribute4
    , x_attribute5
    , x_attribute6
    , x_attribute7
    , x_attribute8
    , x_attribute9
    , x_attribute10
    , x_attribute11
    , x_attribute12
    , x_attribute13
    , x_attribute14
    , x_attribute15
    , x_attribute_category
    , sysdate
    , fnd_global.user_id
    , sysdate
    , g_user_id
    , g_login_id );

    insert into csf_skill_types_tl
    ( skill_type_id
    , name
    , description
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , language
    , source_lang )
    select x_skill_type_id
    ,      x_name
    ,      x_description
    ,      sysdate
    ,      g_user_id
    ,      sysdate
    ,      g_user_id
    ,      g_login_id
    ,      l.language_code
    ,      userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   not exists
          ( select null
            from csf_skill_types_tl t
            where t.skill_type_id = x_skill_type_id
            and   t.language = l.language_code );

    open c_rowid;
    fetch c_rowid into x_rowid;
    if c_rowid%notfound
    then
      close c_rowid;
      raise no_data_found;
    end if;
    close c_rowid;
  END create_skill_type;

  PROCEDURE lock_skill_type
  ( x_skill_type_id         in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_skill_types_b
      where skill_type_id = x_skill_type_id
      for update of skill_type_id nowait;

    l_rec c_ovn%rowtype;

    cursor c_tl
    is
      select name
      ,      description
      ,      decode(language, userenv('LANG'), 'Y', 'N') baselang
      from csf_skill_types_tl
      where skill_type_id = x_skill_type_id
      and   userenv('LANG') in (language, source_lang)
      for update of skill_type_id nowait;

  BEGIN
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = x_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

    for i in c_tl
    loop
      if i.baselang = 'Y'
      then
        if i.name = x_name
        and ( i.description = x_description
           or ( i.description is null and x_description is null ) )
        then
          null;
        else
          fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
          app_exception.raise_exception;
        end if;
      end if;
    end loop;
  END lock_skill_type;

  PROCEDURE update_skill_type
  ( x_skill_type_id      in number
  , x_object_version_number in out nocopy number
  , x_rating_scale_id    in number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_seeded_flag        in varchar2 default null
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 )
  IS
    -- cursor to check for duplicate skill type
    cursor c_dup_task_type is
    select 1
      from csf_skill_types_tl a, csf_skill_types_b b
     where a.skill_type_id = b.skill_type_id
       and upper (rtrim (ltrim (name))) = upper (rtrim (ltrim (x_name)))
       and language = userenv ('lang')
       and a.skill_type_id <> x_skill_type_id;

    l_dummy_var	number;
    l_ovn number;
  BEGIN
    -- check for duplicate skill type
    open c_dup_task_type;
    fetch c_dup_task_type into l_dummy_var;

    if l_dummy_var is not null then
      close c_dup_task_type;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_SKILLTYPE');
      raise_application_error(-20110, fnd_message.get);
    end if;

    close c_dup_task_type;

    update csf_skill_types_b
    set rating_scale_id       = x_rating_scale_id
    ,   start_date_active     = x_start_date_active
    ,   end_date_active       = x_end_date_active
    ,   seeded_flag           = nvl(x_seeded_flag, 'N')
    ,   object_version_number = object_version_number + 1
    ,   attribute1            = x_attribute1
    ,   attribute2            = x_attribute2
    ,   attribute3            = x_attribute3
    ,   attribute4            = x_attribute4
    ,   attribute5            = x_attribute5
    ,   attribute6            = x_attribute6
    ,   attribute7            = x_attribute7
    ,   attribute8            = x_attribute8
    ,   attribute9            = x_attribute9
    ,   attribute10           = x_attribute10
    ,   attribute11           = x_attribute11
    ,   attribute12           = x_attribute12
    ,   attribute13           = x_attribute13
    ,   attribute14           = x_attribute14
    ,   attribute15           = x_attribute15
    ,   attribute_category    = x_attribute_category
    ,   last_update_date      = sysdate
    ,   last_updated_by       = g_user_id
    ,   last_update_login     = g_login_id
    where skill_type_id = x_skill_type_id
    returning object_version_number into l_ovn;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    update csf_skill_types_tl
    set name              = x_name
    ,   description       = x_description
    ,   last_update_date  = sysdate
    ,   last_updated_by   = g_user_id
    ,   last_update_login = g_login_id
    ,   source_lang       = userenv('LANG')
    where skill_type_id = x_skill_type_id
    and   userenv('LANG') in (language, source_lang);

    if sql%notfound
    then
      raise no_data_found;
    end if;
    x_object_version_number := l_ovn;
  END update_skill_type;

  PROCEDURE delete_skill_type ( x_skill_type_id in number )
  IS
  BEGIN
    delete from csf_skill_types_tl
    where skill_type_id = x_skill_type_id;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    delete from csf_skill_types_b
    where skill_type_id = x_skill_type_id;

    if sql%notfound then
      raise no_data_found;
    end if;
  END delete_skill_type;

  PROCEDURE add_skill_type_language
  IS
  BEGIN
    delete from csf_skill_types_tl t
    where not exists
          ( select null
            from csf_skill_types_b b
            where b.skill_type_id = t.skill_type_id );

    update csf_skill_types_tl t
    set ( name, description ) = ( select b.name
                                  ,      b.description
                                  from csf_skill_types_tl b
                                  where b.skill_type_id = t.skill_type_id
                                  and   b.language = t.source_lang )
    where ( t.skill_type_id, t.language ) in
          ( select subt.skill_type_id
            ,      subt.language
            from csf_skill_types_tl subb
            ,    csf_skill_types_tl subt
            where subb.skill_type_id = subt.skill_type_id
            and   subb.language = subt.source_lang
            and ( subb.name <> subt.name
               or subb.description <> subt.description
               or (subb.description is null and subt.description is not null)
               or (subb.description is not null and subt.description is null)));

    insert into csf_skill_types_tl
    ( skill_type_id
    , name
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang )
    select b.skill_type_id
    ,      b.name
    ,      b.description
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    from csf_skill_types_tl b
    ,    fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   b.language = userenv('LANG')
    and not exists
        ( select null
          from csf_skill_types_tl t
          where t.skill_type_id = b.skill_type_id
          and t.language = l.language_code );
  END add_skill_type_language;

  PROCEDURE create_skill
  ( x_rowid                 in out nocopy varchar2
  , x_skill_id              in out nocopy number
  , x_skill_type_id         in number
  , x_skill_alias           in varchar2
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_rowid
    is
      select rowid
      from csf_skills_b
      where skill_id = x_skill_id;

    -- cursor to check for duplicate skills
    cursor c_dup_skill_type is
    select 1
      from csf_skills_b a, csf_skills_tl b
     where a.skill_id = b.skill_id
       and upper (rtrim (ltrim (name))) = upper (rtrim (ltrim (x_name)))
       and skill_type_id = x_skill_type_id
       and language = userenv ('lang');

    l_dummy_var	number;
  BEGIN
    if x_skill_id is null
    then
      select csf_skills_b_s1.nextval
      into x_skill_id
      from dual;
    else
      -- Checks if record to be inserted already exists.
      -- If it does, do nothing (RETURN), else, continue.
      open c_rowid;
      fetch c_rowid into x_rowid;
      if c_rowid%found
      then
        close c_rowid;
        return;
      end if;
      close c_rowid;
    end if;

    -- check for duplicate skills
    open c_dup_skill_type;
    fetch c_dup_skill_type into l_dummy_var;

    if l_dummy_var is not null then
      close c_dup_skill_type;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_SKILL');
      raise_application_error(-20110, fnd_message.get);
    end if;

    close c_dup_skill_type;

    if x_object_version_number is null
    then
      x_object_version_number := 1;
    end if;

    insert into csf_skills_b
    ( skill_id
    , skill_type_id
    , skill_alias
    , start_date_active
    , end_date_active
    , seeded_flag
    , object_version_number
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
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login )
    values
    ( x_skill_id
    , x_skill_type_id
    , x_skill_alias
    , x_start_date_active
    , x_end_date_active
    , nvl(x_seeded_flag, 'N')
    , x_object_version_number
    , x_attribute1
    , x_attribute2
    , x_attribute3
    , x_attribute4
    , x_attribute5
    , x_attribute6
    , x_attribute7
    , x_attribute8
    , x_attribute9
    , x_attribute10
    , x_attribute11
    , x_attribute12
    , x_attribute13
    , x_attribute14
    , x_attribute15
    , x_attribute_category
    , sysdate
    , fnd_global.user_id
    , sysdate
    , g_user_id
    , g_login_id );

    insert into csf_skills_tl
    ( skill_id
    , name
    , description
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , language
    , source_lang )
    select x_skill_id
    ,      x_name
    ,      x_description
    ,      sysdate
    ,      g_user_id
    ,      sysdate
    ,      g_user_id
    ,      g_login_id
    ,      l.language_code
    ,      userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   not exists
          ( select null
            from csf_skills_tl t
            where t.skill_id = x_skill_id
            and   t.language = l.language_code );

    open c_rowid;
    fetch c_rowid into x_rowid;
    if c_rowid%notfound
    then
      close c_rowid;
      raise no_data_found;
    end if;
    close c_rowid;
  END create_skill;

  PROCEDURE lock_skill
  ( x_skill_id              in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_skills_b
      where skill_id = x_skill_id
      for update of skill_id nowait;

    l_rec c_ovn%rowtype;

    cursor c_tl
    is
      select name
      ,      description
      ,      decode(language, userenv('LANG'), 'Y', 'N') baselang
      from csf_skills_tl
      where skill_id = x_skill_id
      and   userenv('LANG') in (language, source_lang)
      for update of skill_id nowait;

  BEGIN
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = x_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

    for i in c_tl
    loop
      if i.baselang = 'Y'
      then
        if i.name = x_name
        and ( i.description = x_description
           or ( i.description is null and x_description is null ) )
        then
          null;
        else
          fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
          app_exception.raise_exception;
        end if;
      end if;
    end loop;
  END lock_skill;

  PROCEDURE update_skill
  ( x_skill_id           in number
  , x_object_version_number in out nocopy number
  , x_skill_type_id      in number
  , x_skill_alias        in varchar2
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 )
  IS
    -- cursor to check for duplicate skills
    cursor c_dup_skill_type is
    select 1
      from csf_skills_b a, csf_skills_tl b
     where a.skill_id = b.skill_id
       and upper (rtrim (ltrim (name))) = upper (rtrim (ltrim (x_name)))
       and skill_type_id = x_skill_type_id
       and a.skill_id <> x_skill_id
       and language = userenv ('lang');

    l_dummy_var	number;
    l_ovn number;
  BEGIN
    -- check for duplicate skills
    open c_dup_skill_type;
    fetch c_dup_skill_type into l_dummy_var;

    if l_dummy_var is not null then
      close c_dup_skill_type;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_SKILL');
      raise_application_error(-20110, fnd_message.get);
    end if;

    close c_dup_skill_type;

    update csf_skills_b
    set skill_type_id         = x_skill_type_id
    ,   skill_alias           = x_skill_alias
    ,   start_date_active     = x_start_date_active
    ,   end_date_active       = x_end_date_active
    ,   object_version_number = object_version_number + 1
    ,   attribute1            = x_attribute1
    ,   attribute2            = x_attribute2
    ,   attribute3            = x_attribute3
    ,   attribute4            = x_attribute4
    ,   attribute5            = x_attribute5
    ,   attribute6            = x_attribute6
    ,   attribute7            = x_attribute7
    ,   attribute8            = x_attribute8
    ,   attribute9            = x_attribute9
    ,   attribute10           = x_attribute10
    ,   attribute11           = x_attribute11
    ,   attribute12           = x_attribute12
    ,   attribute13           = x_attribute13
    ,   attribute14           = x_attribute14
    ,   attribute15           = x_attribute15
    ,   attribute_category    = x_attribute_category
    ,   last_update_date      = sysdate
    ,   last_updated_by       = g_user_id
    ,   last_update_login     = g_login_id
    where skill_id = x_skill_id
    returning object_version_number into l_ovn;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    update csf_skills_tl
    set name              = x_name
    ,   description       = x_description
    ,   last_update_date  = sysdate
    ,   last_updated_by   = g_user_id
    ,   last_update_login = g_login_id
    ,   source_lang       = userenv('LANG')
    where skill_id = x_skill_id
    and   userenv('LANG') in (language, source_lang);

    if sql%notfound
    then
      raise no_data_found;
    end if;
    x_object_version_number := l_ovn;
  END update_skill;

  PROCEDURE delete_skill ( x_skill_id in number )
  IS
  BEGIN
    delete from csf_skills_tl
    where skill_id = x_skill_id;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    delete from csf_skills_b
    where skill_id = x_skill_id;

    if sql%notfound then
      raise no_data_found;
    end if;
  END delete_skill;

  PROCEDURE add_skill_language
  IS
  BEGIN
    delete from csf_skills_tl t
    where not exists
          ( select null
            from csf_skills_b b
            where b.skill_id = t.skill_id );

    update csf_skills_tl t
    set ( name
        , description ) = ( select b.name
                            ,      b.description
                            from csf_skills_tl b
                            where b.skill_id = t.skill_id
                            and   b.language = t.source_lang )
    where ( t.skill_id, t.language ) in
          ( select subt.skill_id
            ,      subt.language
            from csf_skills_tl subb
            ,    csf_skills_tl subt
            where subb.skill_id = subt.skill_id
            and   subb.language = subt.source_lang
            and ( subb.name <> subt.name
               or subb.description <> subt.description
               or (subb.description is null and subt.description is not null)
               or (subb.description is not null and subt.description is null)));

    insert into csf_skills_tl
    ( skill_id
    , name
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang )
    select b.skill_id
    ,      b.name
    ,      b.description
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    from csf_skills_tl b
    ,    fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   b.language = userenv('LANG')
    and not exists
        ( select null
          from csf_skills_tl t
          where t.skill_id = b.skill_id
          and t.language = l.language_code );
  END add_skill_language;

  PROCEDURE create_rating_scale
  ( x_rowid                 in out nocopy varchar2
  , x_rating_scale_id       in out nocopy number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_rowid
    is
      select rowid
      from csf_rating_scales_b
      where rating_scale_id = x_rating_scale_id;

    -- cursor to check for duplicate scale names
    cursor c_dup_scale_type is
    select 1
      from csf_rating_scales_tl a, csf_rating_scales_b b
     where a.rating_scale_id = b.rating_scale_id
       and upper (rtrim (ltrim (name))) = upper (rtrim (ltrim (x_name)))
       and language = userenv ('lang');

    l_dummy_var number;
  BEGIN
    if x_rating_scale_id is null
    then
      select csf_rating_scales_b_s1.nextval
      into x_rating_scale_id
      from dual;
    else
      -- Checks if record to be inserted already exists.
      -- If it does, do nothing (RETURN), else, continue.
      open c_rowid;
      fetch c_rowid into x_rowid;
      if c_rowid%found
      then
        close c_rowid;
        return;
      end if;
      close c_rowid;
    end if;

    -- check whether Scale name entered already exists
    open c_dup_scale_type;
    fetch c_dup_scale_type into l_dummy_var;

    if l_dummy_var is not null then
      close c_dup_scale_type;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_SCALE');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_dup_scale_type;

    if x_object_version_number is null
    then
      x_object_version_number := 1;
    end if;

    insert into csf_rating_scales_b
    ( rating_scale_id
    , start_date_active
    , end_date_active
    , seeded_flag
    , object_version_number
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
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login )
    values
    ( x_rating_scale_id
    , x_start_date_active
    , x_end_date_active
    , nvl(x_seeded_flag, 'N')
    , x_object_version_number
    , x_attribute1
    , x_attribute2
    , x_attribute3
    , x_attribute4
    , x_attribute5
    , x_attribute6
    , x_attribute7
    , x_attribute8
    , x_attribute9
    , x_attribute10
    , x_attribute11
    , x_attribute12
    , x_attribute13
    , x_attribute14
    , x_attribute15
    , x_attribute_category
    , sysdate
    , fnd_global.user_id
    , sysdate
    , g_user_id
    , g_login_id );

    insert into csf_rating_scales_tl
    ( rating_scale_id
    , name
    , description
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , language
    , source_lang )
    select x_rating_scale_id
    ,      x_name
    ,      x_description
    ,      sysdate
    ,      g_user_id
    ,      sysdate
    ,      g_user_id
    ,      g_login_id
    ,      l.language_code
    ,      userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   not exists
          ( select null
            from csf_rating_scales_tl t
            where t.rating_scale_id = x_rating_scale_id
            and   t.language = l.language_code );

    open c_rowid;
    fetch c_rowid into x_rowid;
    if c_rowid%notfound
    then
      close c_rowid;
      raise no_data_found;
    end if;
    close c_rowid;
  END create_rating_scale;

  PROCEDURE lock_rating_scale
  ( x_rating_scale_id       in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_rating_scales_b
      where rating_scale_id = x_rating_scale_id
      for update of rating_scale_id nowait;

    l_rec c_ovn%rowtype;

    cursor c_tl
    is
      select name
      ,      description
      ,      decode(language, userenv('LANG'), 'Y', 'N') baselang
      from csf_rating_scales_tl
      where rating_scale_id = x_rating_scale_id
      and   userenv('LANG') in (language, source_lang)
      for update of rating_scale_id nowait;

  BEGIN
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = x_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

    for i in c_tl
    loop
      if i.baselang = 'Y'
      then
        if i.name = x_name
        and ( i.description = x_description
           or ( i.description is null and x_description is null ) )
        then
          null;
        else
          fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
          app_exception.raise_exception;
        end if;
      end if;
    end loop;
  END lock_rating_scale;

  PROCEDURE update_rating_scale
  ( x_rating_scale_id    in number
  , x_object_version_number in out nocopy number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_seeded_flag        in varchar2 default null
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 )
  IS
    -- cursor to check for duplicate scale names
    cursor c_dup_scale_type is
    select 1
      from csf_rating_scales_tl a, csf_rating_scales_b b
     where a.rating_scale_id = b.rating_scale_id
       and upper (rtrim (ltrim (name))) = upper (rtrim (ltrim (x_name)))
       and language = userenv ('lang')
       and b.rating_scale_id <> x_rating_scale_id;

    l_dummy_var number;
    l_ovn number;
  BEGIN
    -- check whether Scale name entered already exists
    open c_dup_scale_type;
    fetch c_dup_scale_type into l_dummy_var;

    if l_dummy_var is not null then
      close c_dup_scale_type;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_SCALE');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_dup_scale_type;

    update csf_rating_scales_b
    set start_date_active     = x_start_date_active
    ,   end_date_active       = x_end_date_active
    ,   seeded_flag           = nvl(x_seeded_flag, 'N')
    ,   object_version_number = object_version_number + 1
    ,   attribute1            = x_attribute1
    ,   attribute2            = x_attribute2
    ,   attribute3            = x_attribute3
    ,   attribute4            = x_attribute4
    ,   attribute5            = x_attribute5
    ,   attribute6            = x_attribute6
    ,   attribute7            = x_attribute7
    ,   attribute8            = x_attribute8
    ,   attribute9            = x_attribute9
    ,   attribute10           = x_attribute10
    ,   attribute11           = x_attribute11
    ,   attribute12           = x_attribute12
    ,   attribute13           = x_attribute13
    ,   attribute14           = x_attribute14
    ,   attribute15           = x_attribute15
    ,   attribute_category    = x_attribute_category
    ,   last_update_date      = sysdate
    ,   last_updated_by       = g_user_id
    ,   last_update_login     = g_login_id
    where rating_scale_id = x_rating_scale_id
    returning object_version_number into l_ovn;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    update csf_rating_scales_tl
    set name              = x_name
    ,   description       = x_description
    ,   last_update_date  = sysdate
    ,   last_updated_by   = g_user_id
    ,   last_update_login = g_login_id
    ,   source_lang       = userenv('LANG')
    where rating_scale_id = x_rating_scale_id
    and   userenv('LANG') in (language, source_lang);

    if sql%notfound
    then
      raise no_data_found;
    end if;
    x_object_version_number := l_ovn;
  END update_rating_scale;

  PROCEDURE delete_rating_scale ( x_rating_scale_id in number )
  IS
  BEGIN
    delete from csf_rating_scales_tl
    where rating_scale_id = x_rating_scale_id;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    delete from csf_rating_scales_b
    where rating_scale_id = x_rating_scale_id;

    if sql%notfound then
      raise no_data_found;
    end if;
  END delete_rating_scale;

  PROCEDURE add_rating_scale_language
  IS
  BEGIN
    delete from csf_rating_scales_tl t
    where not exists
          ( select null
            from csf_rating_scales_b b
            where b.rating_scale_id = t.rating_scale_id );

    update csf_rating_scales_tl t
    set ( name
        , description ) = ( select b.name
                            ,      b.description
                            from csf_rating_scales_tl b
                            where b.rating_scale_id = t.rating_scale_id
                            and   b.language = t.source_lang )
    where ( t.rating_scale_id, t.language ) in
          ( select subt.rating_scale_id
            ,      subt.language
            from csf_rating_scales_tl subb
            ,    csf_rating_scales_tl subt
            where subb.rating_scale_id = subt.rating_scale_id
            and   subb.language = subt.source_lang
            and ( subb.name <> subt.name
               or subb.description <> subt.description
               or (subb.description is null and subt.description is not null)
               or (subb.description is not null and subt.description is null)));

    insert into csf_rating_scales_tl
    ( rating_scale_id
    , name
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang )
    select b.rating_scale_id
    ,      b.name
    ,      b.description
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    from csf_rating_scales_tl b
    ,    fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   b.language = userenv('LANG')
    and not exists
        ( select null
          from csf_rating_scales_tl t
          where t.rating_scale_id = b.rating_scale_id
          and t.language = l.language_code );
  END add_rating_scale_language;

  PROCEDURE create_skill_level
  ( x_rowid                 in out nocopy varchar2
  , x_skill_level_id        in out nocopy number
  , x_rating_scale_id       in number
  , x_step_value            in number
  , x_correction_factor     in number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_rowid
    is
      select rowid
      from csf_skill_levels_b
      where skill_level_id = x_skill_level_id;

    -- cursor to check for duplicate level name
    cursor c_dup_name is
      select 1
        from csf_skill_levels_b a, csf_skill_levels_tl b
       where a.skill_level_id = b.skill_level_id
         and (upper (rtrim (ltrim (b.name))) = upper (rtrim (ltrim (x_name)))
             )
         and a.rating_scale_id = x_rating_scale_id
         and b.language = userenv ('LANG');

    -- cursor to check for duplicate level order
    cursor c_dup_order is
      select 1
        from csf_skill_levels_b a, csf_skill_levels_tl b
       where a.skill_level_id = b.skill_level_id
         and a.step_value in (
               select c.step_value
                 from csf_skill_levels_b c
                where c.skill_level_id = a.skill_level_id
                  and rating_scale_id = x_rating_scale_id
                  and c.step_value = x_step_value)
         and a.rating_scale_id = x_rating_scale_id
         and b.language = userenv ('LANG');

    l_dummy_var number;
  BEGIN
    if x_skill_level_id is null
    then
      select csf_skill_levels_b_s1.nextval
      into x_skill_level_id
      from dual;
    else
      -- Checks if record to be inserted already exists.
      -- If it does, do nothing (RETURN), else, continue.
      open c_rowid;
      fetch c_rowid into x_rowid;
      if c_rowid%found
      then
        close c_rowid;
        return;
      end if;
      close c_rowid;
    end if;

    -- for bug 3799295
    -- check for duplicate level order
    open c_dup_order;
    fetch c_dup_order into l_dummy_var;

    if l_dummy_var is not null then
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_ORDER');
      raise_application_error(-20120,fnd_message.get);
    end if;

    close c_dup_order;

    -- check for duplicate level name
    open c_dup_name;
    fetch c_dup_name into l_dummy_var;

    if l_dummy_var is not null then
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_LEVEL');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_dup_name;

    if x_object_version_number is null
    then
      x_object_version_number := 1;
    end if;

    insert into csf_skill_levels_b
    ( skill_level_id
    , rating_scale_id
    , step_value
    , correction_factor
    , start_date_active
    , end_date_active
    , seeded_flag
    , object_version_number
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
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login )
    values
    ( x_skill_level_id
    , x_rating_scale_id
    , x_step_value
    , x_correction_factor
    , x_start_date_active
    , x_end_date_active
    , nvl(x_seeded_flag, 'N')
    , x_object_version_number
    , x_attribute1
    , x_attribute2
    , x_attribute3
    , x_attribute4
    , x_attribute5
    , x_attribute6
    , x_attribute7
    , x_attribute8
    , x_attribute9
    , x_attribute10
    , x_attribute11
    , x_attribute12
    , x_attribute13
    , x_attribute14
    , x_attribute15
    , x_attribute_category
    , sysdate
    , fnd_global.user_id
    , sysdate
    , g_user_id
    , g_login_id );

    insert into csf_skill_levels_tl
    ( skill_level_id
    , name
    , description
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , language
    , source_lang )
    select x_skill_level_id
    ,      x_name
    ,      x_description
    ,      sysdate
    ,      g_user_id
    ,      sysdate
    ,      g_user_id
    ,      g_login_id
    ,      l.language_code
    ,      userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   not exists
          ( select null
            from csf_skill_levels_tl t
            where t.skill_level_id = x_skill_level_id
            and   t.language = l.language_code );

    open c_rowid;
    fetch c_rowid into x_rowid;
    if c_rowid%notfound
    then
      close c_rowid;
      raise no_data_found;
    end if;
    close c_rowid;
  END create_skill_level;

  PROCEDURE lock_skill_level
  ( x_skill_level_id        in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 )
  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_skill_levels_b
      where skill_level_id = x_skill_level_id
      for update of skill_level_id nowait;

    l_rec c_ovn%rowtype;

    cursor c_tl
    is
      select name
      ,      description
      ,      decode(language, userenv('LANG'), 'Y', 'N') baselang
      from csf_skill_levels_tl
      where skill_level_id = x_skill_level_id
      and   userenv('LANG') in (language, source_lang)
      for update of skill_level_id nowait;

  BEGIN
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = x_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

    for i in c_tl
    loop
      if i.baselang = 'Y'
      then
        if i.name = x_name
        and ( i.description = x_description
           or ( i.description is null and x_description is null ) )
        then
          null;
        else
          fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
          app_exception.raise_exception;
        end if;
      end if;
    end loop;
  END lock_skill_level;

  PROCEDURE update_skill_level
  ( x_skill_level_id     in number
  , x_object_version_number in out nocopy number
  , x_rating_scale_id    in number
  , x_step_value         in number
  , x_correction_factor  in number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_seeded_flag        in varchar2 default null
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 )
  IS
    -- cursor to check for duplicate level name
    cursor c_dup_name is
      select 1
        from csf_skill_levels_b a, csf_skill_levels_tl b
       where a.skill_level_id = b.skill_level_id
         and (upper (rtrim (ltrim (b.name))) = upper (rtrim (ltrim (x_name)))
             )
         and a.rating_scale_id = x_rating_scale_id
         and b.language = userenv ('LANG')
         and a.skill_level_id <> x_skill_level_id;

    -- cursor to check for duplicate level order
    cursor c_dup_order is
      select 1
        from csf_skill_levels_b a, csf_skill_levels_tl b
       where a.skill_level_id = b.skill_level_id
         and a.step_value in (
               select c.step_value
                 from csf_skill_levels_b c
                where c.skill_level_id = a.skill_level_id
                  and rating_scale_id = x_rating_scale_id
                  and c.step_value = x_step_value)
         and a.rating_scale_id = x_rating_scale_id
         and b.language = userenv ('LANG')
         and a.skill_level_id <> x_skill_level_id;

    l_dummy_var number;
    l_ovn number;
  BEGIN
    -- for bug 3799295
    -- duplicate checking for the level order
    open c_dup_order;
    fetch c_dup_order into l_dummy_var;

    if l_dummy_var is not null then
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_ORDER');
      raise_application_error(-20120,fnd_message.get);
    end if;

    close c_dup_order;

    -- duplicate checking for the level name
    open c_dup_name;
    fetch c_dup_name into l_dummy_var;

    if l_dummy_var is not null then
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_LEVEL');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_dup_name;

    update csf_skill_levels_b
    set rating_scale_id       = x_rating_scale_id
    ,   step_value            = x_step_value
    ,   correction_factor     = x_correction_factor
    ,   start_date_active     = x_start_date_active
    ,   end_date_active       = x_end_date_active
    ,   seeded_flag           = nvl(x_seeded_flag, 'N')
    ,   object_version_number = object_version_number + 1
    ,   attribute1            = x_attribute1
    ,   attribute2            = x_attribute2
    ,   attribute3            = x_attribute3
    ,   attribute4            = x_attribute4
    ,   attribute5            = x_attribute5
    ,   attribute6            = x_attribute6
    ,   attribute7            = x_attribute7
    ,   attribute8            = x_attribute8
    ,   attribute9            = x_attribute9
    ,   attribute10           = x_attribute10
    ,   attribute11           = x_attribute11
    ,   attribute12           = x_attribute12
    ,   attribute13           = x_attribute13
    ,   attribute14           = x_attribute14
    ,   attribute15           = x_attribute15
    ,   attribute_category    = x_attribute_category
    ,   last_update_date      = sysdate
    ,   last_updated_by       = g_user_id
    ,   last_update_login     = g_login_id
    where skill_level_id = x_skill_level_id
    returning object_version_number into l_ovn;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    update csf_skill_levels_tl
    set name              = x_name
    ,   description       = x_description
    ,   last_update_date  = sysdate
    ,   last_updated_by   = g_user_id
    ,   last_update_login = g_login_id
    ,   source_lang       = userenv('LANG')
    where skill_level_id = x_skill_level_id
    and   userenv('LANG') in (language, source_lang);

    if sql%notfound
    then
      raise no_data_found;
    end if;
    x_object_version_number := l_ovn;
  END update_skill_level;

  PROCEDURE delete_skill_level ( x_skill_level_id in number )
  IS
  BEGIN
    delete from csf_skill_levels_tl
    where skill_level_id = x_skill_level_id;

    if sql%notfound
    then
      raise no_data_found;
    end if;

    delete from csf_skill_levels_b
    where skill_level_id = x_skill_level_id;

    if sql%notfound then
      raise no_data_found;
    end if;
  END delete_skill_level;

  PROCEDURE add_skill_level_language
  IS
  BEGIN
    delete from csf_skill_levels_tl t
    where not exists
          ( select null
            from csf_skill_levels_b b
            where b.skill_level_id = t.skill_level_id );

    update csf_skill_levels_tl t
    set ( name
        , description ) = ( select b.name
                            ,      b.description
                            from csf_skill_levels_tl b
                            where b.skill_level_id = t.skill_level_id
                            and   b.language = t.source_lang )
    where ( t.skill_level_id, t.language ) in
          ( select subt.skill_level_id
            ,      subt.language
            from csf_skill_levels_tl subb
            ,    csf_skill_levels_tl subt
            where subb.skill_level_id = subt.skill_level_id
            and   subb.language = subt.source_lang
            and ( subb.name <> subt.name
               or subb.description <> subt.description
               or (subb.description is null and subt.description is not null)
               or (subb.description is not null and subt.description is null)));

    insert into csf_skill_levels_tl
    ( skill_level_id
    , name
    , description
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , language
    , source_lang )
    select b.skill_level_id
    ,      b.name
    ,      b.description
    ,      b.created_by
    ,      b.creation_date
    ,      b.last_updated_by
    ,      b.last_update_date
    ,      b.last_update_login
    ,      l.language_code
    ,      b.source_lang
    from csf_skill_levels_tl b
    ,    fnd_languages l
    where l.installed_flag in ('I', 'B')
    and   b.language = userenv('LANG')
    and not exists
        ( select null
          from csf_skill_levels_tl t
          where t.skill_level_id = b.skill_level_id
          and t.language = l.language_code );
  END add_skill_level_language;

  PROCEDURE create_resource_skill
  ( x_rowid                 in out nocopy varchar2
  , x_resource_skill_id     in out nocopy number
  , x_skill_type_id         in number
  , x_skill_id              in number
  , x_resource_type         in varchar2
  , x_resource_id           in number
  , x_skill_level_id        in number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null )
  IS
    cursor c_rowid
    is
      select rowid
      from csf_resource_skills_b
      where resource_skill_id = x_resource_skill_id;

    -- cursor to check for duplicate skills assigned to a resource
    cursor c_resSkill is
    select 1
      from csf_resource_skills_b
     where resource_id = x_resource_id
       and skill_id = x_skill_id
       and resource_type = x_resource_type
       and skill_type_id = x_skill_type_id;

    l_dummy_var number;
  BEGIN
    if x_resource_skill_id is null
    then
      select csf_resource_skills_b_s1.nextval
      into x_resource_skill_id
      from dual;
    else
      -- Checks if record to be inserted already exists.
      -- If it does, do nothing (RETURN), else, continue.
      open c_rowid;
      fetch c_rowid into x_rowid;
      if c_rowid%found
      then
        close c_rowid;
        return;
      end if;
      close c_rowid;
    end if;

    -- check for duplicte skills assigned to a resource
    open c_resSkill;
    fetch c_resSkill into l_dummy_var;

    if l_dummy_var is not null then
      close c_resSkill;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_RES_SKILL');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_resSkill;

    if x_object_version_number is null
    then
      x_object_version_number := 1;
    end if;

    insert into csf_resource_skills_b
    ( resource_skill_id
    , skill_type_id
    , skill_id
    , resource_type
    , resource_id
    , skill_level_id
    , start_date_active
    , end_date_active
    , object_version_number
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
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login )
    values
    ( x_resource_skill_id
    , x_skill_type_id
    , x_skill_id
    , x_resource_type
    , x_resource_id
    , x_skill_level_id
    , x_start_date_active
    , x_end_date_active
    , x_object_version_number
    , x_attribute1
    , x_attribute2
    , x_attribute3
    , x_attribute4
    , x_attribute5
    , x_attribute6
    , x_attribute7
    , x_attribute8
    , x_attribute9
    , x_attribute10
    , x_attribute11
    , x_attribute12
    , x_attribute13
    , x_attribute14
    , x_attribute15
    , x_attribute_category
    , sysdate
    , fnd_global.user_id
    , sysdate
    , g_user_id
    , g_login_id );

    open c_rowid;
    fetch c_rowid into x_rowid;
    if c_rowid%notfound
    then
      close c_rowid;
      raise no_data_found;
    end if;
    close c_rowid;
  END create_resource_skill;

  PROCEDURE lock_resource_skill
  ( x_resource_skill_id   in number
  , x_object_version_number in number )
  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_resource_skills_b
      where resource_skill_id = x_resource_skill_id
      for update of resource_skill_id nowait;

    l_rec c_ovn%rowtype;

  BEGIN
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = x_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  END lock_resource_skill;

  PROCEDURE update_resource_skill
  ( x_resource_skill_id  in number
  , x_object_version_number in out nocopy number
  , x_skill_type_id      in number
  , x_skill_id           in number
  , x_resource_type      in varchar2
  , x_resource_id        in number
  , x_skill_level_id     in number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null )
  IS
    -- cursor to check for duplicate skills assigned to a resource
    cursor c_resSkill is
    select 1
      from csf_resource_skills_b
     where resource_id = x_resource_id
       and skill_id = x_skill_id
       and resource_type = x_resource_type
       and skill_type_id = x_skill_type_id
       and resource_skill_id <> x_resource_skill_id;

    l_dummy_var number;
    l_ovn number;
  BEGIN
    -- check for duplicate skills assigned to a resource
    open c_resSkill;
    fetch c_resSkill into l_dummy_var;

    if l_dummy_var is not null then
      close c_resSkill;
      fnd_message.set_name('CSF','CSF_DC_DUPLICATE_RES_SKILL');
      raise_application_error(-20110,fnd_message.get);
    end if;

    close c_resSkill;

    update csf_resource_skills_b
    set skill_type_id         = x_skill_type_id
    ,   skill_id              = x_skill_id
    ,   resource_type         = x_resource_type
    ,   resource_id           = x_resource_id
    ,   skill_level_id        = x_skill_level_id
    ,   start_date_active     = x_start_date_active
    ,   end_date_active       = x_end_date_active
    ,   object_version_number = object_version_number + 1
    ,   attribute1            = x_attribute1
    ,   attribute2            = x_attribute2
    ,   attribute3            = x_attribute3
    ,   attribute4            = x_attribute4
    ,   attribute5            = x_attribute5
    ,   attribute6            = x_attribute6
    ,   attribute7            = x_attribute7
    ,   attribute8            = x_attribute8
    ,   attribute9            = x_attribute9
    ,   attribute10           = x_attribute10
    ,   attribute11           = x_attribute11
    ,   attribute12           = x_attribute12
    ,   attribute13           = x_attribute13
    ,   attribute14           = x_attribute14
    ,   attribute15           = x_attribute15
    ,   attribute_category    = x_attribute_category
    ,   last_update_date      = sysdate
    ,   last_updated_by       = g_user_id
    ,   last_update_login     = g_login_id
    where resource_skill_id = x_resource_skill_id
    returning object_version_number into l_ovn;

    if sql%notfound
    then
      raise no_data_found;
    end if;
    x_object_version_number := l_ovn;
  END update_resource_skill;

  PROCEDURE delete_resource_skill ( x_resource_skill_id in number )
  IS
  BEGIN
    delete from csf_resource_skills_b
    where resource_skill_id = x_resource_skill_id;

    if sql%notfound then
      raise no_data_found;
    end if;
  END delete_resource_skill;

  PROCEDURE create_required_skill
  ( x_rowid                 in out nocopy varchar2
  , x_required_skill_id     in out nocopy number
  , x_skill_type_id         in number
  , x_skill_id              in number
  , x_has_skill_type        in varchar2
  , x_has_skill_id          in number
  , x_skill_level_id        in number
  , x_skill_required_flag   in varchar2
  , x_level_required_flag   in varchar2
  , x_disabled_flag         in varchar2
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null )
  IS
    cursor c_rowid
    is
      select rowid
      from csf_required_skills_b
      where required_skill_id = x_required_skill_id;

    -- cursor to check for duplicate skills to task
    cursor c_reqSkill is
    select 1
      from csf_required_skills_b
     where skill_id = x_skill_id
       and skill_type_id = x_skill_type_id
       and has_skill_type = x_has_skill_type
       and has_skill_id = x_has_skill_id;

    l_dummy_var number;
  BEGIN
    if x_required_skill_id is null
    then
      select csf_required_skills_b_s1.nextval
      into x_required_skill_id
      from dual;
    else
      -- Checks if record to be inserted already exists.
      -- If it does, do nothing (RETURN), else, continue.
      open c_rowid;
      fetch c_rowid into x_rowid;
      if c_rowid%found
      then
        close c_rowid;
        return;
      end if;
      close c_rowid;
    end if;

    -- check for duplicate skills to task
    open c_reqSkill;
    fetch c_reqSkill into l_dummy_var;

    if l_dummy_var is not null then
      close  c_reqSkill;

      if x_has_skill_type='TASK' then
        fnd_message.set_name('CSF','CSF_DUPLICATE_RECORD');
        raise_application_error(-20110,fnd_message.get);
      elsIf x_has_skill_type='TASK TEMPLATE' then
        fnd_message.set_name('CSF','CSF_DC_DUPLICATE_TASK_TEMPLATE');
        raise_application_error(-20110,fnd_message.get);
      end if;
    end if;

    close  c_reqSkill;

    if x_object_version_number is null
    then
      x_object_version_number := 1;
    end if;

    insert into csf_required_skills_b
    ( required_skill_id
    , skill_type_id
    , skill_id
    , has_skill_type
    , has_skill_id
    , skill_level_id
    , skill_required_flag
    , level_required_flag
    , disabled_flag
    , start_date_active
    , end_date_active
    , object_version_number
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
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login )
    values
    ( x_required_skill_id
    , x_skill_type_id
    , x_skill_id
    , x_has_skill_type
    , x_has_skill_id
    , x_skill_level_id
    , x_skill_required_flag
    , x_level_required_flag
    , x_disabled_flag
    , x_start_date_active
    , x_end_date_active
    , x_object_version_number
    , x_attribute1
    , x_attribute2
    , x_attribute3
    , x_attribute4
    , x_attribute5
    , x_attribute6
    , x_attribute7
    , x_attribute8
    , x_attribute9
    , x_attribute10
    , x_attribute11
    , x_attribute12
    , x_attribute13
    , x_attribute14
    , x_attribute15
    , x_attribute_category
    , sysdate
    , fnd_global.user_id
    , sysdate
    , g_user_id
    , g_login_id );

    open c_rowid;
    fetch c_rowid into x_rowid;
    if c_rowid%notfound
    then
      close c_rowid;
      raise no_data_found;
    end if;
    close c_rowid;
  END create_required_skill;

  PROCEDURE lock_required_skill
  ( x_required_skill_id   in number
  , x_object_version_number in number )
  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_required_skills_b
      where required_skill_id = x_required_skill_id
      for update of required_skill_id nowait;

    l_rec c_ovn%rowtype;

  BEGIN
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = x_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  END lock_required_skill;

  PROCEDURE update_required_skill
  ( x_required_skill_id   in number
  , x_object_version_number in out nocopy number
  , x_skill_type_id       in number
  , x_skill_id            in number
  , x_has_skill_type      in varchar2
  , x_has_skill_id        in number
  , x_skill_level_id      in number
  , x_skill_required_flag in varchar2
  , x_level_required_flag in varchar2
  , x_disabled_flag       in varchar2
  , x_start_date_active   in date
  , x_end_date_active     in date
  , x_attribute1          in varchar2 default null
  , x_attribute2          in varchar2 default null
  , x_attribute3          in varchar2 default null
  , x_attribute4          in varchar2 default null
  , x_attribute5          in varchar2 default null
  , x_attribute6          in varchar2 default null
  , x_attribute7          in varchar2 default null
  , x_attribute8          in varchar2 default null
  , x_attribute9          in varchar2 default null
  , x_attribute10         in varchar2 default null
  , x_attribute11         in varchar2 default null
  , x_attribute12         in varchar2 default null
  , x_attribute13         in varchar2 default null
  , x_attribute14         in varchar2 default null
  , x_attribute15         in varchar2 default null
  , x_attribute_category  in varchar2 default null )
  IS
    l_ovn number;
  BEGIN
    update csf_required_skills_b
    set skill_type_id         = x_skill_type_id
    ,   skill_id              = x_skill_id
    ,   has_skill_type        = x_has_skill_type
    ,   has_skill_id          = x_has_skill_id
    ,   skill_level_id        = x_skill_level_id
    ,   skill_required_flag   = x_skill_required_flag
    ,   level_required_flag   = x_level_required_flag
    ,   disabled_flag         = x_disabled_flag
    ,   start_date_active     = x_start_date_active
    ,   end_date_active       = x_end_date_active
    ,   object_version_number = object_version_number + 1
    ,   attribute1            = x_attribute1
    ,   attribute2            = x_attribute2
    ,   attribute3            = x_attribute3
    ,   attribute4            = x_attribute4
    ,   attribute5            = x_attribute5
    ,   attribute6            = x_attribute6
    ,   attribute7            = x_attribute7
    ,   attribute8            = x_attribute8
    ,   attribute9            = x_attribute9
    ,   attribute10           = x_attribute10
    ,   attribute11           = x_attribute11
    ,   attribute12           = x_attribute12
    ,   attribute13           = x_attribute13
    ,   attribute14           = x_attribute14
    ,   attribute15           = x_attribute15
    ,   attribute_category    = x_attribute_category
    ,   last_update_date      = sysdate
    ,   last_updated_by       = g_user_id
    ,   last_update_login     = g_login_id
    where required_skill_id = x_required_skill_id
    returning object_version_number into l_ovn;

    if sql%notfound
    then
      raise no_data_found;
    end if;
    x_object_version_number := l_ovn;
  END update_required_skill;

  PROCEDURE delete_required_skill ( x_required_skill_id in number )
  IS
  BEGIN
    delete from csf_required_skills_b
    where required_skill_id = x_required_skill_id;

    if sql%notfound then
      raise no_data_found;
    end if;
  END delete_required_skill;

--==============================================================
-- PUBLIC Procedures for translation
--==============================================================
  PROCEDURE translate_rating_scale
  ( p_rating_scale_id       in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2)
  IS
  BEGIN
    update csf_rating_scales_tl
    set name = p_name,
        description = p_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where rating_scale_id = to_number(p_rating_scale_id)
    and userenv('LANG') in (language, source_lang);
  END translate_rating_scale;

  PROCEDURE translate_skill
  ( p_skill_id              in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2)
  IS
  BEGIN
    update csf_skills_tl
    set name = p_name,
        description = p_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where skill_id = to_number(p_skill_id)
    and userenv('LANG') in (language, source_lang);
  END translate_skill;


  PROCEDURE translate_skill_level
  ( p_skill_level_id        in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2)
  IS
  BEGIN
    update csf_skill_levels_tl
    set name = p_name,
        description = p_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where skill_level_id = to_number(p_skill_level_id)
    and userenv('LANG') in (language, source_lang);
  END translate_skill_level;

  PROCEDURE translate_skill_type
  ( p_skill_type_id         in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2)
  IS
  BEGIN
    update csf_skill_types_tl
    set name = p_name,
        description = p_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang = userenv('LANG')
    where skill_type_id = to_number(p_skill_type_id)
    and userenv('LANG') in (language, source_lang);
  END translate_skill_type;

BEGIN
  -- set some session info
  g_user_id  := fnd_global.user_id;
  g_login_id := fnd_global.login_id;

END csf_skills_pkg;

/
