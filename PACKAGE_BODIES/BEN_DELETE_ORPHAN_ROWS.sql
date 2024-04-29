--------------------------------------------------------
--  DDL for Package Body BEN_DELETE_ORPHAN_ROWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DELETE_ORPHAN_ROWS" as
 /* $Header: bedeorph.pkb 120.0.12010000.3 2008/08/05 14:21:29 ubhat ship $ */
 --
 -- Global Variable Declaration
 --
 g_package          varchar2(80) := 'ben_delete_orphan_rows';
 g_request_tbl      g_request_table;
 g_num_processes    number := 0;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< check_all_slaves_finished >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This procedure will make sure all the slaves belong to the master process
 -- are completed before exit the loop.
 --
 procedure check_all_slaves_finished (p_rpt_flag  Boolean default FALSE)
 is
   --
   l_proc		varchar2(80) := g_package || '.check_all_slaves_finished';
   l_no_slaves		boolean := true;
   l_dummy		varchar2(1);
   --
   Cursor c_slaves(p_request_id number) is
   SELECT NULL
     FROM fnd_concurrent_requests fnd
    WHERE fnd.phase_code <> 'C' AND fnd.request_id = p_request_id;
   --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   While l_no_slaves loop
     --
     l_no_slaves := false;
     --
     For l_count in 2..g_num_processes loop
       --
       open c_slaves(g_request_tbl(l_count));
         fetch c_slaves into l_dummy;
         --
         If c_slaves%found then
	   --
           l_no_slaves := true;
           close c_slaves;
           exit;
	   --
         End if;
	 --
       Close c_slaves;
       --
     End loop;
     If (l_no_slaves) then
       --
       dbms_lock.sleep(5);
       --
     End if;
     --
   End loop;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end check_all_slaves_finished;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_per_con >--------------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from PER_CONTACT_RELATIOSHSHIPS
 -- where deleted person_id is directly referenced.
 --
 procedure delete_per_con
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_per_con';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   delete /*+ parallel(a) */ from per_contact_relationships a
   where a.contact_person_id is not null
   and   a.contact_person_id not in ( select /*+ hash_aj index_ffs(ppf) parallel_index(ppf) */ person_id
                                     from   per_all_people_f ppf );
   --
   delete /*+ parallel(a) */ from per_contact_relationships a
   where a.person_id is not null
   and   a.person_id not in ( select /*+ hash_aj index_ffs(ppf) parallel_index(ppf) */ person_id
                             from   per_all_people_f ppf );
   --

   ben_batch_utils.write(p_text => 'PER_CONTACT_RELATIOSHSHIPS           : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_per_con;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_cbr_quald_bnf >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_CBR_QUALD_BNF
 -- where deleted person_id is directly referenced.
 --
 procedure delete_cbr_quald_bnf
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_cbr_quald_bnf';
   --
 --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_cbr_quald_bnf a
         WHERE NOT EXISTS (SELECT 1
                             FROM per_all_people_f per
                            WHERE per.person_id = a.cvrd_emp_person_id);
   --
   --
   ben_batch_utils.write(p_text => 'BEN_CBR_QUALD_BNF          : ' || nvl(to_char(SQL%ROWCOUNT),'0'));

   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_cbr_quald_bnf;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_crt_ordr >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_CRT_ORDR
 -- where deleted person_id is directly referenced.
 --
 procedure delete_crt_ordr
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_crt_ordr';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_crt_ordr a
         WHERE NOT EXISTS (SELECT 1
                             FROM per_all_people_f per
                            WHERE per.person_id = a.person_id);
   ben_batch_utils.write(p_text => 'BEN_CRT_ORDR               : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_crt_ordr;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_crt_ordr_cvrd_per >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_CRT_ORDR_CVRD_PER
 -- where deleted person_id is directly referenced.
 --
 procedure delete_crt_ordr_cvrd_per
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_crt_ordr_cvrd_per';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_crt_ordr_cvrd_per a
         WHERE NOT EXISTS (SELECT 1
                             FROM per_all_people_f per
                            WHERE per.person_id = a.person_id);
   ben_batch_utils.write(p_text => 'BEN_CRT_ORDR_CVRD_PER      : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_crt_ordr_cvrd_per;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_elig_dpnt >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_ELIG_DPNT
 -- where deleted person_id is directly referenced.
 --
 procedure delete_elig_dpnt
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_elig_dpnt';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */ FROM ben_elig_dpnt a
         WHERE a.dpnt_person_id IS NOT NULL
           AND a.dpnt_person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                          FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_ELIG_DPNT              : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_elig_dpnt;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_elig_per_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_ELIG_PER_F
 -- where deleted person_id is directly referenced.
 --
 procedure delete_elig_per_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_elig_per_f';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_elig_per_f a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_ELIG_PER_F             : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_elig_per_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_ext_chg_evt_log >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_EXT_CHG_EVT_LOG
 -- where deleted person_id is directly referenced.
 --
 procedure delete_ext_chg_evt_log
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_ext_chg_evt_log';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_ext_chg_evt_log a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_EXT_CHG_EVT_LOG        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_ext_chg_evt_log;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_ext_rslt_dtl >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_EXT_RSLT_DTL
 -- where deleted person_id is directly referenced.
 --
 procedure delete_ext_rslt_dtl
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_ext_rslt_dtl';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_ext_rslt_dtl a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (0, 999999999999)
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_EXT_RSLT_DTL           : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_ext_rslt_dtl;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_ext_rslt_err >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_EXT_RSLT_ERR
 -- where deleted person_id is directly referenced.
 --
 procedure delete_ext_rslt_err
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_ext_rslt_err';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_ext_rslt_err a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_EXT_RSLT_ERR           : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_ext_rslt_err;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_le_clsn_n_rstr >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_LE_CLSN_N_RSTR
 -- where deleted person_id is directly referenced.
 --
 procedure delete_le_clsn_n_rstr
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_le_clsn_n_rstr';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_le_clsn_n_rstr a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_LE_CLSN_N_RSTR         : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_le_clsn_n_rstr;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_person_actions >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PERSON_ACTIONS
 -- where deleted person_id is directly referenced.
 --
 procedure delete_person_actions
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_person_actions';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_person_actions a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_PERSON_ACTIONS         : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_person_actions;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_per_bnfts_bal_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PER_BNFTS_BAL_F
 -- where deleted person_id is directly referenced.
 --
 procedure delete_per_bnfts_bal_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_per_bnfts_bal_f';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_per_bnfts_bal_f a
         WHERE NOT EXISTS (SELECT 1
                             FROM per_all_people_f per
                            WHERE per.person_id = a.person_id);
   ben_batch_utils.write(p_text => 'BEN_PER_BNFTS_BAL_F        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_per_bnfts_bal_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_per_dlvry_mthd_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PER_DLVRY_MTHD_F
 -- where deleted person_id is directly referenced.
 --
 procedure delete_per_dlvry_mthd_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_per_dlvry_mthd_f';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_per_dlvry_mthd_f a
         WHERE NOT EXISTS (SELECT 1
                             FROM per_all_people_f per
                            WHERE per.person_id = a.person_id);
   ben_batch_utils.write(p_text => 'BEN_PER_DLVRY_MTHD_F       : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_per_dlvry_mthd_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_per_pin_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PER_PIN_F
 -- where deleted person_id is directly referenced.
 --
 procedure delete_per_pin_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_per_pin_f';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_per_pin_f a
         WHERE NOT EXISTS (SELECT 1
                             FROM per_all_people_f per
                            WHERE per.person_id = a.person_id);
   ben_batch_utils.write(p_text => 'BEN_PER_PIN_F              : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_per_pin_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_pl_bnf_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PL_BNF_F
 -- where deleted person_id is directly referenced.
 --
 procedure delete_pl_bnf_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_pl_bnf_f';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_pl_bnf_f a
         WHERE NOT EXISTS (
                  SELECT 1
                    FROM per_all_people_f per
                   WHERE per.person_id = a.bnf_person_id
                      OR per.person_id = a.ttee_person_id);
   ben_batch_utils.write(p_text => 'BEN_PL_BNF_F               : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_pl_bnf_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_prtt_reimbmt_rqst_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PRTT_REIMBMT_RQST_F
 -- where deleted person_id is directly referenced.
 --
 procedure delete_prtt_reimbmt_rqst_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_prtt_reimbmt_rqst_f';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE FROM ben_prtt_reimbmt_rqst_f a
         WHERE NOT EXISTS (
                  SELECT 1
                    FROM per_all_people_f per
                   WHERE per.person_id = a.submitter_person_id
                      OR per.person_id = a.recipient_person_id
                      OR per.person_id = a.provider_person_id
                      OR per.person_id = a.provider_ssn_person_id);
   ben_batch_utils.write(p_text => 'BEN_PRTT_REIMBMT_RQST_F    : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_prtt_reimbmt_rqst_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_ptnl_ler_for_per >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete orphan records from BEN_PTNL_LER_FOR_PER
 -- where deleted person_id is directly referenced.
 --
 procedure delete_ptnl_ler_for_per
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_ptnl_ler_for_per';
   --
 begin
 --
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
   DELETE /*+ PARALLEL(A) */FROM ben_ptnl_ler_for_per a
         WHERE a.person_id IS NOT NULL
           AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                     FROM per_all_people_f per);
   ben_batch_utils.write(p_text => 'BEN_PTNL_LER_FOR_PER       : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_ptnl_ler_for_per;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_benefit_actions >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete all orphan child records of BEN_BENEFIT_ACTIONS
 -- and then records of BEN_BENEFIT_ACTIONS itself where deleted person_id is directly
 -- referenced.
 -- Hierarchy to use
 --
 --  BEN_BENEFIT_ACTIONS
 --   	BEN_BATCH_ACTN_ITEM_INFO
 --   	BEN_BATCH_BNFT_CERT_INFO
 --   	BEN_BATCH_COMMU_INFO
 --   	BEN_BATCH_DPNT_INFO
 --   	BEN_BATCH_ELCTBL_CHC_INFO
 --   	BEN_BATCH_ELIG_INFO
 --   	BEN_BATCH_LER_INFO
 --   	BEN_BATCH_RATE_INFO
 --   	BEN_BATCH_PROC_INFO
 --   	BEN_BATCH_RANGES
 --   	BEN_REPORTING
 --
 procedure delete_benefit_actions
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_benefit_actions';
   l_data       Numdata;
   --
   cursor c1 is
   SELECT       /*+ PARALLEL(A) */
       DISTINCT benefit_action_id
           FROM ben_benefit_actions a
          WHERE a.person_id IS NOT NULL
            AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                      FROM per_all_people_f per);
 --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
      OPEN c1 ;
      LOOP
      FETCH c1 BULK COLLECT INTO l_data ;
      --
      FORALL i IN 1..l_data.COUNT
    	DELETE FROM BEN_BATCH_ACTN_ITEM_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_ACTN_ITEM_INFO   : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_BNFT_CERT_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_BNFT_CERT_INFO   : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_COMMU_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_COMMU_INFO       : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_DPNT_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_DPNT_INFO        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_ELCTBL_CHC_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_ELCTBL_CHC_INFO  : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_ELIG_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_ELIG_INFO        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_LER_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_LER_INFO         : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_RATE_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_RATE_INFO        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_PROC_INFO
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_PROC_INFO        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BATCH_RANGES
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BATCH_RANGES           : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_REPORTING
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_REPORTING              : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM ben_benefit_actions
        WHERE  benefit_action_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BENEFIT_ACTIONS        : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      EXIT WHEN c1%NOTFOUND;
      --
      end loop;
      --
      CLOSE c1;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_benefit_actions;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_per_in_ler >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete all orphan child records of BEN_PER_IN_LER
 -- and then records of BEN_PER_IN_LER itself where deleted person_id is directly
 -- referenced.
 -- Hierarchy to use
 --
 --  BEN_PER_IN_LER
 --   	BEN_BNFT_PRVDD_LDGR_F
 --   	BEN_CBR_PER_IN_LER
 --   	BEN_ELIG_PER_OPT_F
 --   	BEN_ELIG_DPNT
 --   	BEN_PIL_ELCTBL_CHC_POPL
 --   	BEN_PRTT_PREM_BY_MO_F
 --   	BEN_PRTT_PREM_F
 --   	BEN_ENRT_PREM
 --   	BEN_ENRT_BNFT
 --   	BEN_ENRT_RT
 --   	BEN_ELIG_PER_ELCTBL_CHC
 --
 procedure delete_per_in_ler
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_per_in_ler';
   l_data       Numdata;
   --
   cursor c2 is
   SELECT          /*+ PARALLEL(A) */
          DISTINCT per_in_ler_id
              FROM ben_per_in_ler a
             WHERE a.person_id IS NOT NULL
               AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                         FROM per_all_people_f per);
 --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
      OPEN c2 ;
      LOOP
      FETCH c2 BULK COLLECT INTO l_data;
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_BNFT_PRVDD_LDGR_F
        WHERE  PER_IN_LER_ID = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_BNFT_PRVDD_LDGR_F      : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_CBR_PER_IN_LER
        WHERE  PER_IN_LER_ID = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_CBR_PER_IN_LER         : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_ELIG_PER_OPT_F
        WHERE  PER_IN_LER_ID = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_ELIG_PER_OPT_F         : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_ELIG_DPNT a
        where  PER_IN_LER_ID = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_ELIG_DPNT              : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_PIL_ELCTBL_CHC_POPL a
        where  PER_IN_LER_ID = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PIL_ELCTBL_CHC_POPL    : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_ENRT_RT
        where   ELIG_PER_ELCTBL_CHC_ID in ( select ELIG_PER_ELCTBL_CHC_ID
                                            from  BEN_ELIG_PER_ELCTBL_CHC a
                                            where a.PER_IN_LER_ID = l_data(i)  );
      --
      ben_batch_utils.write(p_text => 'BEN_ENRT_RT                : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_PRTT_PREM_BY_MO_F
        where   PRTT_PREM_ID IN ( select PRTT_PREM_ID
       	                          from   BEN_PRTT_PREM_F a
       	                          where  a.PER_IN_LER_ID = l_data(i)  );
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_PREM_BY_MO_F      : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_PRTT_PREM_F a
        where   PER_IN_LER_ID = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_PREM_F            : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_ENRT_PREM
       	where   ELIG_PER_ELCTBL_CHC_ID in ( select ELIG_PER_ELCTBL_CHC_ID
       	                                    from   BEN_ELIG_PER_ELCTBL_CHC a
       	                                    where  a.PER_IN_LER_ID = l_data(i)  );
      --
      ben_batch_utils.write(p_text => 'BEN_ENRT_PREM              : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_ENRT_BNFT
       	where   ELIG_PER_ELCTBL_CHC_ID in ( select ELIG_PER_ELCTBL_CHC_ID
       	                                    from   BEN_ELIG_PER_ELCTBL_CHC a
       	                                    where  a.PER_IN_LER_ID = l_data(i)  );
      --
      ben_batch_utils.write(p_text => 'BEN_ENRT_BNFT              : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        delete from BEN_ELIG_PER_ELCTBL_CHC a
        where   PER_IN_LER_ID = l_data(i) ;
      --
      ben_batch_utils.write(p_text => 'BEN_ELIG_PER_ELCTBL_CHC    : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PER_IN_LER
        WHERE  PER_IN_LER_ID = l_data(i) ;
      --
      ben_batch_utils.write(p_text => 'BEN_PER_IN_LER             : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      EXIT WHEN c2%NOTFOUND;
      --
      end loop;
      --
      CLOSE c2;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_per_in_ler;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_prtt_enrt_rslt_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete all orphan child records of BEN_PRTT_ENRT_RSLT_F
 -- and then records of BEN_PRTT_ENRT_RSLT_F itself where deleted person_id is directly
 -- referenced.
 -- Hierarchy to use
 --
 --  BEN_PRTT_ENRT_RSLT_F
 --   	BEN_PRMRY_CARE_PRVDR_F
 --   	BEN_PRTT_ENRT_ACTN_F
 --   	BEN_PRTT_ENRT_CTFN_PRVDD_F
 --   	BEN_PRTT_PREM_F
 --   	BEN_PRTT_RT_VAL
 --
 procedure delete_prtt_enrt_rslt_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_prtt_enrt_rslt_f';
   l_data       Numdata;
   --
   cursor c3 is
   SELECT          /*+ PARALLEL(A) */
          DISTINCT prtt_enrt_rslt_id
              FROM ben_prtt_enrt_rslt_f a
             WHERE a.person_id IS NOT NULL
               AND a.person_id NOT IN (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL_INDEX(PER) */ person_id
                                         FROM per_all_people_f per);
 --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
      OPEN c3 ;
      LOOP
      FETCH c3 BULK COLLECT INTO l_data;
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PRMRY_CARE_PRVDR_F
        WHERE  prtt_enrt_rslt_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRMRY_CARE_PRVDR_F     : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PRTT_ENRT_ACTN_F
        WHERE  prtt_enrt_rslt_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_ENRT_ACTN_F       : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PRTT_ENRT_CTFN_PRVDD_F
        WHERE  prtt_enrt_rslt_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_ENRT_CTFN_PRVDD_F : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PRTT_PREM_F
        WHERE  prtt_enrt_rslt_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_PREM_F            : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PRTT_RT_VAL
        WHERE  prtt_enrt_rslt_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_RT_VAL            : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
        DELETE FROM BEN_PRTT_ENRT_RSLT_F
        WHERE  prtt_enrt_rslt_id = l_data(i);
      --
      ben_batch_utils.write(p_text => 'BEN_PRTT_ENRT_RSLT_F       : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      EXIT WHEN c3%NOTFOUND;
      --
      end loop;
      --
      CLOSE c3;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_prtt_enrt_rslt_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_elig_cvrd_dpnt_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete all orphan child records of BEN_ELIG_CVRD_DPNT_F
 -- and then records of BEN_ELIG_CVRD_DPNT_F itself where deleted person_id is directly
 -- referenced.
 -- Hierarchy to use
 --
 --  BEN_ELIG_CVRD_DPNT_F
 --   	BEN_EXT_CRIT_VAL
 --   	BEN_CVRD_DPNT_CTFN_PRVDD_F
 --
 procedure delete_elig_cvrd_dpnt_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_elig_cvrd_dpnt_f';
   l_data       Numdata;
   --
   cursor c4 is
   SELECT /*+ PARALLEL(A) */
          DISTINCT elig_cvrd_dpnt_id
              FROM ben_elig_cvrd_dpnt_f a
             WHERE NOT EXISTS (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL(PER) */ 1
                                 FROM per_all_people_f per
                                WHERE per.person_id = a.dpnt_person_id);
 --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
      OPEN c4 ;
      LOOP
      FETCH c4 BULK COLLECT INTO l_data ;
      --
      FORALL i IN 1..l_data.COUNT
      DELETE FROM ben_cvrd_dpnt_ctfn_prvdd_f
            WHERE elig_cvrd_dpnt_id = l_data (i);
      --
      ben_batch_utils.write(p_text => 'BEN_CVRD_DPNT_CTFN_PRVDD_F : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
      DELETE FROM ben_ext_crit_val
            WHERE ext_crit_val_id IN (
                     SELECT DISTINCT ext_crit_val_id
                                FROM ben_ext_crit_val val, ben_ext_crit_typ typ
                               WHERE typ.crit_typ_cd = 'PID'
                                 AND val.ext_crit_typ_id = typ.ext_crit_typ_id
                                 AND val.val_1 = TO_CHAR (l_data (i)));
      --
      ben_batch_utils.write(p_text => 'BEN_EXT_CRIT_VAL           : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
      DELETE FROM ben_elig_cvrd_dpnt_f
            WHERE elig_cvrd_dpnt_id = l_data (i);
      --
      ben_batch_utils.write(p_text => 'BEN_ELIG_CVRD_DPNT_F       : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      EXIT WHEN c4%NOTFOUND;
      --
      end loop;
      --
      CLOSE c4;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_elig_cvrd_dpnt_f;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< delete_per_cm_f >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is procedure to delete all orphan child records of BEN_PER_CM_F
 -- and then records of BEN_PER_CM_F itself where deleted person_id is directly
 -- referenced.
 -- Hierarchy to use
 --
 --  BEN_PER_CM_F
 --   	BEN_PER_CM_PRVDD_F
 --   	BEN_PER_CM_TRGR_F
 --	BEN_PER_CM_USG_F
 --
 procedure delete_per_cm_f
 is
   --
   l_proc       varchar2(80) := g_package || '.delete_per_cm_f';
   l_data       Numdata;
   --
   cursor c5 is
   SELECT /*+ PARALLEL(A) */
          DISTINCT per_cm_id
              FROM ben_per_cm_f a
             WHERE NOT EXISTS (SELECT /*+ HASH_AJ INDEX_FFS(PER) PARALLEL(PER) */ 1
                                 FROM per_all_people_f per
                                WHERE per.person_id = a.person_id);
 --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   --
      OPEN c5 ;
      LOOP
      FETCH c5 BULK COLLECT INTO l_data ;
      --
      FORALL i IN 1..l_data.COUNT
         delete FROM  ben_per_cm_prvdd_f
         WHERE  per_cm_id = l_data(i) ;
      --
      ben_batch_utils.write(p_text => 'BEN_PER_CM_PRVDD_F         : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
         delete FROM  ben_per_cm_trgr_f
         WHERE  per_cm_id = l_data(i) ;
      --
      ben_batch_utils.write(p_text => 'BEN_PER_CM_TRGR_F          : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
         delete FROM ben_per_cm_usg_f
         WHERE  per_cm_id = l_data(i) ;
      --
      ben_batch_utils.write(p_text => 'BEN_PER_CM_USG_F           : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      FORALL i IN 1..l_data.COUNT
         delete FROM ben_per_cm_f
         WHERE  per_cm_id = l_data(i) ;
      --
      ben_batch_utils.write(p_text => 'BEN_PER_CM_F               : ' || nvl(to_char(SQL%ROWCOUNT),'0'));
      --
      EXIT WHEN c5%NOTFOUND;
      --
      end loop;
      --
      CLOSE c5;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end delete_per_cm_f;
 --
 -- -----------------------------------------------------------------------------
 -- |--------------------------< do_multithread >-------------------------------|
 -- -----------------------------------------------------------------------------
 --
 -- This is the main batch procedure to be called from the concurrent manager
 --
 procedure do_multithread
   (errbuf                     out nocopy varchar2
   ,retcode                    out nocopy number
   ,p_parent_request_id         in  number
   ,p_thread_id                in  number  )
 is
   --
   -- Local variable declaration
   --
   l_effective_date         date;
   l_proc                   varchar2(80) := g_package || '.do_multithread';
   l_title_text             varchar2(85);
   --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   l_title_text := 'Number of rows deleted from the following tables :';
   --
   if p_thread_id = 1 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_elig_per_f;
     delete_cbr_quald_bnf;
     delete_crt_ordr;
     delete_crt_ordr_cvrd_per ;
      --
   elsif p_thread_id = 2 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_elig_dpnt;
     delete_per_dlvry_mthd_f ;
     delete_pl_bnf_f;
     delete_per_pin_f ;
     --
   elsif p_thread_id = 3 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
    delete_ext_rslt_dtl ;
    delete_per_bnfts_bal_f ;
    delete_prtt_reimbmt_rqst_f;
    --
   elsif p_thread_id = 4 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_ext_rslt_err;
     delete_person_actions;
     --
   elsif p_thread_id = 5 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_benefit_actions;
     delete_le_clsn_n_rstr;
     --
   elsif p_thread_id = 6 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_per_in_ler;
     --
   elsif p_thread_id = 7 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_prtt_enrt_rslt_f;
     --
   elsif p_thread_id = 8 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_elig_cvrd_dpnt_f;
     delete_ext_chg_evt_log;
     --
   elsif p_thread_id = 9 then
     --
     ben_batch_utils.write(p_text => l_title_text);
     --
     delete_per_cm_f;
     delete_ptnl_ler_for_per;
     delete_per_con ;
     --
   end if;
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 end do_multithread;
 --
 -- ----------------------------------------------------------------------------
 -- |--------------------------------< process >-------------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- This is the main batch procedure to be called from the concurrent manager.
 --
 procedure process
   ( errbuf                       out nocopy varchar2
    ,retcode                      out nocopy number
   )
 is
   --
   -- Local variable declaration.
   --
   l_proc                   varchar2(80) := g_package || '.process';
   l_benefit_action_id      number(15);
   l_effective_date         date;
   l_object_version_number  number(15);
   l_threads                number(5) := 1;
   l_request_id             number(15);
   l_parent_request_id      number(15);
   --
   -- Cursor Declaration.
   --
 begin
   --
   hr_utility.set_location ('Entering ' || l_proc, 5);
   --
   l_effective_date := trunc(sysdate);
   l_parent_request_id := fnd_global.conc_request_id;
   --
   -- Create a new benefit_action row.
   --
   ben_benefit_actions_api.create_perf_benefit_actions
     (p_validate               => FALSE
     ,p_benefit_action_id      => l_benefit_action_id
     ,p_process_date           => l_effective_date
     ,p_mode_cd                => 'S'
     ,p_derivable_factors_flag => 'N'
     ,p_validate_flag          => 'N'
     ,p_business_group_id      => fnd_global.per_business_group_id
     ,p_no_programs_flag       => 'N'
     ,p_no_plans_flag          => 'N'
     ,p_audit_log_flag         => 'N'
     ,p_debug_messages_flag    => 'N'
     ,p_object_version_number  => l_object_version_number
     ,p_effective_date         => l_effective_date
     ,p_request_id             => l_parent_request_id
     ,p_program_application_id => fnd_global.prog_appl_id
     ,p_program_id             => fnd_global.conc_program_id
     ,p_program_update_date    => sysdate
   );
   --
   -- As of now the number of threads to be spawned is kept fixed to 9
   l_threads := 9;
   g_num_processes := 1;
   --
   for l_count in 2..l_threads
   loop
     --
     -- We start submitting threads from TWO as the main process will act as first thread.
     --
     hr_utility.set_location('Submitting request ' || l_count, 10);
     --
     l_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BEDEORTHRD'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => l_parent_request_id
		       ,argument2   => l_count);
     --
     -- Store the request id of the concurrent request
     --
     g_num_processes := g_num_processes + 1;
     g_request_tbl(l_count) := l_request_id;
     commit;
     --
   end loop;
   --
   -- Carry on with the master.
   --
   hr_utility.set_location('Submitting the master process', 10);
   --
   do_multithread
     (errbuf               => errbuf
     ,retcode              => retcode
     ,p_parent_request_id  => l_parent_request_id
     ,p_thread_id          => 1        );
   --
   -- Check if all the slave processes are finished.
   --
   check_all_slaves_finished(p_rpt_flag => TRUE);
   --
   hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
 exception
   --
   when others then
     --
     null;
     --
   --
 end process;
 --
end ben_delete_orphan_rows;

/
