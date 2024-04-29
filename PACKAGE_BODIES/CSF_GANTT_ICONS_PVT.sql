--------------------------------------------------------
--  DDL for Package Body CSF_GANTT_ICONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_GANTT_ICONS_PVT" as
/* $Header: CSFGTICB.pls 120.0 2005/05/24 17:42:38 appldev noship $ */
  procedure update_row
  ( p_seq_id                IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_RANKING               IN number
  , p_ACTIVE                IN VARCHAR2
  , p_last_updated_by       IN  number
  , p_last_update_date      IN   date
  , p_last_update_login     IN   number
  )
  is
    l_last_updated_by   number;
  l_last_update_date        date;
  l_last_update_login       number	;
  begin

    if p_last_updated_by is null then
      l_last_updated_by   := fnd_global.user_id;
    end if;

    if p_last_update_login is null then
      l_last_update_login := fnd_global.login_id;
    end if;

    if p_last_update_date is null then
      l_last_update_date  := sysdate;
    end if;

    update csf_gnticons_setup_b
    set
        last_updated_by        = l_last_updated_by
    ,   last_update_date       = l_last_update_date
    ,   last_update_login      = l_last_update_login
    ,   object_version_number  = object_version_number + 1
    ,   ranking                = p_ranking
    ,   active                 = p_active
    where seq_id = p_seq_id;

    if sql%notfound
    then
      raise NO_DATA_FOUND;
    end if;
  end update_row;
end CSF_GANTT_ICONS_PVT;

/
