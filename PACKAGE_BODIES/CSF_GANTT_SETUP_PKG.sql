--------------------------------------------------------
--  DDL for Package Body CSF_GANTT_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_GANTT_SETUP_PKG" as
/* $Header: CSFGTSTB.pls 120.0.12010000.2 2009/12/22 12:56:59 ramchint ship $ */
  procedure insert_row
  ( p_seq_id                IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_icon_file_name        IN varchar2
  , p_description           IN varchar2
  , P_RANKING               IN number
  , P_ACTIVE                IN VARCHAR2
  )
  is
  begin
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

    insert into csf_gnticons_setup_b
    ( seq_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , object_version_number
    , icon_file_name
    , description
    , ranking
    , active
    )
    values
    ( p_seq_id
    , p_created_by
    , p_creation_date
    , p_last_updated_by
    , p_last_update_date
    , p_last_update_login
    , p_object_version_number
    , p_icon_file_name
    , p_description
    , p_ranking
    , p_active
    );
  end insert_row;

  procedure update_row
  ( p_seq_id                IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_icon_file_name        IN varchar2
  , p_description           IN varchar2
  , p_RANKING                  IN number
  , p_ACTIVE                   IN VARCHAR2
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

    update csf_gnticons_setup_b
    set
        last_updated_by        = p_last_updated_by
    ,   last_update_date       = p_last_update_date
    ,   last_update_login      = p_last_update_login
    ,   object_version_number  = p_object_version_number
    ,   icon_file_name         = p_icon_file_name
    ,   description            = p_description
    ,   ranking                = p_ranking
    ,   active                 = p_active
    where seq_id = p_seq_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;
  end update_row;


  procedure load_row
  ( p_seq_id                IN varchar2
  , p_owner                 IN varchar2
  , p_object_version_number IN varchar2
  , p_icon_file_name        IN varchar2
  , p_description           IN varchar2
  , p_RANKING               IN varchar2
  , p_ACTIVE                IN VARCHAR2
  )
  is
    l_seq_id                number       ;
    l_object_version_number number       ;
    l_update_date           date         ;
    l_user                  number       := 0;
    l_row_id                varchar2(64);

  begin
    if (p_owner = 'SEED')
    then
      l_user := 1;
    end if;
    l_seq_id                  := to_number(p_seq_id);
    l_object_version_number   := to_number(p_object_version_number);
    l_update_date             := sysdate;



    update_row
    ( p_seq_id                 => l_seq_id
    , p_created_by             => l_user
    , p_creation_date          => l_update_date
    , p_last_updated_by        => l_user
    , p_last_update_date       => l_update_date
    , p_last_update_login      => l_user
    , p_object_version_number  => l_object_version_number
    , p_icon_file_name         => p_icon_file_name
    , p_description            => p_description
    , p_ranking                => to_number(p_ranking)
    , p_active                 =>  p_active
    );
  exception
    when NO_DATA_FOUND then
      insert_row
      ( p_seq_id                 => l_seq_id
      , p_created_by             => l_user
      , p_creation_date          => l_update_date
      , p_last_updated_by        => l_user
      , p_last_update_date       => l_update_date
      , p_last_update_login      => l_user
      , p_object_version_number  => l_object_version_number
      , p_icon_file_name         => p_icon_file_name
      , p_description            => p_description
      , p_ranking                => to_number(p_ranking)
      , p_active                 =>  p_active
      );
  end load_row;

  PROCEDURE insert_rows
  ( p_setup_type		IN	varchar2
  , p_tooltip_setup_tbl IN	tooltip_setup_tbl
  , p_delete_rows	IN	boolean
  , p_user_id		IN	number
  , p_login_id     IN   number
  )
  IS
  BEGIN


    for i in p_tooltip_setup_tbl.first..p_tooltip_setup_tbl.last
    loop
       insert into csf_gantt_chart_setup
        (created_by,creation_date,last_updated_by, last_update_date, last_update_login, user_id, setup_type, seq_no, field_name, field_value)
         values (p_user_id, sysdate, p_user_id,sysdate,p_login_id, p_user_id,p_setup_type,p_tooltip_setup_tbl(i).seq_no,p_tooltip_setup_tbl(i).field_name,p_tooltip_setup_tbl(i).field_value);
    end loop;

  END INSERT_ROWS;


end CSF_GANTT_SETUP_PKG;

/
