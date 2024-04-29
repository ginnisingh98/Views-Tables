--------------------------------------------------------
--  DDL for Package Body BEN_SEED_ACTION_ITEM_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SEED_ACTION_ITEM_TYPES" as
/* $Header: benactse.pkb 120.0.12010000.2 2008/08/05 14:30:48 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Seed Action Item Types
Purpose
        This package is used to seed action item types on a business group
        basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        18 Jun 98        S Tee      110.0      Created.
        08 Jul 99        TMathers   115.1      Uses seed tables now.
        12 May 00        S Tee      115.2      Insert into MLS table.
        18 Feb 02        gsheelum   115.3      Removed description from
                                                not_exists clause.
                                               Fixing 2217566.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_seed_action_item_types';
--
--
procedure seed_action_item_types(p_business_group_id in number) is
  --
  l_package               varchar2(80) := g_package||'.seed_action_item_types';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  --
    insert into ben_actn_typ
    (actn_typ_id,
     business_group_id,
     type_cd,
     name,
     description,
     object_version_number)
    select
     ben_actn_typ_s.nextval,
     p_business_group_id,
     s_at.type_cd,
     s_at.name,
     s_at.description,
     1
     from ben_startup_actn_typ s_at
     where not exists (select 'Y'
                      from ben_actn_typ act
                      where s_at.type_cd        = act.type_cd
                      and   s_at.name           = act.name
                      -- and   s_at.description    = act.description
                      and   p_business_group_id = act.business_group_id);
   --
   --  Also insert into MLS table.
   --
  insert into ben_actn_typ_tl (
    actn_typ_id,
    name,
    description,
    language,
    type_cd,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
  ) select
    b.actn_typ_id,
    tl.name,
    tl.description,
    tl.language,
    tl.type_cd,
    tl.source_lang,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    b.created_by,
    b.creation_date
  from ben_actn_typ b,
       ben_startup_actn_typ_tl tl
  where b.business_group_id = p_business_group_id
  and b.type_cd = tl.type_cd
  and not exists
            (select 'Y'
             from ben_actn_typ_tl t
             where t.actn_typ_id = b.actn_typ_id
             and   t.source_lang = userenv('LANG'));
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end seed_action_item_types;
--
end ben_seed_action_item_types;

/
