--------------------------------------------------------
--  DDL for Package BEN_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TYPE" AUTHID CURRENT_USER as
/* $Header: bentype.pkh 120.0 2005/05/28 00:13:32 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Environment Object Caching Routine
Purpose
	This package is used to return environment object information.
History
  Date       Who        Version    What?
  ---------  ---------  -------    --------------------------------------------
  27 Jul 99  mhoyes     115.0      Created
  ------------------------------------------------------------------------------
*/
--
  --
  -- Types
  --
  --   Create reporting structure
  --
  type g_report_rec is record
    (reporting_id          number,
     benefit_action_id     number,
     thread_id             number,
     sequence              number,
     rep_typ_cd            hr_lookups.lookup_code%type,
     error_message_code    hr_lookups.lookup_code%type,
     national_identifier   per_people_f.national_identifier%type,
     related_person_ler_id ben_ler_f.ler_id%type,
     temporal_ler_id       ben_ler_f.ler_id%type,
     ler_id                ben_ler_f.ler_id%type,
     person_id             per_people_f.person_id%type,
     pgm_id                ben_pgm_f.pgm_id%type,
     pl_id                 ben_pl_f.pl_id%type,
     related_person_id     per_people_f.person_id%type,
     oipl_id               ben_oipl_f.oipl_id%type,
     pl_typ_id             ben_pl_typ_f.pl_typ_id%type,
     actl_prem_id          ben_actl_prem_f.actl_prem_id%type,
     val                   ben_prtt_prem_by_mo_f.val%type,
     mo_num                ben_prtt_prem_by_mo_f.mo_num%type,
     yr_num                ben_prtt_prem_by_mo_f.yr_num%type,
     text                  varchar2(2000),
     object_version_number number);
  --
  type g_report_table is varray(10000000) of g_report_rec;
  --
  -- Batch actions
  --
  type g_batch_action_rec is record
    (person_action_id      number,
     action_status_cd      varchar2(30),
     ler_id                number,
     object_version_number number,
     effective_date        date);
  --
  type g_batch_action_table is varray(10000000) of g_batch_action_rec;
  --
  type g_batch_proc_rec is record
    (batch_ler_id          number,
     benefit_action_id     number,
     strt_dt               date,
     end_dt                date,
     strt_tm               varchar2(30),
     end_tm                varchar2(30),
     elpsd_tm              varchar2(30),
     per_slctd             number,
     per_proc              number,
     per_unproc            number,
     per_proc_succ         number,
     per_err               number,
     business_group_id     number,
     object_version_number number);
  --
  type g_batch_proc_table is varray(10000000) of g_batch_proc_rec;
  --
  type g_batch_commu_rec is record
    (batch_commu_id         number,
     benefit_action_id     number,
     person_id             number,
     per_cm_id             number,
     cm_typ_id             number,
     per_cm_prvdd_id       number,
     to_be_sent_dt         date,
     business_group_id     number,
     object_version_number number);
  --
  type g_batch_commu_table is varray(10000000) of g_batch_commu_rec;
  --
--
end ben_type;

 

/
