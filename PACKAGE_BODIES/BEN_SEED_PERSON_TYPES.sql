--------------------------------------------------------
--  DDL for Package Body BEN_SEED_PERSON_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SEED_PERSON_TYPES" as
/* $Header: benpptse.pkb 120.0 2005/05/28 09:18:09 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Seed Person Types
Purpose
        This package is used to seed person types on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        16 Jun 98        G Perry    110.0      Created.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_seed_person_types';
--
type g_varchar80 is table of varchar2(80) index by binary_integer;
--
procedure seed_person_types(p_business_group_id in number) is
  --
  l_package               varchar2(80) := g_package||'.seed_person_types';
  l_active_flag           g_varchar80;
  l_default_flag          g_varchar80;
  l_system_person_type    g_varchar80;
  l_user_person_type      g_varchar80;
  l_person_type_id        number;
  l_number_of_types       number(9) := 3;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Setup arrays
  --
  l_active_flag(1) := 'Y';
  l_active_flag(2) := 'Y';
  l_active_flag(3) := 'Y';
  --
  l_default_flag(1) := 'N';
  l_default_flag(2) := 'N';
  l_default_flag(3) := 'N';
  --
  l_system_person_type(1) := 'BNF';
  l_system_person_type(2) := 'DPNT';
  l_system_person_type(3) := 'PRTN';
  --
  l_user_person_type(1) := 'Beneficiary';
  l_user_person_type(2) := 'Dependent';
  l_user_person_type(3) := 'Participant';
  --
  for l_count in 1..l_number_of_types loop
    --
    select per_person_types_s.nextval
    into   l_person_type_id
    from   sys.dual;
    --
    insert into per_person_types
    (person_type_id,
     business_group_id,
     active_flag,
     default_flag,
     system_person_type,
     user_person_type)
    values
    (l_person_type_id,
     p_business_group_id,
     l_active_flag(l_count),
     l_default_flag(l_count),
     l_system_person_type(l_count),
     l_user_person_type(l_count));
    --
  end loop;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end seed_person_types;
--
end ben_seed_person_types;

/
