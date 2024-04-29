--------------------------------------------------------
--  DDL for Package Body BEN_SEED_REGULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SEED_REGULATIONS" as
/* $Header: benregse.pkb 120.0 2005/05/28 09:25:43 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Seed Regulations
Purpose
        This package is used to seed regulations on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        08 Oct 99        S Tee      115.0      Created.
        11 May 00        S Tee      115.1      Insert into MLS table.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_seed_regulations';
--
--
procedure seed_regulations(p_business_group_id in number) is
  --
  l_package               varchar2(80) := g_package||'.seed_regulations';
  l_object_version_number number(38);
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
    --
    insert into ben_regn_f
    (regn_id,
     effective_start_date,
     effective_end_date,
     name,
     sttry_citn_name,
     business_group_id,
     object_version_number)
    select
     ben_regn_f_s.nextval,
     to_date('01-01-1950','DD-MM-YYYY'),
     to_date('31-12-4712','DD-MM-YYYY'),
     name,
     sttry_citn_name,
     p_business_group_id,
     1
   from ben_startup_regn s_reg
   where not exists (select 1
                     from ben_regn_f reg
                     where s_reg.sttry_citn_name = reg.sttry_citn_name
                     and   reg.business_group_id = p_business_group_id
                    );
  --
  -- Insert into MLS table.
  --
  insert into ben_regn_f_tl (
    regn_id,
    effective_start_date,
    effective_end_date,
    name,
    sttry_citn_name,
    language,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
  ) select
    b.regn_id,
    b.effective_start_date,
    b.effective_end_date,
    tl.name,
    tl.sttry_citn_name,
    tl.language,
    tl.source_lang,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    b.created_by,
    b.creation_date
  from ben_regn_f b
      ,ben_startup_regn_tl tl
  where b.business_group_id = p_business_group_id
  and b.sttry_citn_name = tl.sttry_citn_name
  and not exists
          (select 'Y'
           from ben_regn_f_tl t
           where t.regn_id = b.regn_id
           and t.effective_start_date = b.effective_start_date
           and   t.source_lang = userenv('LANG'));
 --
 hr_utility.set_location ('Leaving '||l_package,10);
  --
end seed_regulations;
--
end ben_seed_regulations;

/
