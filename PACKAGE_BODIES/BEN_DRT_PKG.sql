--------------------------------------------------------
--  DDL for Package Body BEN_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DRT_PKG" AS
/* $Header: bedrtapi.pkb 120.0.12010000.3 2018/03/30 10:12:32 arakudit noship $ */
--
/*
+========================================================================+
|             Copyright (c) 1997,2018 Oracle Corporation                 |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
*/
/*
History
     Date             Who        Version    What?
     ----             ---        -------    -----
     27-Mar-2018      arakudit   120.0                 Initial Version
     30-Mar-2018      arakudit   120.0.12010000.1      Benefits Assignment Validation removed.
*/
-----------------------------------------------------------------------------------------


  l_package varchar2(33) DEFAULT 'BEN_DRT_PKG.';

PROCEDURE write_log
  (message IN varchar2
                   ,stage   IN varchar2) IS
BEGIN
  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.string (fnd_log.level_procedure
                   ,message
                   ,stage);
  END IF;
END write_log;

PROCEDURE add_to_results
  (person_id   IN            number
                        ,entity_type IN            varchar2
                        ,status      IN            varchar2
                        ,msgcode     IN            varchar2
                        ,msgaplid    IN            number
  ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    n number(15);
  BEGIN
    n := result_tbl.count + 1;

    result_tbl (n).person_id := person_id;

    result_tbl (n).entity_type := entity_type;

    result_tbl (n).status := status;

    result_tbl (n).msgcode := msgcode;

  result_tbl (n).msgaplid := msgaplid;
END add_to_results;

PROCEDURE ben_hr_drc(person_id  IN         number
                    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

 l_proc varchar2(72) := l_package|| 'ben_hr_drc';
 l_person_id number(20) := person_id;
 l_count number;
 l_temp varchar2(20);
 l_success     boolean := true;

 cursor c_check_pil
 is
 select 'Y'
 from ben_per_in_ler
 where PERSON_ID = l_person_id
 and PER_IN_LER_STAT_CD in ('STRTD')
 union
 select 'Y'
 from ben_ptnl_ler_for_per
 where person_id = l_person_id
 and PTNL_LER_FOR_PER_STAT_CD in ('UNPROCD','DTCTD');

 l_check_pil c_check_pil%rowtype;

 cursor c_check_pen
 is
 SELECT  * FROM ben_prtt_enrt_rslt_f
 WHERE person_id = l_person_id
 AND prtt_enrt_rslt_stat_cd IS NULL
 AND sysdate between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 And sysdate between ENRT_CVG_STRT_DT and ENRT_CVG_THRU_DT;

 l_check_pen c_check_pen%rowtype;

 cursor c_check_pdp
 is
 SELECT  *
 FROM    ben_elig_cvrd_dpnt_f
 where DPNT_PERSON_ID = l_person_id
 AND sysdate between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE
 And sysdate between CVG_STRT_DT and CVG_THRU_DT;

 l_check_pdp c_check_pdp%rowtype;

 cursor c_check_plbnf
 is
 select * from ben_pl_bnf_f
 where BNF_PERSON_ID = l_person_id
 and sysdate between DSGN_STRT_DT and  DSGN_THRU_DT;

 l_check_plbnf c_check_plbnf%rowtype;

BEGIN
  write_log ('Entering: '|| l_proc,'10');
  l_person_id := person_id;
  open c_check_pil;
  fetch c_check_pil into l_check_pil;
  if c_check_pil%found then
     l_success := false;
     add_to_results
			  (person_id => l_person_id
 			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'BEN_94968_GDPR_ACTV_LE'
			  ,msgaplid => 805
			  ,result_tbl => result_tbl);
  end if;
  close c_check_pil;

  open c_check_pen;
  fetch c_check_pen into l_check_pen;
  if c_check_pen%found then
     l_success := false;
     add_to_results
			  (person_id => l_person_id
 			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'BEN_94969_GDPR_ACTV_PEN'
			  ,msgaplid => 805
			  ,result_tbl => result_tbl);
  end if;
  close c_check_pen;

  open c_check_pdp;
  fetch c_check_pdp into l_check_pdp;
  if c_check_pdp%found then
     l_success := false;
     add_to_results
			  (person_id => l_person_id
 			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'BEN_94970_GDPR_CVRD_DPNT'
			  ,msgaplid => 805
			  ,result_tbl => result_tbl);
  end if;
  close c_check_pdp;

  open c_check_plbnf;
  fetch c_check_plbnf into l_check_plbnf;
  if c_check_plbnf%found then
     l_success := false;
     add_to_results
			  (person_id => l_person_id
 			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'BEN_94971_GDPR_ACTV_BNF'
			  ,msgaplid => 805
			  ,result_tbl => result_tbl);
  end if;
  close c_check_plbnf;

  if l_success then
     write_log ('Successfull BEN DRT'|| l_proc,'10');
     add_to_results
			  (person_id => l_person_id
 			  ,entity_type => 'HR'
			  ,status => 'S'
			  ,msgcode => null
			  ,msgaplid => null
			  ,result_tbl => result_tbl);
  end if;

  write_log ('Leaving:'|| l_proc,'10');

END ben_hr_drc;

PROCEDURE ben_hr_pre
    (person_id IN number) IS
BEGIN
    NULL;
END ben_hr_pre;

PROCEDURE ben_hr_post
    (person_id IN number) IS

 l_person_id number := person_id;
 l_proc varchar2(72) := l_package|| 'ben_hr_post';
BEGIN
    write_log ('Entering: '|| l_proc,'10');

    Delete from ben_reporting where person_id = l_person_id;

    write_log ('Leaving:'|| l_proc,'10');
END ben_hr_post;

END ben_drt_pkg;

/
