--------------------------------------------------------
--  DDL for Package Body BEN_SEED_COMMUNICATION_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SEED_COMMUNICATION_TYPES" as
/* $Header: bencmtse.pkb 120.0 2005/05/28 03:50:33 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Seed Communication Types
Purpose
        This package is used to seed communication types on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        30 Oct 98        S Tee      115.0      Created.
        01 Jul 99        Tmathers   115.1      Changed to use startup table.
        11 May 00        S Tee      115.0      Insert into MLS table.
        16 Dec 04        rpgupta    115.4      Insert the to_be_sent_cd which is
                                               seeded.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_seed_communication_types';
--
--
procedure seed_communication_types(p_business_group_id in number) is
  --
  l_package               varchar2(80) := g_package||'.seed_communication_types';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
    --
    insert into ben_cm_typ_f
    (cm_typ_id,
     effective_start_date,
     effective_end_date,
     name,
     whnvr_trgrd_flag,
     shrt_name,
     pc_kit_cd,
     trk_mlg_flag,
     to_be_sent_dt_cd,
     inspn_rqd_flag,
     business_group_id,
     object_version_number)
    select
    ben_cm_typ_s.nextval,
     to_date('01-01-1950','DD-MM-YYYY'),
     to_date('31-12-4712','DD-MM-YYYY'),
     name,
     'N',
     shrt_name,
     'PC',
     'N',
     nvl(to_be_sent_dt_cd, 'OED'),--4056466
     'N',
     p_business_group_id,
     1
     from ben_startup_cm_typ s_ct
     where not exists (select 1
                       from ben_cm_typ_f ct
                       where s_ct.name          = ct.name
                       and   s_ct.shrt_name     = ct.shrt_name
                       and ct.business_group_id = p_business_group_id);
    --
    -- Insert into MLS table.
    --
    insert into ben_cm_typ_f_tl (
      cm_typ_id,
      effective_start_date,
      effective_end_date,
      shrt_name,
      name,
      language,
      source_lang,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date
    ) select
      b.cm_typ_id,
      b.effective_start_date,
      b.effective_end_date,
      tl.shrt_name,
      tl.name,
      tl.language,
      tl.source_lang,
      b.last_update_date,
      b.last_updated_by,
      b.last_update_login,
      b.created_by,
      b.creation_date
    from ben_cm_typ_f b
        ,ben_startup_cm_typ_tl tl
    where b.business_group_id = p_business_group_id
    and b.shrt_name = tl.shrt_name
    and not exists
            (select 'Y'
             from ben_cm_typ_f_tl t
             where t.cm_typ_id = b.cm_typ_id
             and t.effective_start_date = b.effective_start_date
             and   t.source_lang = userenv('LANG'));
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end seed_communication_types;
--
end ben_seed_communication_types;

/
