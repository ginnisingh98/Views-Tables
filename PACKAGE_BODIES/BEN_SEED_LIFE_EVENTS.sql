--------------------------------------------------------
--  DDL for Package Body BEN_SEED_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SEED_LIFE_EVENTS" as
/* $Header: benlerse.pkb 120.4 2006/11/07 09:22:19 nhunur ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Seed Life Events
Purpose
        This package is used to seed life events on a business group basis.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        24 Jan 98        G Perry    110.0      Created.
        08 Apr 98        G Perry    110.1      Accounted for schema change
                                               to ben_ler_f.
        16 Jun 98        G Perry    110.2      Rewrote insert going straight
                                               to the table to avoid mutating
                                               table issues.
        31-dec-98        jlamoure   110.3      Added new life events QMSCO and
                                               QDRO.
        15-Jan-99        maagrawa   115.4      Added life event for override
                                               enrollment.
        04-Mar-99        lmcdonal   115.5      remove QMSCO and QDRO.
        04-Mar-99        stee       115.6      Add new life events, Reduction
                                               of hours, Loss of Eligibility
                                               and Satisfied Waiting Period
                                               events.
        01-Jul-99        tmathers   115.7      Use startup table.
        24-Sep-99        stee       115.8      Add cobra qualifying event
                                               flag.
        12-May-00        stee       115.9      Insert into MLS table.
        30-Jun-06        rbingi     115.11     5367645: Inserting defaults to
                                                TimelinesEvalCode and Timneliness Days
        18-Sep-06        rgajula    115.12     Bug  5521080 : Removed the condition s_ler.name = ler.name
        2-nov-06         nhunur     115.13     set codes for temporals only
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_seed_life_events';
--
--
procedure seed_life_events(p_business_group_id in number) is
  --
  l_package               varchar2(80) := g_package||'.seed_life_events';
  l_object_version_number number(38);
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
    --
    insert into ben_ler_f
    (ler_id,
     effective_start_date,
     effective_end_date,
     name,
     business_group_id,
     typ_cd,
     ck_rltd_per_elig_flag,
     cm_aply_flag,
     ovridg_le_flag,
     qualg_evt_flag,
     tmlns_eval_cd,  -- 5367645
     tmlns_dys_num,  -- 5367645
     object_version_number)
    select
     ben_ler_f_s.nextval,
     to_date('01-01-1950','DD-MM-YYYY'),
     to_date('31-12-4712','DD-MM-YYYY'),
     name,
     p_business_group_id,
     typ_cd,
     'N',
     'N',
     'N',
     'N',
     decode(TYP_CD,'DRVDAGE','PRCM', 'DRVDCAL','PRCM','DRVDCMP','PRCM','DRVDHRW','PRCM','DRVDLOS','PRCM',NULL) ,
     decode(TYP_CD,'DRVDAGE',90, 'DRVDCAL',90,'DRVDCMP',90,'DRVDHRW',90,'DRVDLOS',90,NULL) ,
     1
   from ben_startup_lers s_ler
   where not exists (select 1
                     from ben_ler_f ler
                     where s_ler.typ_cd          = ler.typ_cd
                     and   ler.business_group_id = p_business_group_id
                    );

  -- Bug  5521080 : Removed the condition s_ler.name = ler.name
  -- from the above select statement to make it lesser restrictive.
  --
  -- Insert into MLS table.
  --
  insert into ben_ler_f_tl (
    ler_id,
    effective_start_date,
    effective_end_date,
    typ_cd,
    name,
    language,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
  ) select
    b.ler_id,
    b.effective_start_date,
    b.effective_end_date,
    tl.typ_cd,
    tl.name,
    tl.language,
    tl.source_lang,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    b.created_by,
    b.creation_date
  from ben_ler_f b
      ,ben_startup_lers_tl tl
  where b.business_group_id = p_business_group_id
  and b.typ_cd = tl.typ_cd
  and not exists
          (select 'Y'
           from ben_ler_f_tl t
           where t.ler_id = b.ler_id
           and t.effective_start_date = b.effective_start_date
           and   t.source_lang = userenv('LANG'));

  hr_utility.set_location ('Leaving '||l_package,10);
  --
end seed_life_events;
--
end ben_seed_life_events;

/
