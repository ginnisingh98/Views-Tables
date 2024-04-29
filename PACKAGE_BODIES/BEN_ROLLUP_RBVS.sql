--------------------------------------------------------
--  DDL for Package Body BEN_ROLLUP_RBVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ROLLUP_RBVS" as
/* $Header: benrbvru.pkb 120.0 2005/05/28 09:25:25 appldev noship $ */
--
g_package varchar2(50) := 'ben_rollup_rbvs.';
--
PROCEDURE build_rollup_sql_str
  (p_rt_cd_va       in out nocopy benutils.g_v2_150_table
  ,p_rt_fromstr_va  in out nocopy benutils.g_varchar2_table
  ,p_rt_wherestr_va in out nocopy benutils.g_varchar2_table
  ,p_rt_sqlstr_va   in out nocopy benutils.g_varchar2_table
  ,p_rt_typcd_va    in out nocopy benutils.g_v2_150_table
  )
is
  --
  l_rawrt_en              pls_integer;
  l_rawrt_cd_va           benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_rawrt_typcd_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_rawrt_selstr_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rawrt_fromstr_va      benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rawrt_sqlstr_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rawrt_wherestr_va     benutils.g_varchar2_table := benutils.g_varchar2_table();
  --
  l_rt_en                 pls_integer;
  l_rt_sqlstr_va          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_fromstr_va         benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_wherestr_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_cd_va              benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_rt_typcd_va           benutils.g_v2_150_table := benutils.g_v2_150_table();
  --
  l_sql_str               long;
  l_sel_str               long;
  --
begin
  --
  l_rawrt_en := 1;
  --
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PPL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_ptnl_ler_for_per_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PIL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_per_in_ler_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PILBCKDT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_per_in_ler_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.PER_IN_LER_STAT_CD = '||''''||'BCKDT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PILSTRTD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_per_in_ler_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.PER_IN_LER_STAT_CD = '||''''||'STRTD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PILVOIDD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_per_in_ler_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.PER_IN_LER_STAT_CD = '||''''||'VOIDD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PILPROCD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_per_in_ler_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.PER_IN_LER_STAT_CD = '||''''||'PROCD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PILLTSCHEDDU';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_per_in_ler_rbv rbv, ben_ler_f ler ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.ler_id = ler.ler_id '
                                     ||' and ler.typ_cd = '||''''||'SCHEDDU'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'CRP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_cbr_per_in_ler_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'DTTABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPNULLPINL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.per_in_ler_id is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIE';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.elig_flag = '||''''||'N'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEAGE';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'AGE'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEAGL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'AGL'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEAST';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'AST'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEBGR';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'BGR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEBRG';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'BRG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIECMP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'CMP'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEDSB';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'DSB'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEAI';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EAI'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEECQ';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ECQ'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEDT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EDT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEET';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EET'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEGN';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EGN'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEHC';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EHC'||'''';


  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEOP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EOP'||'''';


  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEOY';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EOY'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEPS';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EPS'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEQG';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EQG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEQT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EQT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEERG';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ERG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEERL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ERL'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEETC';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ETC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEETD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ETD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEETP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ETP'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEETU';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ETU'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEEVT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'EVT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEFPT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'FPT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEGRD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'GRD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEHRS';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'HRS'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEJOB';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'JOB'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIELBR';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'LBR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIELOA';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'LOA'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIELOS';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'LOS'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEORG';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ORG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEPEO';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'PEO'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEPFQ';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'PFQ'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEPFT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'PFT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEPTP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'PTP'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEPYR';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'PYR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIESHR';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'SHR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIESTA';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'STA'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIESVC';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'SVC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPIEZIP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.inelg_rsn_cd = '||''''||'ZIP'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPWTPRD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and (rbv.wait_perd_cmpltn_dt is not null '
                                     ||' or   rbv.wait_perd_strt_dt is not null) ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPDFCT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and (rbv.comp_ref_amt is not null '
                                     ||' or   rbv.cmbn_age_n_los_val is not null '
                                     ||' or   rbv.age_val is not null '
                                     ||' or   rbv.los_val is not null '
                                     ||' or   rbv.hrs_wkd_val is not null '
                                     ||' or   rbv.pct_fl_tm_val is not null) ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPDFCTRT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and (rbv.rt_comp_ref_amt is not null '
                                     ||' or   rbv.rt_cmbn_age_n_los_val is not null '
                                     ||' or   rbv.rt_age_val is not null '
                                     ||' or   rbv.rt_los_val is not null '
                                     ||' or   rbv.rt_hrs_wkd_val is not null '
                                     ||' or   rbv.rt_pct_fl_tm_val is not null) ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPPGM';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id is not null '
                                     ||' and rbv.ptip_id is null '
                                     ||' and rbv.pl_id is null '
                                     ||' and rbv.plip_id is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPPTIP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id is not null '
                                     ||' and rbv.ptip_id is not null '
                                     ||' and rbv.pl_id is null '
                                     ||' and rbv.plip_id is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPPLN';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id is not null '
                                     ||' and rbv.ptip_id is null '
                                     ||' and rbv.pl_id is not null '
                                     ||' and rbv.plip_id is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPPLNIP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id is null '
                                     ||' and rbv.ptip_id is null '
                                     ||' and rbv.pl_id is not null '
                                     ||' and rbv.plip_id is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEPPLIP';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id is not null '
                                     ||' and rbv.ptip_id is null '
                                     ||' and rbv.pl_id is null '
                                     ||' and rbv.plip_id is not null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'EPO';
  l_rawrt_typcd_va(l_rawrt_en)    := 'DTTABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_opt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'EPONULLPINL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_opt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.per_in_ler_id is null';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'EPOIE';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_opt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.elig_flag = '||''''||'N'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'EPOWTPRD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_opt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and (rbv.wait_perd_cmpltn_dt is not null '
                                     ||' or   rbv.wait_perd_strt_dt is not null) ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'EPODFCT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_opt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and (rbv.comp_ref_amt is not null '
                                     ||' or   rbv.cmbn_age_n_los_val is not null '
                                     ||' or   rbv.age_val is not null '
                                     ||' or   rbv.los_val is not null '
                                     ||' or   rbv.hrs_wkd_val is not null '
                                     ||' or   rbv.pct_fl_tm_val is not null) ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'EPODFCTRT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_opt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and (rbv.rt_comp_ref_amt is not null '
                                     ||' or   rbv.rt_cmbn_age_n_los_val is not null '
                                     ||' or   rbv.rt_age_val is not null '
                                     ||' or   rbv.rt_los_val is not null '
                                     ||' or   rbv.rt_hrs_wkd_val is not null '
                                     ||' or   rbv.rt_pct_fl_tm_val is not null) ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPE';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEELFLG';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.elctbl_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEBPRVPL';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.BNFT_PRVDR_POOL_ID is not null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEAUTOENR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.auto_enrt_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPECURRENR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.crntly_enrd_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPECRYFWDDPNT';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cryfwd_elig_dpnt_cd = '||''''||'CFRRWP'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPLN';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pl_id is not null '
                                     ||' and rbv.oipl_id is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPLNIMPPRTT';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pl_f pln ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pl_id = pln.pl_id '
                                     ||' and pln.subj_to_imptd_incm_typ_cd = '||''''||'PRTT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPLNIMPDPNT';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pl_f pln ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pl_id = pln.pl_id '
                                     ||' and pln.subj_to_imptd_incm_typ_cd = '||''''||'DPNT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPLNIMPSPS';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pl_f pln ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pl_id = pln.pl_id '
                                     ||' and pln.subj_to_imptd_incm_typ_cd = '||''''||'SPS'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPGMARPMO';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pgm_f pgm ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id = pgm.pgm_id '
                                     ||' and pgm.acty_ref_perd_cd = '||''''||'MO'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPGMARPPYR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pgm_f pgm ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id = pgm.pgm_id '
                                     ||' and pgm.acty_ref_perd_cd = '||''''||'PYR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPGMARPPWK';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pgm_f pgm ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id = pgm.pgm_id '
                                     ||' and pgm.acty_ref_perd_cd = '||''''||'PWK'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPGMARPBWK';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pgm_f pgm ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id = pgm.pgm_id '
                                     ||' and pgm.acty_ref_perd_cd = '||''''||'BWK'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEPGMARPPHR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv, ben_pgm_f pgm ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id = pgm.pgm_id '
                                     ||' and pgm.acty_ref_perd_cd = '||''''||'PHR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPEOIPL';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_per_elctbl_chc_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pl_id is not null '
                                     ||' and rbv.oipl_id is not null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)     := 'PEL';
  l_rawrt_typcd_va(l_rawrt_en)  := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_pil_epe_popl_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)     := 'PELLEERSN';
  l_rawrt_typcd_va(l_rawrt_en)  := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_pil_epe_popl_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.lee_rsn_id is not null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ECC';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elctbl_chc_ctfn_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EGD';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_dpnt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EGDPELP';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_dpnt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.ELIG_PER_OPT_ID is null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EGDELPOPT';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_dpnt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.ELIG_PER_OPT_ID is not null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PDP';
  l_rawrt_typcd_va(l_rawrt_en) := 'DTTABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_cvrd_dpnt_f_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PDPCVRD';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_elig_cvrd_dpnt_f_rbv rbv, ben_prtt_enrt_rslt_f_rbv prbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                   ||' and   rbv.benefit_action_id = prbv.benefit_action_id '
                                   ||' and   rbv.PRTT_ENRT_RSLT_ID = prbv.PRTT_ENRT_RSLT_ID ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'CQB';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_cbr_quald_bnf_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENB';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBDFLT';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.dflt_flag='||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBCMCCL';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cvg_mlt_cd='||''''||'CL'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBCMCFLRNG';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cvg_mlt_cd='||''''||'FLRNG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBCMCFLFX';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cvg_mlt_cd='||''''||'FLFX'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBCMCSAAEAR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cvg_mlt_cd='||''''||'SAAEAR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBCMCCLRNG';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cvg_mlt_cd='||''''||'CLRNG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ENBCMCCLPFLRNG';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_bnft_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.cvg_mlt_cd='||''''||'CLPFLRNG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'EPR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_prem_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ECR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_rt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ECRFLXCR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_rt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.rt_usg_cd = '||''''||'FLXCR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ECRIMPTDINC';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_rt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.rt_usg_cd = '||''''||'IMPTDINC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ECRSTD';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_rt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.rt_usg_cd = '||''''||'STD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'ECRENTVLENR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from ben_enrt_rt_rbv rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.entr_val_at_enrt_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRV';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE0';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVEEV';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.ELEMENT_ENTRY_VALUE_ID is not null ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVFLFX';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'FLFX'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVCL';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'CL'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVSAREC';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'SAREC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVCVG';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'CVG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVNSVU';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'NSVU'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVPRNT';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'PRNT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVAP';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'AP'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVRL';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'RL'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVCLANDCVG';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.mlt_cd = '||''''||'CLANDCVG'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVRTOVRIDN';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.rt_ovridn_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCNCRDSTR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'NCRDSTR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCNCRUDED';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'NCRUDED'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCEEIC';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'EEIC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCEEPRIID';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'EEPRIID'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCEEPYC';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'EEPYC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCEEPYD';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'EEPYD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCERPYC';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'ERPYC'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCPBC2';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'PBC2'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCPRDPR';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'PRDPR'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)    := 'PRVATCCS';
  l_rawrt_typcd_va(l_rawrt_en) := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_RT_VAL_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.acty_typ_cd = '||''''||'CS'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PEN';
  l_rawrt_typcd_va(l_rawrt_en)    := 'DTTABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENPGMCOBRA';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv, ben_pgm_f pgm ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pgm_id = pgm.pgm_id '
                                     ||' and pgm.pgm_typ_cd like '||''''||'COBRA%'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENPLNDSGN';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv, ben_dsgn_rqmt_f dsn ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.pl_id = dsn.pl_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENOIPLDSGN';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv, ben_dsgn_rqmt_f dsn ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.oipl_id = dsn.oipl_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENCVGTHRUDT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.ENRT_CVG_THRU_DT <> to_date('||''''||'31/12/4712'||''''
                                     ||','||''''||'DD/MM/YYYY'||''''||')';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENDEENR';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(rbv.object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.ENRT_CVG_THRU_DT <> to_date('||''''||'31/12/4712'||''''
                                     ||','||''''||'DD/MM/YYYY'||''''||')'
                                     ||' and rbv.effective_end_date <> to_date('||''''||'31/12/4712'||''''
                                     ||','||''''||'DD/MM/YYYY'||''''||')';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENSSPND';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.sspndd_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENOVRIDN';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.enrt_ovridn_flag = '||''''||'Y'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENBCKDT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.prtt_enrt_rslt_stat_cd = '||''''||'BCKDT'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENVOIDD';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.prtt_enrt_rslt_stat_cd = '||''''||'VOIDD'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENAUTO';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.enrt_mthd_cd = '||''''||'A'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENDFLT';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.enrt_mthd_cd = '||''''||'D'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PENEXPL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'TABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PRTT_ENRT_RSLT_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id '
                                     ||' and rbv.enrt_mthd_cd = '||''''||'E'||'''';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'BPL';
  l_rawrt_typcd_va(l_rawrt_en)    := 'DTTABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_BNFT_PRVDD_LDGR_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  l_rawrt_en := l_rawrt_en+1;
  l_rawrt_cd_va.extend(1);
  l_rawrt_typcd_va.extend(1);
  l_rawrt_selstr_va.extend(1);
  l_rawrt_fromstr_va.extend(1);
  l_rawrt_wherestr_va.extend(1);
  l_rawrt_sqlstr_va.extend(1);
  l_rawrt_cd_va(l_rawrt_en)       := 'PCM';
  l_rawrt_typcd_va(l_rawrt_en)    := 'DTTABLE';
  l_rawrt_selstr_va(l_rawrt_en)   := ' select count(*), '
                                   ||'     nvl(sum(nvl(object_version_number,0)),0) sum_ovn ';
  l_rawrt_fromstr_va(l_rawrt_en)  := ' from BEN_PER_CM_F_RBV rbv ';
  l_rawrt_wherestr_va(l_rawrt_en) := ' where rbv.benefit_action_id = :benefit_action_id ';
  --
  -- Populate derived rollup types
  --
  l_rt_en := 1;
  --
  for rawrt_en in l_rawrt_cd_va.first..l_rawrt_cd_va.last
  loop
    --
    l_sel_str := null;
    l_sql_str := null;
    --
    l_rt_cd_va.extend(1);
    l_rt_fromstr_va.extend(1);
    l_rt_wherestr_va.extend(1);
    l_rt_sqlstr_va.extend(1);
    --
    l_rt_cd_va(l_rt_en)       := l_rawrt_cd_va(rawrt_en);
    l_rt_fromstr_va(l_rt_en)  := l_rawrt_fromstr_va(rawrt_en);
    l_rt_wherestr_va(l_rt_en) := l_rawrt_wherestr_va(rawrt_en);
    --
    if l_rawrt_typcd_va(rawrt_en) = 'DTTABLE'
    then
      --
      l_sel_str := l_rawrt_selstr_va(rawrt_en)
                   ||', min(effective_start_date) min_esd '
                   ||', min(effective_end_date) min_eed ';
      --
    else
      --
      l_sel_str := l_rawrt_selstr_va(rawrt_en)
                   ||', null min_esd '
                   ||', null min_eed ';
      --
    end if;
    --
    l_sql_str := l_sel_str
                 ||' '||l_rawrt_fromstr_va(rawrt_en)
                 ||' '||l_rawrt_wherestr_va(rawrt_en);
    --
    l_rt_sqlstr_va(l_rt_en) := l_sql_str;
    l_rt_en := l_rt_en+1;
    --
    if l_rawrt_typcd_va(rawrt_en) in ('TABLE0','DTTABLE')
    then
      --
      l_rt_cd_va.extend(1);
      l_rt_fromstr_va.extend(1);
      l_rt_wherestr_va.extend(1);
      l_rt_sqlstr_va.extend(1);
      l_rt_cd_va(l_rt_en)       := l_rawrt_cd_va(rawrt_en)||'INS';
      l_rt_fromstr_va(l_rt_en)  := l_rawrt_fromstr_va(rawrt_en);
      l_rt_wherestr_va(l_rt_en) := l_rawrt_wherestr_va(rawrt_en)
                                   ||' and   rbv.object_version_number = 1 ';
      l_rt_sqlstr_va(l_rt_en)   := l_sql_str
                                   ||' and   rbv.object_version_number = 1 ';
      l_rt_en := l_rt_en+1;
      --
    end if;
    --
    if l_rawrt_typcd_va(rawrt_en) = 'TABLE0'
    then
      --
      l_rt_cd_va.extend(1);
      l_rt_fromstr_va.extend(1);
      l_rt_wherestr_va.extend(1);
      l_rt_sqlstr_va.extend(1);
      l_rt_cd_va(l_rt_en)       := l_rawrt_cd_va(rawrt_en)||'UPD';
      l_rt_fromstr_va(l_rt_en)  := l_rawrt_fromstr_va(rawrt_en);
      l_rt_wherestr_va(l_rt_en) := l_rawrt_wherestr_va(rawrt_en)
                                   ||' and   rbv.object_version_number >= 2 ';
      l_rt_sqlstr_va(l_rt_en)   := l_sql_str
                                   ||' and   rbv.object_version_number >= 2 ';
      l_rt_en := l_rt_en+1;
      --
    elsif l_rawrt_typcd_va(rawrt_en) = 'DTTABLE'
    then
      --
      l_rt_cd_va.extend(1);
      l_rt_fromstr_va.extend(1);
      l_rt_wherestr_va.extend(1);
      l_rt_sqlstr_va.extend(1);
      l_rt_cd_va(l_rt_en)       := l_rawrt_cd_va(rawrt_en)||'UPDCORR';
      l_rt_fromstr_va(l_rt_en)  := l_rawrt_fromstr_va(rawrt_en);
      l_rt_wherestr_va(l_rt_en) := l_rawrt_wherestr_va(rawrt_en)
                                   ||' and   rbv.object_version_number = 2 ';
      l_rt_sqlstr_va(l_rt_en)   := l_sql_str
                                   ||' and   rbv.object_version_number = 2 ';
      l_rt_en := l_rt_en+1;
      --
      l_rt_cd_va.extend(1);
      l_rt_fromstr_va.extend(1);
      l_rt_wherestr_va.extend(1);
      l_rt_sqlstr_va.extend(1);
      l_rt_cd_va(l_rt_en)       := l_rawrt_cd_va(rawrt_en)||'UPD';
      l_rt_fromstr_va(l_rt_en)  := l_rawrt_fromstr_va(rawrt_en);
      l_rt_wherestr_va(l_rt_en) := l_rawrt_wherestr_va(rawrt_en)
                                   ||' and   rbv.object_version_number >= 3 ';
      l_rt_sqlstr_va(l_rt_en)   := l_sql_str
                                   ||' and   rbv.object_version_number >= 3 ';
      l_rt_en := l_rt_en+1;
      --
      l_rt_cd_va.extend(1);
      l_rt_fromstr_va.extend(1);
      l_rt_wherestr_va.extend(1);
      l_rt_sqlstr_va.extend(1);
      l_rt_cd_va(l_rt_en)       := l_rawrt_cd_va(rawrt_en)||'DEL';
      l_rt_fromstr_va(l_rt_en)  := l_rawrt_fromstr_va(rawrt_en);
      l_rt_wherestr_va(l_rt_en) := l_rawrt_wherestr_va(rawrt_en)
                                   ||' and   rbv.effective_end_date <> to_date('||''''||'31/12/4712'||''''
                                     ||','||''''||'DD/MM/YYYY'||''''||')';
      l_rt_sqlstr_va(l_rt_en)   := l_sql_str
                                   ||' and   rbv.effective_end_date <> to_date('||''''||'31/12/4712'||''''
                                   ||','||''''||'DD/MM/YYYY'||''''||')';
      l_rt_en := l_rt_en+1;
      --
    end if;
     --
  end loop;
  --
  -- Add the person action SQL
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'PERACT';
  l_rt_fromstr_va(l_rt_en)  := ' from ben_person_actions pact ';
  l_rt_wherestr_va(l_rt_en) := ' where pact.benefit_action_id = :benefit_action_id ';
  --
  l_sel_str := ' select count(*), '
               ||'  nvl(sum(nvl(object_version_number,0)),0) sum_ovn '
               ||', null min_esd '
               ||', null min_eed ';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'PERACTPROC';
  l_rt_fromstr_va(l_rt_en)  := ' from ben_person_actions pact ';
  l_rt_wherestr_va(l_rt_en) := ' where pact.benefit_action_id = :benefit_action_id '
                               ||' and pact.ACTION_STATUS_CD = '||''''||'P'||'''';
  --
  l_sel_str := ' select count(*), '
               ||'  nvl(sum(nvl(object_version_number,0)),0) sum_ovn '
               ||', null min_esd '
               ||', null min_eed ';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'PERACTUNPROC';
  l_rt_fromstr_va(l_rt_en)  := ' from ben_person_actions pact ';
  l_rt_wherestr_va(l_rt_en) := ' where pact.benefit_action_id = :benefit_action_id '
                               ||' and pact.ACTION_STATUS_CD = '||''''||'U'||'''';
  --
  l_sel_str := ' select count(*), '
               ||'  nvl(sum(nvl(object_version_number,0)),0) sum_ovn '
               ||', null min_esd '
               ||', null min_eed ';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'PERACTCCRRUN';
  l_rt_fromstr_va(l_rt_en)  := ' from ben_person_actions pact, '
                               ||' ben_batch_ranges bbr, '
                               ||' ben_benefit_actions bft, '
                               ||' fnd_concurrent_requests ccr '
                               ;
  l_rt_wherestr_va(l_rt_en) := ' where pact.benefit_action_id = :benefit_action_id '
                               ||' and pact.ACTION_STATUS_CD = '||''''||'U'||''''
                               ||' and pact.person_action_id '
                               ||'  between bbr.STARTING_PERSON_ACTION_ID and bbr.ENDING_PERSON_ACTION_ID '
                               ||' and bbr.benefit_action_id = bft.benefit_action_id '
                               ||' and bft.request_id = ccr.PARENT_REQUEST_ID '
                               ||' and bbr.last_update_login = ccr.last_update_login '
                               ||' and ccr.status_code = '||''''||'R'||'''';
  --
  l_sel_str := ' select count(*), '
               ||'  nvl(sum(nvl(object_version_number,0)),0) sum_ovn '
               ||', null min_esd '
               ||', null min_eed ';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'PERACTERR';
  l_rt_fromstr_va(l_rt_en)  := ' from ben_person_actions pact ';
  l_rt_wherestr_va(l_rt_en) := ' where pact.benefit_action_id = :benefit_action_id '
                               ||' and pact.ACTION_STATUS_CD = '||''''||'E'||'''';
  --
  l_sel_str := ' select count(*), '
               ||'  nvl(sum(nvl(object_version_number,0)),0) sum_ovn '
               ||', null min_esd '
               ||', null min_eed ';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'WWBUGS';
  l_rt_fromstr_va(l_rt_en)  := ' from ad_bugs abg ';
  l_rt_wherestr_va(l_rt_en) := ' where abg.last_update_date < '
                               ||' (select bft.last_update_date '
                               ||' from ben_benefit_actions bft '
                               ||' where bft.benefit_action_id = :benefit_action_id) ';
  --
  l_sel_str := ' select count(*) '
               ||', 0 sum_ovn '
               ||', null min_esd '
               ||', null min_eed ';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'WWBUGSBEN';
  l_rt_fromstr_va(l_rt_en)  := ' from ad_bugs abg ';
  l_rt_wherestr_va(l_rt_en) := ' where abg.last_update_date < '
                               ||' (select bft.last_update_date '
                               ||' from ben_benefit_actions bft '
                               ||' where bft.benefit_action_id = :benefit_action_id) '
                               ||' and abg.APPLICATION_SHORT_NAME = '||''''||'BEN'||'''';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'WWBUGSPER';
  l_rt_fromstr_va(l_rt_en)  := ' from ad_bugs abg ';
  l_rt_wherestr_va(l_rt_en) := ' where abg.last_update_date < '
                               ||' (select bft.last_update_date '
                               ||' from ben_benefit_actions bft '
                               ||' where bft.benefit_action_id = :benefit_action_id) '
                               ||' and abg.APPLICATION_SHORT_NAME = '||''''||'PER'||'''';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  l_rt_en := l_rt_en+1;
  --
  l_rt_cd_va.extend(1);
  l_rt_fromstr_va.extend(1);
  l_rt_wherestr_va.extend(1);
  l_rt_sqlstr_va.extend(1);
  --
  l_rt_cd_va(l_rt_en)       := 'WWBUGSPAY';
  l_rt_fromstr_va(l_rt_en)  := ' from ad_bugs abg ';
  l_rt_wherestr_va(l_rt_en) := ' where abg.last_update_date < '
                               ||' (select bft.last_update_date '
                               ||' from ben_benefit_actions bft '
                               ||' where bft.benefit_action_id = :benefit_action_id) '
                               ||' and abg.APPLICATION_SHORT_NAME = '||''''||'PAY'||'''';
  --
  l_rt_sqlstr_va(l_rt_en)   := l_sel_str
                               ||' '||l_rt_fromstr_va(l_rt_en)
                               ||' '||l_rt_wherestr_va(l_rt_en);
  --
  p_rt_cd_va       := l_rt_cd_va;
  p_rt_fromstr_va  := l_rt_fromstr_va;
  p_rt_wherestr_va := l_rt_wherestr_va;
  p_rt_sqlstr_va   := l_rt_sqlstr_va;
  --
end build_rollup_sql_str;
--
PROCEDURE get_rollup_code_sql_dets
  (p_rollup_code in            varchar2
  --
  ,p_from_str    in out nocopy varchar2
  ,p_where_str   in out nocopy varchar2
  ,p_sql_str     in out nocopy varchar2
  )
is
  --
  l_cd_va       benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_sqlstr_va   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_fromstr_va  benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_wherestr_va benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rbvtypcd_va benutils.g_v2_150_table := benutils.g_v2_150_table();
  --
begin
  --
  build_rollup_sql_str
    (p_rt_cd_va       => l_cd_va
    ,p_rt_fromstr_va  => l_fromstr_va
    ,p_rt_wherestr_va => l_wherestr_va
    ,p_rt_sqlstr_va   => l_sqlstr_va
    ,p_rt_typcd_va    => l_rbvtypcd_va
    );
  --
  if l_cd_va.count > 0
  then
    --
    for vaen in l_cd_va.first..l_cd_va.last
    loop
      --
      if upper(l_cd_va(vaen)) = upper(p_rollup_code)
      then
        --
/*
          --
          -- Temporary
          --
          dbms_output.put_line(' BENRBVRU: get_sql_dets: '||upper(l_cd_va(vaen))
                              ||' RC: '||upper(p_rollup_code)
                              );
          --
          dbms_output.put_line(' '||substr(l_wherestr_va(vaen),1,250));
          --
*/
        p_from_str  := l_fromstr_va(vaen);
        p_where_str := l_wherestr_va(vaen);
        p_sql_str   := l_sqlstr_va(vaen);
        --
        exit;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
end get_rollup_code_sql_dets;
--
PROCEDURE get_rollup_code_perid_va
  (p_rollup_code           in            varchar2
  ,p_old_benefit_action_id in            number
  ,p_new_benefit_action_id in            number
  --
  ,p_perid_va              in out nocopy benutils.g_number_table
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  c_per_list      cur_type;
  --
  l_old_perid_va  benutils.g_number_table := benutils.g_number_table();
  l_old_percnt_va benutils.g_number_table := benutils.g_number_table();
  l_new_perid_va  benutils.g_number_table := benutils.g_number_table();
  l_new_percnt_va benutils.g_number_table := benutils.g_number_table();
  l_mmperid_va    benutils.g_number_table := benutils.g_number_table();
  --
  l_sel_str       long;
  l_from_str      long;
  l_where_str     long;
  l_groupby_str   long;
  l_orderby_str   long;
  l_sql_str       long;
  --
  l_vaen          pls_integer;
  l_person_id     number;
  l_cnt           number;
  l_perid_match   boolean;
  l_mmvaen        pls_integer;
  --
  l_new_totcnt    pls_integer;
  l_old_totcnt    pls_integer;
  --
begin
  --
  -- Exclude non person related rollups
  --
  if instr(p_rollup_code,'WWBUGS') > 0
  then
    --
    -- Init collection
    --
    p_perid_va := l_mmperid_va;
    return;
    --
  else
    --
    if instr(p_rollup_code,'PERACT') > 0
    then
      --
      -- Build SQL statement to get PACT info
      --
      l_sel_str     := ' select pact.person_id, count(*) cnt ';
      l_from_str    := ' from ben_person_actions pact ';
      l_where_str   := ' where pact.benefit_action_id = :benefit_action_id ';
      l_groupby_str := ' group by pact.person_id ';
      l_orderby_str := ' order by count(*) desc ';
      --
    else
      --
      -- Get rollup sql details
      --
      ben_rollup_rbvs.get_rollup_code_sql_dets
        (p_rollup_code => p_rollup_code
        --
        ,p_from_str    => l_from_str
        ,p_where_str   => l_where_str
        ,p_sql_str     => l_sql_str
        );
      --
      -- Build SQL statement to get PACT info
      --
      l_sel_str     := 'select pact.person_id, count(*) cnt ';
      l_from_str    := l_from_str||', ben_person_actions pact ';
      l_where_str   := l_where_str||' and rbv.person_action_id = pact.person_action_id ';
      l_groupby_str := ' group by pact.person_id ';
      l_orderby_str := ' order by count(*) desc ';
      --
    end if;
    --
    l_sql_str     := l_sel_str
                     ||' '||l_from_str
                     ||' '||l_where_str
                     ||' '||l_groupby_str
                     ||' '||l_orderby_str;
    --
    l_vaen := 1;
    --
    open c_per_list FOR l_sql_str using p_old_benefit_action_id;
    loop
      l_person_id := null;
      l_cnt       := null;
      FETCH c_per_list INTO l_person_id,l_cnt;
      EXIT WHEN c_per_list%NOTFOUND;
      --
      l_old_perid_va.extend(1);
      l_old_percnt_va.extend(1);
      --
      l_old_perid_va(l_vaen)  := l_person_id;
      l_old_percnt_va(l_vaen) := l_cnt;
      l_vaen := l_vaen+1;
      --
    end loop;
    close c_per_list;
    --
    l_vaen := 1;
    --
    open c_per_list FOR l_sql_str using p_new_benefit_action_id;
    loop
      l_person_id := null;
      l_cnt       := null;
      FETCH c_per_list INTO l_person_id,l_cnt;
      EXIT WHEN c_per_list%NOTFOUND;
      --
      l_new_perid_va.extend(1);
      l_new_percnt_va.extend(1);
      --
      l_new_perid_va(l_vaen)  := l_person_id;
      l_new_percnt_va(l_vaen) := l_cnt;
      l_vaen := l_vaen+1;
      --
    end loop;
    close c_per_list;
    --
    -- Check differences between old and new list
    --
    if l_new_perid_va.count <> l_old_perid_va.count
    then
      --
      if l_new_perid_va.count > l_old_perid_va.count
      then
        --
        l_mmvaen := 1;
        --
        for vaen in l_new_perid_va.first..l_new_perid_va.last
        loop
          --
          l_perid_match := FALSE;
          --
          if l_old_perid_va.count > 0
          then
            --
            for subvaen in l_old_perid_va.first..l_old_perid_va.last
            loop
              --
              if l_old_perid_va(subvaen) = l_new_perid_va(vaen)
              then
                --
                l_perid_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_perid_match
            then
              --
              l_mmperid_va.extend(1);
              l_mmperid_va(l_mmvaen) := l_new_perid_va(vaen);
              l_mmvaen := l_mmvaen+1;
              --
            end if;
            --
          else
            --
            l_mmperid_va := l_new_perid_va;
            --
          end if;
          --
        end loop;
        --
      elsif l_old_perid_va.count > l_new_perid_va.count
      then
        --
        l_mmvaen := 1;
        --
        for vaen in l_old_perid_va.first..l_old_perid_va.last
        loop
          --
          l_perid_match := FALSE;
          --
          if l_new_perid_va.count > 0
          then
            --
            for subvaen in l_new_perid_va.first..l_new_perid_va.last
            loop
              --
              if l_new_perid_va(subvaen) = l_old_perid_va(vaen)
              then
                --
                l_perid_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_perid_match
            then
              --
              l_mmperid_va.extend(1);
              l_mmperid_va(l_mmvaen) := l_old_perid_va(vaen);
              l_mmvaen := l_mmvaen+1;
              --
            end if;
            --
          else
            --
            l_mmperid_va := l_old_perid_va;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    else
      --
      -- Check for person count totals
      --
      if l_new_perid_va.count > 0
      then
        --
        l_new_totcnt := 0;
        --
        for vaen in l_new_perid_va.first..l_new_perid_va.last
        loop
          --
          l_new_totcnt := l_new_totcnt+l_new_percnt_va(vaen);
          --
        end loop;
        --
      end if;
      --
      if l_old_perid_va.count > 0
      then
        --
        l_old_totcnt := 0;
        --
        for vaen in l_old_perid_va.first..l_old_perid_va.last
        loop
          --
          l_old_totcnt := l_old_totcnt+l_old_percnt_va(vaen);
          --
        end loop;
        --
      end if;
      --
      -- Check for person count descrepancies
      --
      if l_new_totcnt <> l_old_totcnt
      then
        --
        l_mmvaen := 1;
        --
        for vaen in l_new_perid_va.first..l_new_perid_va.last
        loop
          --
          l_perid_match := FALSE;
          --
          if l_old_perid_va.count > 0
          then
            --
            for subvaen in l_old_perid_va.first..l_old_perid_va.last
            loop
              --
              if l_old_perid_va(subvaen) = l_new_perid_va(vaen)
                and l_old_percnt_va(subvaen) = l_new_percnt_va(vaen)
              then
                --
                l_perid_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_perid_match
            then
              --
              l_mmperid_va.extend(1);
              l_mmperid_va(l_mmvaen) := l_new_perid_va(vaen);
              l_mmvaen := l_mmvaen+1;
              --
            end if;
            --
          else
            --
            l_mmperid_va := l_new_perid_va;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  p_perid_va := l_mmperid_va;
  --
end get_rollup_code_perid_va;
--
PROCEDURE get_oldnewcombkey_va
  (p_sql_str               in            varchar2
  ,p_old_benefit_action_id in            number
  ,p_new_benefit_action_id in            number
  ,p_keycol_cnt            in            number
  --
  ,p_old_perid_va          in out nocopy benutils.g_number_table
  ,p_old_combid_va         in out nocopy benutils.g_number_table
  ,p_old_combid2_va        in out nocopy benutils.g_number_table
  ,p_old_combid3_va        in out nocopy benutils.g_number_table
  ,p_old_combid4_va        in out nocopy benutils.g_number_table
  ,p_old_cnt_va            in out nocopy benutils.g_number_table
  ,p_new_perid_va          in out nocopy benutils.g_number_table
  ,p_new_combid_va         in out nocopy benutils.g_number_table
  ,p_new_combid2_va        in out nocopy benutils.g_number_table
  ,p_new_combid3_va        in out nocopy benutils.g_number_table
  ,p_new_combid4_va        in out nocopy benutils.g_number_table
  ,p_new_cnt_va            in out nocopy benutils.g_number_table
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  c_comb_list      cur_type;
  --
  l_old_perid_va   benutils.g_number_table := benutils.g_number_table();
  l_old_combid_va  benutils.g_number_table := benutils.g_number_table();
  l_old_combid2_va benutils.g_number_table := benutils.g_number_table();
  l_old_combid3_va benutils.g_number_table := benutils.g_number_table();
  l_old_combid4_va benutils.g_number_table := benutils.g_number_table();
  l_old_cnt_va     benutils.g_number_table := benutils.g_number_table();
  l_new_perid_va   benutils.g_number_table := benutils.g_number_table();
  l_new_combid_va  benutils.g_number_table := benutils.g_number_table();
  l_new_combid2_va benutils.g_number_table := benutils.g_number_table();
  l_new_combid3_va benutils.g_number_table := benutils.g_number_table();
  l_new_combid4_va benutils.g_number_table := benutils.g_number_table();
  l_new_cnt_va     benutils.g_number_table := benutils.g_number_table();
  --
  l_vaen           pls_integer;
  --
  l_person_id      number;
  l_comb_id        number;
  l_comb_id2       number;
  l_comb_id3       number;
  l_comb_id4       number;
  l_cnt            number;
  --
  l_keycol_cnt     number;
  --
begin
  --
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' BENRBVRU: get_oldnewcombkey_va: OldBFT: '||p_old_benefit_action_id
                          ||' NewBFT: '||p_new_benefit_action_id
                          );
      dbms_output.put_line(' '||substr(p_sql_str,1,250));
      --
*/
  l_old_perid_va.delete;
  l_old_cnt_va.delete;
  l_old_combid_va.delete;
  l_old_combid2_va.delete;
  l_old_combid3_va.delete;
  l_old_combid4_va.delete;
  l_new_perid_va.delete;
  l_new_cnt_va.delete;
  l_new_combid_va.delete;
  l_new_combid2_va.delete;
  l_new_combid3_va.delete;
  l_new_combid4_va.delete;
  --
  l_vaen := 1;
  --
  begin
    --
    open c_comb_list FOR p_sql_str using p_old_benefit_action_id;
    --
  exception
    when others then
      --
/*
        --
        -- Temporary
        --
        dbms_output.put_line('-- p_oldbftid: '||p_old_benefit_action_id);
        dbms_output.put_line('-- p_sql_str: '||substr(p_sql_str,1,200));
        --
*/
      --
      raise;
      --
  end;
  --
  loop
    --
    l_person_id := null;
    l_comb_id   := null;
    l_comb_id2  := null;
    l_comb_id3  := null;
    l_comb_id4  := null;
    l_cnt       := null;
    --
    if p_keycol_cnt = 0
    then
      --
      FETCH c_comb_list INTO l_person_id, l_cnt;
      --
    elsif p_keycol_cnt = 1
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id, l_cnt;
      --
    elsif p_keycol_cnt = 2
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id,l_comb_id2, l_cnt;
      --
    elsif p_keycol_cnt = 3
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id,l_comb_id2,l_comb_id3, l_cnt;
      --
    elsif p_keycol_cnt = 4
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id,l_comb_id2,l_comb_id3,l_comb_id4, l_cnt;
      --
    end if;
    --
    EXIT WHEN c_comb_list%NOTFOUND;
    --
    l_old_perid_va.extend(1);
    l_old_combid_va.extend(1);
    l_old_combid2_va.extend(1);
    l_old_combid3_va.extend(1);
    l_old_combid4_va.extend(1);
    l_old_cnt_va.extend(1);
    --
    l_old_perid_va(l_vaen)   := l_person_id;
    l_old_combid_va(l_vaen)  := l_comb_id;
    l_old_combid2_va(l_vaen) := l_comb_id2;
    l_old_combid3_va(l_vaen) := l_comb_id3;
    l_old_combid4_va(l_vaen) := l_comb_id4;
    l_old_cnt_va(l_vaen)     := l_cnt;
    l_vaen := l_vaen+1;
    --
  end loop;
  close c_comb_list;
  --
  l_vaen := 1;
  --
  begin
    --
    open c_comb_list FOR p_sql_str using p_new_benefit_action_id;
    --
  exception
    when others then
      --
/*
        --
        -- Temporary
        --
        dbms_output.put_line('-- p_newbftid: '||p_new_benefit_action_id);
        dbms_output.put_line('-- p_sql_str: '||substr(p_sql_str,1,200));
        --
*/
      --
      raise;
      --
  end;
  --
  loop
    --
    l_person_id := null;
    l_comb_id   := null;
    l_comb_id2  := null;
    l_comb_id3  := null;
    l_comb_id4  := null;
    l_cnt       := null;
    --
    if p_keycol_cnt = 0
    then
      --
      FETCH c_comb_list INTO l_person_id, l_cnt;
      --
    elsif p_keycol_cnt = 1
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id, l_cnt;
      --
    elsif p_keycol_cnt = 2
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id, l_comb_id2, l_cnt;
      --
    elsif p_keycol_cnt = 3
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id, l_comb_id2, l_comb_id3, l_cnt;
      --
    elsif p_keycol_cnt = 4
    then
      --
      FETCH c_comb_list INTO l_person_id,l_comb_id, l_comb_id2, l_comb_id3, l_comb_id4, l_cnt;
      --
    end if;
    --
    EXIT WHEN c_comb_list%NOTFOUND;
    --
    l_new_perid_va.extend(1);
    l_new_combid_va.extend(1);
    l_new_combid2_va.extend(1);
    l_new_combid3_va.extend(1);
    l_new_combid4_va.extend(1);
    l_new_cnt_va.extend(1);
    --
    l_new_perid_va(l_vaen)   := l_person_id;
    l_new_combid_va(l_vaen)  := l_comb_id;
    l_new_combid2_va(l_vaen) := l_comb_id2;
    l_new_combid3_va(l_vaen) := l_comb_id3;
    l_new_combid4_va(l_vaen) := l_comb_id4;
    l_new_cnt_va(l_vaen)     := l_cnt;
    l_vaen := l_vaen+1;
    --
  end loop;
  close c_comb_list;
  --
  p_old_perid_va   := l_old_perid_va;
  p_old_combid_va  := l_old_combid_va;
  p_old_combid2_va := l_old_combid2_va;
  p_old_combid3_va := l_old_combid3_va;
  p_old_combid4_va := l_old_combid4_va;
  p_old_cnt_va     := l_old_cnt_va;
  p_new_perid_va   := l_new_perid_va;
  p_new_combid_va  := l_new_combid_va;
  p_new_combid2_va := l_new_combid2_va;
  p_new_combid3_va := l_new_combid3_va;
  p_new_combid4_va := l_new_combid4_va;
  p_new_cnt_va     := l_new_cnt_va;
  --
end get_oldnewcombkey_va;
--
PROCEDURE get_rollup_code_combkey_va
  (p_rollup_code           in            varchar2
  ,p_old_benefit_action_id in            number
  ,p_new_benefit_action_id in            number
  --
  ,p_perid_va              in out nocopy benutils.g_number_table
  ,p_perlud_va             in out nocopy benutils.g_date_table
  ,p_combnm_va             in out nocopy benutils.g_varchar2_table
  ,p_combnm2_va            in out nocopy benutils.g_varchar2_table
  ,p_combnm3_va            in out nocopy benutils.g_varchar2_table
  ,p_combnm4_va            in out nocopy benutils.g_varchar2_table
  ,p_combid_va             in out nocopy benutils.g_number_table
  ,p_combid2_va            in out nocopy benutils.g_number_table
  ,p_combid3_va            in out nocopy benutils.g_number_table
  ,p_combid4_va            in out nocopy benutils.g_number_table
  ,p_cnt_va                in out nocopy benutils.g_number_table
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  c_rbvmaxlud      cur_type;
  --
  l_old_perid_va   benutils.g_number_table := benutils.g_number_table();
  l_old_combid_va  benutils.g_number_table := benutils.g_number_table();
  l_old_combid2_va benutils.g_number_table := benutils.g_number_table();
  l_old_combid3_va benutils.g_number_table := benutils.g_number_table();
  l_old_combid4_va benutils.g_number_table := benutils.g_number_table();
  l_old_cnt_va     benutils.g_number_table := benutils.g_number_table();
  l_new_perid_va   benutils.g_number_table := benutils.g_number_table();
  l_new_combid_va  benutils.g_number_table := benutils.g_number_table();
  l_new_combid2_va benutils.g_number_table := benutils.g_number_table();
  l_new_combid3_va benutils.g_number_table := benutils.g_number_table();
  l_new_combid4_va benutils.g_number_table := benutils.g_number_table();
  l_new_cnt_va     benutils.g_number_table := benutils.g_number_table();
  l_mmperid_va     benutils.g_number_table := benutils.g_number_table();
  l_mmperlud_va    benutils.g_date_table := benutils.g_date_table();
  l_mmcombnm_va    benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombnm2_va   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombnm3_va   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombnm4_va   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombid_va    benutils.g_number_table := benutils.g_number_table();
  l_mmcombid2_va   benutils.g_number_table := benutils.g_number_table();
  l_mmcombid3_va   benutils.g_number_table := benutils.g_number_table();
  l_mmcombid4_va   benutils.g_number_table := benutils.g_number_table();
  l_mmcnt_va       benutils.g_number_table := benutils.g_number_table();
  --
  l_keycol_str      long;
  --
  l_sel_str         long;
  l_from_str        long;
  l_where_str       long;
  l_groupby_str     long;
  l_orderby_str     long;
  l_sql_str         long;
  --
  l_perid_match     boolean;
  l_mmvaen          pls_integer;
  --
  l_new_totcnt      pls_integer;
  l_old_totcnt      pls_integer;
  --
  l_keycol_cnt      pls_integer;
  l_keycolnm        varchar2(100);
  l_keycolnm2       varchar2(100);
  l_keycolnm3       varchar2(100);
  l_keycolnm4       varchar2(100);
  l_fromclapp_str   long;
  l_whereclapp_str  long;
  --
  l_per_mxlud       date;
  l_perdata_changes boolean;
  l_mmcombid_cnt    pls_integer;
  l_mmcombid2_cnt   pls_integer;
  l_mmcombid3_cnt   pls_integer;
  l_mmcombid4_cnt   pls_integer;
  --
begin
  --
  -- Exclude non person related rollups
  --
  if instr(p_rollup_code,'WWBUGS') > 0
  then
    --
    -- Init collection
    --
    p_perid_va := l_mmperid_va;
    return;
    --
  --
  else
    --
    -- Hard coded need to make generic
    --
    l_keycol_cnt     := 0;
    l_fromclapp_str  := null;
    l_whereclapp_str := null;
    --
    if instr(p_rollup_code,'PEP') > 0
    then
      --
      l_keycol_cnt := 1;
      l_keycolnm   := 'PGM_ID';
      l_keycol_str := ',rbv.'||l_keycolnm||' ';
      --
      l_keycol_cnt := 2;
      l_keycolnm2  := 'PL_ID';
      l_keycol_str := l_keycol_str||',rbv.'||l_keycolnm2||' ';
      --
      l_keycol_cnt := 3;
      l_keycolnm3  := 'PLIP_ID';
      l_keycol_str := l_keycol_str||',rbv.'||l_keycolnm3||' ';
      --
      l_keycol_cnt := 4;
      l_keycolnm4  := 'PTIP_ID';
      l_keycol_str := l_keycol_str||',rbv.'||l_keycolnm4||' ';
      --
    elsif instr(p_rollup_code,'EPO') > 0
    then
      --
      l_keycol_cnt := 1;
      l_keycolnm   := 'OPT_ID';
      l_keycol_str := ',rbv.'||l_keycolnm||' ';
    --
    elsif instr(p_rollup_code,'EPE') > 0
    then
      --
      l_keycol_cnt := 1;
      l_keycolnm   := 'PGM_ID';
      l_keycol_str := ',rbv.'||l_keycolnm||' ';
      --
      l_keycol_cnt := 2;
      l_keycolnm2  := 'PL_ID';
      l_keycol_str := l_keycol_str||',rbv.'||l_keycolnm2||' ';
      --
    elsif instr(p_rollup_code,'PEN') > 0
    then
      --
      l_keycol_cnt := 1;
      l_keycolnm   := 'PL_ID';
      l_keycol_str := ',rbv.'||l_keycolnm||' ';
    --
    elsif instr(p_rollup_code,'PRV') > 0
    then
      --
      l_keycol_cnt := 1;
      l_keycolnm   := 'PL_ID';
      l_keycol_str := ',rbv1.'||l_keycolnm||' ';
      --
      l_fromclapp_str  := ', ben_prtt_enrt_rslt_f rbv1 ';
      l_whereclapp_str := ' and rbv.PRTT_ENRT_RSLT_ID = rbv1.PRTT_ENRT_RSLT_ID ';
      --
    else
      --
      l_keycol_cnt := 0;
      l_keycol_str := ' ';
      --
    end if;
    --
    -- Get rollup sql details
    --
    ben_rollup_rbvs.get_rollup_code_sql_dets
      (p_rollup_code => p_rollup_code
      --
      ,p_from_str    => l_from_str
      ,p_where_str   => l_where_str
      ,p_sql_str     => l_sql_str
      );
    --
    -- Check for person action rollup types
    --
    if instr(p_rollup_code,'PERACT') > 0
    then
      --
      -- Build SQL statement to get PACT info
      --
      l_sel_str     := ' select pact.person_id, count(*) cnt ';
      l_from_str    := l_from_str;
      l_where_str   := l_where_str;
      l_groupby_str := ' group by pact.person_id ';
      l_orderby_str := ' order by 1 desc ';
      --
    else
/*
        --
        -- Temporary
        --
        dbms_output.put_line('- BENRBVRU: Roll: '||p_rollup_code
                            ||' FrCL: '||l_from_str
                            ||' WhCL: '||l_where_str
                            );
        dbms_output.put_line('-- l_keycol_str: '||l_keycol_str
                            );
        --
*/
      --
      -- Build SQL statement to get PACT info
      --
      l_sel_str     := 'select pact.person_id '||l_keycol_str||', count(*) cnt ';
      l_from_str    := l_from_str||', ben_person_actions pact ';
      l_where_str   := l_where_str||' and rbv.person_action_id = pact.person_action_id ';
      l_groupby_str := ' group by pact.person_id '||l_keycol_str;
      l_orderby_str := ' order by 1 desc ';
      --
    end if;
    --
    -- Add to from and where clauses for foreign key references
    --
    if l_fromclapp_str is not null
      or l_whereclapp_str is not null
    then
      --
      l_from_str  := l_from_str||' '||l_fromclapp_str;
      l_where_str := l_where_str||' '||l_whereclapp_str;
      --
    end if;
    --
    l_sql_str     := l_sel_str
                     ||' '||l_from_str
                     ||' '||l_where_str
                     ||' '||l_groupby_str
                     ||' '||l_orderby_str;
    --
    get_oldnewcombkey_va
      (p_sql_str               => l_sql_str
      ,p_old_benefit_action_id => p_old_benefit_action_id
      ,p_new_benefit_action_id => p_new_benefit_action_id
      ,p_keycol_cnt            => l_keycol_cnt
      --
      ,p_old_perid_va          => l_old_perid_va
      ,p_old_combid_va         => l_old_combid_va
      ,p_old_combid2_va        => l_old_combid2_va
      ,p_old_combid3_va        => l_old_combid3_va
      ,p_old_combid4_va        => l_old_combid4_va
      ,p_old_cnt_va            => l_old_cnt_va
      ,p_new_perid_va          => l_new_perid_va
      ,p_new_combid_va         => l_new_combid_va
      ,p_new_combid2_va        => l_new_combid2_va
      ,p_new_combid3_va        => l_new_combid3_va
      ,p_new_combid4_va        => l_new_combid4_va
      ,p_new_cnt_va            => l_new_cnt_va
      );
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' First: l_new_perid_va.count: '||l_new_perid_va.count
                          ||' l_old_perid_va.count: '||l_old_perid_va.count
                          ||' OCMIDCnt: '||l_old_combid_va.count
                          ||' OCMID2Cnt: '||l_old_combid2_va.count
                          ||' OCMID3Cnt: '||l_old_combid3_va.count
                          );
      --
*/
    --
    -- Check if any rows were found if not then re-try with rollup type
    -- specific criteria
    --
    if l_new_perid_va.count = 0
      and l_old_perid_va.count = 0
    then
      --
      if instr(p_rollup_code,'PRV') > 0
      then
        --
        -- Join to live table rather than RBV table
        --
        l_keycol_cnt := 1;
        l_keycolnm   := 'PL_ID';
        l_keycol_str := ',rbv1.'||l_keycolnm||' ';
        --
        l_fromclapp_str  := ', ben_prtt_enrt_rslt_f_rbv rbv1 ';
        l_whereclapp_str := ' and rbv.PRTT_ENRT_RSLT_ID = rbv1.PRTT_ENRT_RSLT_ID ';
        --
        -- Get rollup sql details
        --
        ben_rollup_rbvs.get_rollup_code_sql_dets
          (p_rollup_code => p_rollup_code
          --
          ,p_from_str    => l_from_str
          ,p_where_str   => l_where_str
          ,p_sql_str     => l_sql_str
          );
        --
        -- Build SQL statement to get PACT info
        --
        l_sel_str     := 'select pact.person_id '||l_keycol_str||', count(*) cnt ';
        l_from_str    := l_from_str||', ben_person_actions pact ';
        l_where_str   := l_where_str||' and rbv.person_action_id = pact.person_action_id ';
        l_groupby_str := ' group by pact.person_id '||l_keycol_str;
        l_orderby_str := ' order by 1 desc ';
        --
        -- Add to from and where clauses for foreign key references
        --
        if l_fromclapp_str is not null
          or l_whereclapp_str is not null
        then
          --
          l_from_str  := l_from_str||' '||l_fromclapp_str;
          l_where_str := l_where_str||' '||l_whereclapp_str;
          --
        end if;
        --
        l_sql_str     := l_sel_str
                         ||' '||l_from_str
                         ||' '||l_where_str
                         ||' '||l_groupby_str
                         ||' '||l_orderby_str;
        --
        get_oldnewcombkey_va
          (p_sql_str               => l_sql_str
          ,p_old_benefit_action_id => p_old_benefit_action_id
          ,p_new_benefit_action_id => p_new_benefit_action_id
          ,p_keycol_cnt            => l_keycol_cnt
          --
          ,p_old_perid_va          => l_old_perid_va
          ,p_old_combid_va         => l_old_combid_va
          ,p_old_combid2_va        => l_old_combid2_va
          ,p_old_combid3_va        => l_old_combid3_va
          ,p_old_combid4_va        => l_old_combid4_va
          ,p_old_cnt_va            => l_old_cnt_va
          ,p_new_perid_va          => l_new_perid_va
          ,p_new_combid_va         => l_new_combid_va
          ,p_new_combid2_va        => l_new_combid2_va
          ,p_new_combid3_va        => l_new_combid3_va
          ,p_new_combid4_va        => l_new_combid4_va
          ,p_new_cnt_va            => l_new_cnt_va
          );
        --
      end if;
      --
    end if;
    --
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' Second: OBFTID: '||p_old_benefit_action_id
                          ||' NBFTID: '||p_new_benefit_action_id
                          ||' RlCd: '||p_rollup_code
                          ||' Nperid cnt: '||l_new_perid_va.count
                          ||' Operid cnt: '||l_old_perid_va.count
                          ||' OCMIDCnt: '||l_old_combid_va.count
                          ||' OCMID2Cnt: '||l_old_combid2_va.count
                          ||' OCMID3Cnt: '||l_old_combid3_va.count
                          );
      --
      dbms_output.put_line(' - NCMIDCnt: '||l_new_combid_va.count
                          ||' NCMID2Cnt: '||l_new_combid2_va.count
                          ||' NCMID3Cnt: '||l_new_combid3_va.count
                          );
      --
*/
    --
    -- Check differences between old and new list
    --
    l_mmperid_va.delete;
    l_mmcombid_va.delete;
    l_mmcombid2_va.delete;
    l_mmcombid3_va.delete;
    l_mmcombid4_va.delete;
    l_mmcnt_va.delete;
    --
    l_mmcombid_cnt  := l_mmcombid_va.count;
    l_mmcombid2_cnt := l_mmcombid2_va.count;
    l_mmcombid3_cnt := l_mmcombid3_va.count;
    l_mmcombid4_cnt := l_mmcombid4_va.count;
    --
    if l_new_perid_va.count <> l_old_perid_va.count
    then
      --
      if l_new_perid_va.count > l_old_perid_va.count
      then
        --
        l_mmvaen := 1;
        --
        for vaen in l_new_perid_va.first..l_new_perid_va.last
        loop
          --
          l_perid_match := FALSE;
          --
          if l_old_perid_va.count > 0
          then
            --
            for subvaen in l_old_perid_va.first..l_old_perid_va.last
            loop
              --
              if l_old_perid_va(subvaen) = l_new_perid_va(vaen)
                and nvl(l_old_combid_va(subvaen),-999) = nvl(l_new_combid_va(vaen),-999)
                and nvl(l_old_combid2_va(subvaen),-999) = nvl(l_new_combid2_va(vaen),-999)
                and nvl(l_old_combid3_va(subvaen),-999) = nvl(l_new_combid3_va(vaen),-999)
                and nvl(l_old_combid4_va(subvaen),-999) = nvl(l_new_combid4_va(vaen),-999)
              then
                --
                l_perid_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_perid_match
            then
              --
              l_mmperid_va.extend(1);
              l_mmcnt_va.extend(1);
              l_mmperid_va(l_mmvaen)   := l_new_perid_va(vaen);
              l_mmcnt_va(l_mmvaen)     := l_new_cnt_va(vaen);
              --
              l_mmcombid_va.extend(1);
              l_mmcombid_va(l_mmvaen) := l_new_combid_va(vaen);
              --
              l_mmcombid2_va.extend(1);
              l_mmcombid2_va(l_mmvaen) := l_new_combid2_va(vaen);
              --
              l_mmcombid3_va.extend(1);
              l_mmcombid3_va(l_mmvaen) := l_new_combid3_va(vaen);
              --
              l_mmcombid4_va.extend(1);
              l_mmcombid4_va(l_mmvaen) := l_new_combid4_va(vaen);
              --
              l_mmvaen := l_mmvaen+1;
              --
            end if;
            --
          else
            --
            l_mmperid_va   := l_new_perid_va;
            l_mmcombid_va  := l_new_combid_va;
            l_mmcombid2_va := l_new_combid2_va;
            l_mmcombid3_va := l_new_combid3_va;
            l_mmcombid4_va := l_new_combid4_va;
            l_mmcnt_va     := l_new_cnt_va;
            --
          end if;
          --
        end loop;
        --
      elsif l_old_perid_va.count > l_new_perid_va.count
      then
        --
        l_mmvaen := 1;
        --
        for vaen in l_old_perid_va.first..l_old_perid_va.last
        loop
          --
          l_perid_match := FALSE;
          --
          if l_new_perid_va.count > 0
          then
            --
            for subvaen in l_new_perid_va.first..l_new_perid_va.last
            loop
              --
              if l_new_perid_va(subvaen) = l_old_perid_va(vaen)
                and nvl(l_new_combid_va(subvaen),999)  = nvl(l_old_combid_va(vaen),999)
                and nvl(l_new_combid2_va(subvaen),999) = nvl(l_old_combid2_va(vaen),999)
                and nvl(l_new_combid3_va(subvaen),999) = nvl(l_old_combid3_va(vaen),999)
                and nvl(l_new_combid4_va(subvaen),999) = nvl(l_old_combid4_va(vaen),999)
              then
                --
                l_perid_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_perid_match
            then
              --
              l_mmperid_va.extend(1);
              l_mmcnt_va.extend(1);
              l_mmperid_va(l_mmvaen)   := l_old_perid_va(vaen);
              l_mmcnt_va(l_mmvaen)     := l_old_cnt_va(vaen);
              --
              l_mmcombid_va.extend(1);
              l_mmcombid_va(l_mmvaen) := l_old_combid_va(vaen);
              --
              l_mmcombid2_va.extend(1);
              l_mmcombid2_va(l_mmvaen) := l_old_combid2_va(vaen);
              --
              l_mmcombid3_va.extend(1);
              l_mmcombid3_va(l_mmvaen) := l_old_combid3_va(vaen);
              --
              l_mmcombid4_va.extend(1);
              l_mmcombid4_va(l_mmvaen) := l_old_combid4_va(vaen);
              --
              l_mmvaen := l_mmvaen+1;
              --
            end if;
            --
          else
            --
            l_mmperid_va   := l_old_perid_va;
            l_mmcombid_va  := l_old_combid_va;
            l_mmcombid2_va := l_old_combid2_va;
            l_mmcombid3_va := l_old_combid3_va;
            l_mmcombid4_va := l_old_combid4_va;
            l_mmcnt_va     := l_old_cnt_va;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    else
      --
      -- Check for count totals
      --
      if l_new_perid_va.count > 0
      then
        --
        l_new_totcnt := 0;
        --
        for vaen in l_new_perid_va.first..l_new_perid_va.last
        loop
          --
          l_new_totcnt := l_new_totcnt+l_new_cnt_va(vaen);
          --
        end loop;
        --
      end if;
      --
      if l_old_perid_va.count > 0
      then
        --
        l_old_totcnt := 0;
        --
        for vaen in l_old_perid_va.first..l_old_perid_va.last
        loop
          --
          l_old_totcnt := l_old_totcnt+l_old_cnt_va(vaen);
          --
        end loop;
        --
      end if;
      --
      -- Check for person count descrepancies
      --
  /*
          --
          -- Temporary
          --
          dbms_output.put_line(' l_new_totcnt: '||l_new_totcnt
                              ||' l_old_totcnt: '||l_old_totcnt
                              );
          --
*/
      if l_new_totcnt <> l_old_totcnt
      then
        --
        l_mmvaen := 1;
        --
        for vaen in l_new_perid_va.first..l_new_perid_va.last
        loop
          --
          l_perid_match := FALSE;
          --
          if l_old_perid_va.count > 0
          then
            --
            for subvaen in l_old_perid_va.first..l_old_perid_va.last
            loop
              --
              if l_old_perid_va(subvaen) = l_new_perid_va(vaen)
                and nvl(l_old_combid_va(subvaen),-999) = nvl(l_new_combid_va(vaen),-999)
                and nvl(l_old_combid2_va(subvaen),-999) = nvl(l_new_combid2_va(vaen),-999)
                and nvl(l_old_combid3_va(subvaen),-999) = nvl(l_new_combid3_va(vaen),-999)
                and nvl(l_old_combid4_va(subvaen),-999) = nvl(l_new_combid4_va(vaen),-999)
                and l_old_cnt_va(subvaen) = l_new_cnt_va(vaen)
              then
                --
                l_perid_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_perid_match
            then
              --
              l_mmperid_va.extend(1);
              l_mmcnt_va.extend(1);
              l_mmperid_va(l_mmvaen)   := l_new_perid_va(vaen);
              l_mmcnt_va(l_mmvaen)     := l_new_cnt_va(vaen);
              --
              l_mmcombid_va.extend(1);
              l_mmcombid_va(l_mmvaen) := l_new_combid_va(vaen);
              --
              l_mmcombid2_va.extend(1);
              l_mmcombid2_va(l_mmvaen) := l_new_combid2_va(vaen);
              --
              l_mmcombid3_va.extend(1);
              l_mmcombid3_va(l_mmvaen) := l_new_combid3_va(vaen);
              --
              l_mmcombid4_va.extend(1);
              l_mmcombid4_va(l_mmvaen) := l_new_combid4_va(vaen);
/*
                --
                -- Temporary
                --
                dbms_output.put_line(' mmperid: '||l_mmperid_va(l_mmvaen)
                                    );
                --
                dbms_output.put_line(' mmcombid: '||l_mmcombid_va(l_mmvaen)
                                    );
                --
*/
              l_mmvaen := l_mmvaen+1;
              --
            end if;
            --
          else
            --
            l_mmperid_va   := l_new_perid_va;
            l_mmcombid_va  := l_new_combid_va;
            l_mmcombid2_va := l_new_combid2_va;
            l_mmcombid3_va := l_new_combid3_va;
            l_mmcombid4_va := l_new_combid4_va;
            l_mmcnt_va     := l_new_cnt_va;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    end if;
    --
    -- Populate the combination name varray
    --
    if l_mmcombid_va.count > 0
    then
      --
      l_mmcombnm_va.delete;
      l_mmcombnm2_va.delete;
      l_mmcombnm3_va.delete;
      l_mmcombnm4_va.delete;
      --
      l_mmcombid_cnt  := l_mmcombid_va.count;
      l_mmcombid2_cnt := l_mmcombid2_va.count;
      l_mmcombid3_cnt := l_mmcombid3_va.count;
      l_mmcombid4_cnt := l_mmcombid4_va.count;
      --
      for vaen in l_mmcombid_va.first..l_mmcombid_va.last
      loop
        --
        if l_mmcombid_cnt > 0
        then
          --
          l_mmcombnm_va.extend(1);
          l_mmcombnm_va(vaen) := l_keycolnm;
          --
        end if;
        --
        if l_mmcombid2_cnt > 0
        then
          --
          l_mmcombnm2_va.extend(1);
          l_mmcombnm2_va(vaen) := l_keycolnm2;
          --
        end if;
        --
        if l_mmcombid3_cnt > 0
        then
          --
          l_mmcombnm3_va.extend(1);
          l_mmcombnm3_va(vaen) := l_keycolnm3;
          --
        end if;
        --
        if l_mmcombid4_cnt > 0
        then
          --
          l_mmcombnm4_va.extend(1);
          l_mmcombnm4_va(vaen) := l_keycolnm4;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Populate the last update date from live table
    --
/*
      --
      -- Debugging
      --
      dbms_output.put_line(' BENRBVRU: l_mmperid_va.count: '||l_mmperid_va.count
                          ||' l_mmcombid_va.count: '||l_mmcombid_va.count
                          );
      --
*/
    if l_mmperid_va.count > 0
    then
      --
      l_sql_str         := null;
      l_perdata_changes := FALSE;
      --
      if instr(p_rollup_code,'PIL') > 0
      then
        --
        -- Build SQL statement to get PACT info
        --
        l_sel_str     := ' select max(rbv.last_update_date) ';
        l_from_str    := ' from ben_per_in_ler rbv ';
        l_where_str   := ' where person_id = :person_id ';
        --
        l_sql_str     := l_sel_str
                         ||' '||l_from_str
                         ||' '||l_where_str;
        --
      end if;
      --
      if l_sql_str is not null
      then
        --
        for vaen in l_mmperid_va.first..l_mmperid_va.last
        loop
          --
          l_per_mxlud := null;
          --
          open c_rbvmaxlud FOR l_sql_str using l_mmperid_va(vaen);
          fetch c_rbvmaxlud into l_per_mxlud;
          --
          if l_per_mxlud is not null
          then
            --
            l_perdata_changes := TRUE;
            --
          end if;
          --
          close c_rbvmaxlud;
          --
          l_mmperlud_va.extend(1);
          l_mmperlud_va(vaen) := l_per_mxlud;
          --
        end loop;
        --
      end if;
      --
      -- Check if any changes were found
      --
      if not l_perdata_changes
      then
        --
        -- Build SQL statement to check PPL information
        --
        -- Note: exclude out future changes caused by tweaking db date
        --
        l_sel_str     := ' select max(ppl.last_update_date) ';
        l_from_str    := ' from ben_ptnl_ler_for_per ppl ';
        l_where_str   := ' where ppl.person_id = :person_id '
                         ||' and ppl.last_update_date < sysdate ';
        --
        l_sql_str     := l_sel_str
                         ||' '||l_from_str
                         ||' '||l_where_str;
        --
        for vaen in l_mmperid_va.first..l_mmperid_va.last
        loop
          --
          l_per_mxlud := null;
          --
          open c_rbvmaxlud FOR l_sql_str using l_mmperid_va(vaen);
          fetch c_rbvmaxlud into l_per_mxlud;
          --
          if l_per_mxlud is not null
          then
            --
            l_perdata_changes := TRUE;
            --
          end if;
          --
          close c_rbvmaxlud;
          --
          l_mmperlud_va.extend(1);
          l_mmperlud_va(vaen) := l_per_mxlud;
          --
        end loop;
        --
      end if;
      --
    end if;
    --
  end if;
  --
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' - MMCMIDCnt: '||l_mmcombid_va.count
                          ||' MMCMID2Cnt: '||l_mmcombid2_va.count
                          ||' MMCMID3Cnt: '||l_mmcombid3_va.count
                          );
      --
*/
  p_perid_va   := l_mmperid_va;
  p_perlud_va  := l_mmperlud_va;
  p_combnm_va  := l_mmcombnm_va;
  p_combnm2_va := l_mmcombnm2_va;
  p_combnm3_va := l_mmcombnm3_va;
  p_combnm4_va := l_mmcombnm4_va;
  p_combid_va  := l_mmcombid_va;
  p_combid2_va := l_mmcombid2_va;
  p_combid3_va := l_mmcombid3_va;
  p_combid4_va := l_mmcombid4_va;
  p_cnt_va     := l_mmcnt_va;
  --
end get_rollup_code_combkey_va;
--
PROCEDURE rollup_benmngle_rbvs
  (p_benefit_action_id in     number
  ,p_refresh_rollups   in     varchar2 default 'N'
  )
IS
  --
  TYPE cur_type IS REF CURSOR;
  --
  type t_v2_4000_va is varray(10000000) of varchar2(4000);
  --
  type t_rbvsum_rec is record
    (cnt     number
    ,sum_ovn number
    ,min_esd date
    ,min_eed date
    );
  --
  type t_rbvdet_rec is record
    (id_str    varchar2(4000)
    ,date_str  varchar2(4000)
    ,value_str varchar2(4000)
    );
  --
  c_rbv_summary           cur_type;
  c_rbv_detail            cur_type;
  --
  l_rbv_summary_row       t_rbvsum_rec;
  l_rbv_detail_row        t_rbvdet_rec;
  --
  l_cd_va                 benutils.g_v2_150_table   := benutils.g_v2_150_table();
  l_sqlstr_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_fromstr_va            benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_wherestr_va           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rbvtypcd_va           benutils.g_v2_150_table   := benutils.g_v2_150_table();
  --
  l_batch_id_va           benutils.g_number_table := benutils.g_number_table();
  l_batch_type_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_class_code_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_class_code_count_va   benutils.g_number_table := benutils.g_number_table();
  l_class_sumovn_va       benutils.g_number_table := benutils.g_number_table();
  l_class_minesd_va       benutils.g_date_table   := benutils.g_date_table();
  l_class_mineed_va       benutils.g_date_table   := benutils.g_date_table();
  l_class_idstr_va        t_v2_4000_va := t_v2_4000_va();
  l_class_datestr_va      t_v2_4000_va := t_v2_4000_va();
  l_class_valuestr_va     t_v2_4000_va := t_v2_4000_va();
  --
  l_id_str                varchar2(4000);
  l_date_str              varchar2(4000);
  l_value_str             varchar2(4000);
  --
  l_cnt                   number;
  l_rollup_id             number;
  --
  l_rollupcnt_tot         number;
  l_rollupsumovn_tot      number;
  --
  l_batch_action_id       number;
  --
  cursor c_bft_dets
    (c_bft_id number
    )
  is
    select bft.validate_flag
    from ben_benefit_actions bft
    where bft.validate_flag in ('C','B')
    and bft.benefit_action_id = c_bft_id;
  --
  l_bft_dets  c_bft_dets%rowtype;
  --
  cursor c_rubft_dets
    (c_bft_id number
    )
  is
    select bat.batch_id
    from ben_batch_actions bat
    where bat.batch_id = c_bft_id;
  --
  l_rubft_dets  c_rubft_dets%rowtype;
  --
BEGIN
  --
  open c_bft_dets
    (c_bft_id => p_benefit_action_id
    );
  fetch c_bft_dets into l_bft_dets;
  if c_bft_dets%notfound then
    --
    close c_bft_dets;
    return;
    --
  end if;
  close c_bft_dets;
  --
  if nvl(p_refresh_rollups,'N') <> 'Y'
  then
    --
    open c_rubft_dets
      (c_bft_id => p_benefit_action_id
      );
    fetch c_rubft_dets into l_rubft_dets;
    if c_rubft_dets%found then
      --
      close c_rubft_dets;
      return;
      --
    end if;
    close c_rubft_dets;
    --
  end if;
  --
  if l_bft_dets.validate_flag in ('C','B')
  then
    --
    if nvl(p_refresh_rollups,'N') = 'Y'
    then
      --
      delete from ben_rollup_rbv_summary rlp
      where exists
        (select 1
         from ben_batch_actions bba
         where bba.batch_action_id = rlp.batch_action_id
         and bba.batch_id = p_benefit_action_id
        );
      --
      delete from ben_batch_actions bba
      where bba.batch_id = p_benefit_action_id;
      --
    end if;
    --
    -- Build the rollup SQL statement
    --
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' BENRBVRU: BFTID: '||p_benefit_action_id);
      --
*/
    build_rollup_sql_str
      (p_rt_cd_va       => l_cd_va
      ,p_rt_fromstr_va  => l_fromstr_va
      ,p_rt_wherestr_va => l_wherestr_va
      ,p_rt_sqlstr_va   => l_sqlstr_va
      ,p_rt_typcd_va    => l_rbvtypcd_va
      );
    --
    -- Populate the rollup type details
    --
    l_rollupcnt_tot    := 0;
    l_rollupsumovn_tot := 0;
    --
    for va_en in l_sqlstr_va.first..l_sqlstr_va.last
    loop
      --
      begin
        --
        open c_rbv_summary FOR l_sqlstr_va(va_en) using p_benefit_action_id;
        FETCH c_rbv_summary INTO l_rbv_summary_row;
        if c_rbv_summary%notfound
        then
          --
          l_rbv_summary_row.cnt := 0;
          l_rbv_summary_row.sum_ovn := 0;
          l_rbv_summary_row.min_esd := hr_api.g_sot;
          l_rbv_summary_row.min_eed := hr_api.g_eot;
          --
        end if;
        close c_rbv_summary;
        --
      exception
        when others then
/*
            --
            -- Temporary
            --
            dbms_output.put_line(' BENRBVRU: Roll: '||l_cd_va(va_en));
            dbms_output.put_line(' - '||substr(l_sqlstr_va(va_en),1,200));

            --
*/
          --
          -- Special case for new tables that are not patched in
          --
          l_rbv_summary_row.cnt     := 0;
          l_rbv_summary_row.sum_ovn := 0;
          l_rbv_summary_row.min_esd := hr_api.g_sot;
          l_rbv_summary_row.min_eed := hr_api.g_eot;
          --
      end;
      --
/*
      if l_rt_cd_va(va_en) = 'PEP'
      then
        --
        -- Get ID columns
        --
        l_sel_str := ' select PGM_ID||PTIP_ID||PLIP_ID||PL_ID||MUST_ENRL_ANTHR_PL_ID id_str, '
                     ||' null date_str, '
                     ||' null value_str ';
        --
        l_sql_str := l_sel_str
                     ||' '||l_rt_fromstr_va(va_en)
                     ||' '||l_rt_wherestr_va(va_en);
        --
        l_id_str    := ' ';
        l_date_str  := ' ';
        l_value_str := ' ';
        --
        open c_rbv_detail FOR l_sql_str using p_benefit_action_id;
        loop
          FETCH c_rbv_detail INTO l_rbv_detail_row;
          EXIT WHEN c_rbv_detail%NOTFOUND;
          --
          begin
            --
            l_id_str    := nvl(l_id_str,' ')||' '||l_rbv_detail_row.id_str;
            --
          exception
            when others then
              --
              null;
              --
          end;
          --
          l_date_str  := nvl(l_date_str,' ')||' '||l_rbv_detail_row.date_str;
          l_value_str := nvl(l_value_str,' ')||' '||l_rbv_detail_row.value_str;
          --
        end loop;
        close c_rbv_detail;
        --
      end if;
*/
      --
      l_batch_id_va.extend(1);
      l_batch_type_va.extend(1);
      l_class_code_va.extend(1);
      l_class_code_count_va.extend(1);
      l_class_sumovn_va.extend(1);
      l_class_minesd_va.extend(1);
      l_class_mineed_va.extend(1);
      l_class_idstr_va.extend(1);
      l_class_datestr_va.extend(1);
      l_class_valuestr_va.extend(1);
      --
      l_batch_id_va(va_en)         := p_benefit_action_id;
      l_batch_type_va(va_en)       := 'BEN_BFT';
      l_class_code_va(va_en)       := l_cd_va(va_en);
      l_class_code_count_va(va_en) := l_rbv_summary_row.cnt;
      l_class_sumovn_va(va_en)     := l_rbv_summary_row.sum_ovn;
      l_class_minesd_va(va_en)     := l_rbv_summary_row.min_esd;
      l_class_mineed_va(va_en)     := l_rbv_summary_row.min_eed;
      l_class_idstr_va(va_en)      := l_id_str;
      l_class_datestr_va(va_en)    := l_date_str;
      l_class_valuestr_va(va_en)   := l_value_str;
      --
      l_rollupcnt_tot    := l_rollupcnt_tot+l_class_code_count_va(va_en);
      l_rollupsumovn_tot := l_rollupsumovn_tot+l_class_sumovn_va(va_en);
      --
    end loop;
    --
    if l_batch_id_va.count > 0
    then
      --
      -- Insert a batch action
      --
      insert into ben_batch_actions
        (batch_action_id
        ,batch_id
        ,batch_type
        ,rollup_count
        ,rollup_sumovn
        )
      values
        (ben_batch_actions_s.nextval
        ,p_benefit_action_id
        ,'BEN_BFT'
        ,l_rollupcnt_tot
        ,l_rollupsumovn_tot
        ) RETURNING batch_action_id into l_batch_action_id;
      --
      if l_rollupcnt_tot > 0
      then
        --
        for va_en in l_batch_id_va.first ..l_batch_id_va.last
        loop
          --
          insert into ben_rollup_rbv_summary
            (rollup_id
            ,batch_action_id
            ,rollup_code
            ,rollup_count
            ,rollup_sumovn
            ,rollup_minesd
            ,rollup_mineed
            ,rollup_id_string
            ,rollup_date_string
            ,rollup_value_string
            )
          values
            (ben_rollup_rbv_summary_s.nextval
            ,l_batch_action_id
            ,l_class_code_va(va_en)
            ,l_class_code_count_va(va_en)
            ,l_class_sumovn_va(va_en)
            ,l_class_minesd_va(va_en)
            ,l_class_mineed_va(va_en)
            ,l_class_idstr_va(va_en)
            ,l_class_datestr_va(va_en)
            ,l_class_valuestr_va(va_en)
            ) RETURNING rollup_id into l_rollup_id;
          --
        end loop;
        --
      end if;
      --
    end if;
    --
  end if;
  --
END rollup_benmngle_rbvs;
--
end ben_rollup_rbvs;

/
