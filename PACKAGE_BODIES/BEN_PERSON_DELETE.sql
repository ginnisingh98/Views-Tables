--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_DELETE" AS
/* $Header: bepedchk.pkb 120.1.12010000.3 2008/08/29 11:04:03 pvelvano ship $ */
g_package varchar2(50) := 'ben_person_delete.';
   PROCEDURE perform_ri_check (
      p_person_id   IN   NUMBER
   ) IS
      CURSOR c1 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_actn_item_info
         WHERE  person_id = p_person_id;
      CURSOR c2 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_bnft_cert_info
         WHERE  person_id = p_person_id;
      CURSOR c20 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_commu_info
         WHERE  person_id = p_person_id;
      CURSOR c21 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_dpnt_info
         WHERE  person_id = p_person_id;
      CURSOR c22 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_elctbl_chc_info
         WHERE  person_id = p_person_id;
      CURSOR c23 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_elig_info
         WHERE  person_id = p_person_id;
      CURSOR c24 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_ler_info
         WHERE  person_id = p_person_id;
      CURSOR c25 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_batch_rate_info
         WHERE  person_id = p_person_id;
      CURSOR c26 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_benefit_actions
         WHERE  person_id = p_person_id;
      CURSOR c15 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_crt_ordr
         WHERE  person_id = p_person_id;
      CURSOR c16 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_crt_ordr_cvrd_per
         WHERE  person_id = p_person_id;
      CURSOR c17 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_elig_per_f
         WHERE  person_id = p_person_id;
      CURSOR c3 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_ext_chg_evt_log
         WHERE  person_id = p_person_id;
      CURSOR c6 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_ext_rslt_dtl
         WHERE  person_id = p_person_id;
      CURSOR c7 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_ext_rslt_err
         WHERE  person_id = p_person_id;
      CURSOR c11 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_le_clsn_n_rstr lct,
                ben_per_in_ler pil
         WHERE  pil.person_id = p_person_id
           AND  pil.per_in_ler_id = lct.per_in_ler_id;   /* Bug 4882374 : Perf */
      CURSOR c27 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_person_actions
         WHERE  person_id = p_person_id;
      CURSOR c4 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_bnfts_bal_f
         WHERE  person_id = p_person_id;
      CURSOR c19 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_cm_f
         WHERE  person_id = p_person_id;
      CURSOR c8 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_dlvry_mthd_f
         WHERE  person_id = p_person_id;
      CURSOR c12 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_in_ler
         WHERE  person_id = p_person_id;
      CURSOR c9 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_in_lgl_enty_f
         WHERE  person_id = p_person_id;
      CURSOR c10 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_in_org_unit_f
         WHERE  person_id = p_person_id;
      CURSOR c5 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_per_pin_f
         WHERE  person_id = p_person_id;
      CURSOR c14 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_popl_org_f
         WHERE  person_id = p_person_id;
      CURSOR c18 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_prtt_enrt_rslt_f
         WHERE  person_id = p_person_id;
      CURSOR c13 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_ptnl_ler_for_per
         WHERE  person_id = p_person_id;
      CURSOR c28 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_reporting rep,
                ben_person_actions pat
         WHERE  pat.person_id = p_person_id
           AND  rep.benefit_action_id = pat.benefit_action_id;   /* Bug 4882374 : Perf */
      CURSOR c29 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_elig_cvrd_dpnt_f
         WHERE  dpnt_person_id = p_person_id;
      CURSOR c30 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_prtt_reimbmt_rqst_f
         WHERE  submitter_person_id = p_person_id;
      CURSOR c31 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_prtt_reimbmt_rqst_f
         WHERE  recipient_person_id = p_person_id;
      CURSOR c32 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_prtt_reimbmt_rqst_f
         WHERE  provider_person_id = p_person_id;
      CURSOR c33 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_prtt_reimbmt_rqst_f
         WHERE  provider_ssn_person_id = p_person_id;
      CURSOR c34 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_cbr_quald_bnf
         WHERE  cvrd_emp_person_id = p_person_id;
      -- 3511450
      CURSOR c35 (
         p_person_id   NUMBER
      ) IS
         SELECT 1
         FROM   ben_pl_bnf_f
         WHERE  bnf_person_id = p_person_id;

      l_temp   VARCHAR2 (2);
   BEGIN

--
-- Testing for values in BEN_BATCH_ACTN_ITEM_INFO
--
      OPEN c1 (
         p_person_id
      );

--
      FETCH c1 INTO l_temp;
      IF c1%FOUND THEN
         CLOSE c1;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_ACTN_ITEM_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c1;

--
-- Testing for values in BEN_BATCH_BNFT_CERT_INFO
--
      OPEN c2 (
         p_person_id
      );

--
      FETCH c2 INTO l_temp;
      IF c2%FOUND THEN
         CLOSE c2;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_BNFT_CERT_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c2;

--
-- Testing for values in BEN_BATCH_COMMU_INFO
--
      OPEN c20 (
         p_person_id
      );

--
      FETCH c20 INTO l_temp;
      IF c20%FOUND THEN
         CLOSE c20;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_COMMU_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c20;

--
-- Testing for values in BEN_BATCH_DPNT_INFO
--
      OPEN c21 (
         p_person_id
      );

--
      FETCH c21 INTO l_temp;
      IF c21%FOUND THEN
         CLOSE c21;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_DPNT_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c21;

--
-- Testing for values in BEN_BATCH_ELCTBL_CHC_INFO
--
      OPEN c22 (
         p_person_id
      );

--
      FETCH c22 INTO l_temp;
      IF c22%FOUND THEN
         CLOSE c22;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_ELCTBL_CHC_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c22;

--
-- Testing for values in BEN_BATCH_ELIG_INFO
--
      OPEN c23 (
         p_person_id
      );

--
      FETCH c23 INTO l_temp;
      IF c23%FOUND THEN
         CLOSE c23;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_ELIG_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c23;

--
-- Testing for values in BEN_BATCH_LER_INFO
--
      OPEN c24 (
         p_person_id
      );

--
      FETCH c24 INTO l_temp;
      IF c24%FOUND THEN
         CLOSE c24;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_LER_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c24;

--
-- Testing for values in BEN_BATCH_RATE_INFO
--
      OPEN c25 (
         p_person_id
      );

--
      FETCH c25 INTO l_temp;
      IF c25%FOUND THEN
         CLOSE c25;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BATCH_RATE_INFO'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c25;

--
-- Testing for values in BEN_BENEFIT_ACTIONS
--
      OPEN c26 (
         p_person_id
      );

--
      FETCH c26 INTO l_temp;
      IF c26%FOUND THEN
         CLOSE c26;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_BENEFIT_ACTIONS'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c26;

--
-- Testing for values in BEN_CRT_ORDR
--
      OPEN c15 (
         p_person_id
      );

--
      FETCH c15 INTO l_temp;
      IF c15%FOUND THEN
         CLOSE c15;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_CRT_ORDR'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c15;

--
-- Testing for values in BEN_CRT_ORDR_CVRD_PER
--
      OPEN c16 (
         p_person_id
      );

--
      FETCH c16 INTO l_temp;
      IF c16%FOUND THEN
         CLOSE c16;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_CRT_ORDR_CVRD_PER'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c16;

--
-- Testing for values in BEN_ELIG_PER_F
--
      OPEN c17 (
         p_person_id
      );

--
      FETCH c17 INTO l_temp;
      IF c17%FOUND THEN
         CLOSE c17;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_ELIG_PER_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c17;

--
-- Testing for values in BEN_EXT_CHG_EVT_LOG
--
      OPEN c3 (
         p_person_id
      );

--
      FETCH c3 INTO l_temp;
      IF c3%FOUND THEN
         CLOSE c3;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_EXT_CHG_EVT_LOG'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c3;

--
-- Testing for values in BEN_EXT_RSLT_DTL
--
      OPEN c6 (
         p_person_id
      );

--
      FETCH c6 INTO l_temp;
      IF c6%FOUND THEN
         CLOSE c6;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_EXT_RSLT_DTL'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c6;

--
-- Testing for values in BEN_EXT_RSLT_ERR
--
      OPEN c7 (
         p_person_id
      );

--
      FETCH c7 INTO l_temp;
      IF c7%FOUND THEN
         CLOSE c7;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_EXT_RSLT_ERR'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c7;

--
-- Testing for values in BEN_LE_CLSN_N_RSTR
--
      OPEN c11 (
         p_person_id
      );

--
      FETCH c11 INTO l_temp;
      IF c11%FOUND THEN
         CLOSE c11;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_LE_CLSN_N_RSTR'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c11;

--
-- Testing for values in BEN_PERSON_ACTIONS
--
      OPEN c27 (
         p_person_id
      );

--
      FETCH c27 INTO l_temp;
      IF c27%FOUND THEN
         CLOSE c27;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PERSON_ACTIONS'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c27;

--
-- Testing for values in BEN_PER_BNFTS_BAL_F
--
      OPEN c4 (
         p_person_id
      );

--
      FETCH c4 INTO l_temp;
      IF c4%FOUND THEN
         CLOSE c4;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_BNFTS_BAL_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c4;

--
-- Testing for values in BEN_PER_CM_F
--
      OPEN c19 (
         p_person_id
      );

--
      FETCH c19 INTO l_temp;
      IF c19%FOUND THEN
         CLOSE c19;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_CM_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c19;

--
-- Testing for values in BEN_PER_DLVRY_MTHD_F
--
      OPEN c8 (
         p_person_id
      );

--
      FETCH c8 INTO l_temp;
      IF c8%FOUND THEN
         CLOSE c8;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_DLVRY_MTHD_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c8;

--
-- Testing for values in BEN_PER_IN_LER
--
      OPEN c12 (
         p_person_id
      );

--
      FETCH c12 INTO l_temp;
      IF c12%FOUND THEN
         CLOSE c12;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_IN_LER'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c12;

--
-- Testing for values in BEN_PER_IN_LGL_ENTY_F
--
      OPEN c9 (
         p_person_id
      );

--
      FETCH c9 INTO l_temp;
      IF c9%FOUND THEN
         CLOSE c9;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_IN_LGL_ENTY_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c9;

--
-- Testing for values in BEN_PER_IN_ORG_UNIT_F
--
      OPEN c10 (
         p_person_id
      );

--
      FETCH c10 INTO l_temp;
      IF c10%FOUND THEN
         CLOSE c10;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_IN_ORG_UNIT_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c10;

--
-- Testing for values in BEN_PER_PIN_F
--
      OPEN c5 (
         p_person_id
      );

--
      FETCH c5 INTO l_temp;
      IF c5%FOUND THEN
         CLOSE c5;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PER_PIN_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c5;

--
-- Testing for values in BEN_POPL_ORG_F
--
      OPEN c14 (
         p_person_id
      );

--
      FETCH c14 INTO l_temp;
      IF c14%FOUND THEN
         CLOSE c14;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_POPL_ORG_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c14;

--
-- Testing for values in BEN_PRTT_ENRT_RSLT_F
--
      OPEN c18 (
         p_person_id
      );

--
      FETCH c18 INTO l_temp;
      IF c18%FOUND THEN
         CLOSE c18;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PRTT_ENRT_RSLT_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c18;

--
-- Testing for values in BEN_PTNL_LER_FOR_PER
--
      OPEN c13 (
         p_person_id
      );

--
      FETCH c13 INTO l_temp;
      IF c13%FOUND THEN
         CLOSE c13;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PTNL_LER_FOR_PER'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c13;

--
-- Testing for values in BEN_REPORTING
--
      OPEN c28 (
         p_person_id
      );

--
      FETCH c28 INTO l_temp;
      IF c28%FOUND THEN
         CLOSE c28;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_REPORTING'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c28;
--
-- Testing for values in BEN_ELIG_CVRD_DPNT_F
--
      OPEN c29 (
         p_person_id
      );

--
      FETCH c29 INTO l_temp;
      IF c29%FOUND THEN
         CLOSE c29;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_ELIG_CVRD_DPNT_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c29;
--
-- Testing for values in BEN_PRTT_REIBMT_RQST_F
--
      OPEN c30 (
         p_person_id
      );

--
      FETCH c30 INTO l_temp;
      IF c30%FOUND THEN
         CLOSE c30;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PRTT_REIBMT_RQST_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c30;
--
-- Testing for values in BEN_PRTT_REIBMT_RQST_F
--
      OPEN c31 (
         p_person_id
      );

--
      FETCH c31 INTO l_temp;
      IF c31%FOUND THEN
         CLOSE c31;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PRTT_REIBMT_RQST_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c31;
--
-- Testing for values in BEN_PRTT_REIBMT_RQST_F
--
      OPEN c32 (
         p_person_id
      );

--
      FETCH c32 INTO l_temp;
      IF c32%FOUND THEN
         CLOSE c32;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PRTT_REIBMT_RQST_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c32;
--
-- Testing for values in BEN_PRTT_REIBMT_RQST_F
--
      OPEN c33 (
         p_person_id
      );

--
      FETCH c33 INTO l_temp;
      IF c33%FOUND THEN
         CLOSE c33;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_PRTT_REIBMT_RQST_F'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c33;
--
-- Testing for values in BEN_CBR_QUALD_BNF
--
      OPEN c34 (
         p_person_id
      );

--
      FETCH c34 INTO l_temp;
      IF c34%FOUND THEN
         CLOSE c34;
         fnd_message.set_name (
            'BEN',
            'BEN_94121_DT_CHILD_EXISTS'
         );
         fnd_message.set_token (
            'TABLE_NAME',
            'BEN_CBR_QUALD_BNF'
         );
         fnd_message.raise_error;
      END IF;

--
      CLOSE c34;
--
--3511450 start

      OPEN c35 (
	         p_person_id
	        );
      FETCH c35 INTO l_temp;
      IF c35%FOUND THEN
         CLOSE c35;
         fnd_message.set_name (
            'BEN',
            'BEN_93911_DPT_DESIG_BNF'
         );
         fnd_message.raise_error;
      END IF;
--
      CLOSE c35;
-- 3511450 end

   END perform_ri_check;

--
   PROCEDURE delete_dependent_information (
      p_person_id   IN   NUMBER
   ) IS

 l_proc              varchar2(100):= g_package||'delete_dependent_information';
--
      CURSOR c_ecd IS
         SELECT elig_cvrd_dpnt_id, dpnt_person_id
         FROM            ben_elig_cvrd_dpnt_f
         WHERE           dpnt_person_id = p_person_id
         FOR UPDATE OF elig_cvrd_dpnt_id,dpnt_person_id;

--
      CURSOR c_crt_ordr_cvrd (
         p_dpnt_person_id   IN   NUMBER
      ) IS
         SELECT        crt_ordr_cvrd_per_id
         FROM          ben_crt_ordr_cvrd_per
         WHERE         crt_ordr_id IN (SELECT crt_ordr_id
                                       FROM   ben_crt_ordr
                                       WHERE  person_id = p_dpnt_person_id)
         FOR UPDATE OF crt_ordr_id;

--
      CURSOR c_cvrd_dpnt (
         p_elig_cvrd_dpnt_id   IN   NUMBER
      ) IS
         SELECT        cvrd_dpnt_ctfn_prvdd_id
         FROM          ben_cvrd_dpnt_ctfn_prvdd_f
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;
      CURSOR c1 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_prtt_enrt_actn_f
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c2 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_prmry_care_prvdr_f
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c3 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_cvrd_dpnt_ctfn_prvdd_f
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c4 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_elig_cvrd_dpnt_f
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c5 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_elig_dpnt
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c6 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        ext_crit_val_id
         FROM          ben_ext_crit_val
         WHERE         ext_crit_val_id IN
                             (SELECT DISTINCT ext_crit_val_id
                              FROM            ben_ext_crit_val val,
                                              ben_ext_crit_typ typ
                              WHERE           typ.crit_typ_cd = 'PID'
AND                                           val.ext_crit_typ_id =
                                                          typ.ext_crit_typ_id
AND                                           val.val_1 =
                                                 TO_CHAR (
                                                    p_elig_cvrd_dpnt_id
                                                 ))
         FOR UPDATE OF ext_crit_val_id;
      CURSOR c7 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_elig_dpnt
         WHERE         dpnt_person_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      l_id   NUMBER;
   BEGIN
     hr_utility.set_location('Entering: '||l_proc,10);
      FOR l_ecd IN c_ecd LOOP
         FOR l_crt_ordr_cvrd IN c_crt_ordr_cvrd (
                                   l_ecd.dpnt_person_id
                                ) LOOP
            DELETE FROM ben_crt_ordr_cvrd_per
            WHERE  CURRENT OF c_crt_ordr_cvrd;
         END LOOP;
         hr_utility.set_location(l_proc, 15);
         FOR l_cvrd_dpnt IN c_cvrd_dpnt (
                               l_ecd.elig_cvrd_dpnt_id
                            ) LOOP
            DELETE      ben_cvrd_dpnt_ctfn_prvdd_f
            WHERE  CURRENT OF c_cvrd_dpnt;
         END LOOP;
         hr_utility.set_location(l_proc, 20);
         OPEN c1 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_prtt_enrt_actn_f>>
         LOOP
            FETCH c1 INTO l_id;
            EXIT WHEN c1%NOTFOUND;
            DELETE      ben_prtt_enrt_actn_f
            WHERE  CURRENT OF c1;
         END LOOP ben_prtt_enrt_actn_f;
         CLOSE c1;
         hr_utility.set_location(l_proc, 25);
         OPEN c2 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_prmry_care_prvdr_f>>
         LOOP
            FETCH c2 INTO l_id;
            EXIT WHEN c2%NOTFOUND;
            DELETE      ben_prmry_care_prvdr_f
            WHERE  CURRENT OF c2;
         END LOOP ben_prmry_care_prvdr_f;
         CLOSE c2;
         hr_utility.set_location(l_proc, 30);
         OPEN c3 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_cvrd_dpnt_ctfn_prvdd_f>>
         LOOP
            FETCH c3 INTO l_id;
            EXIT WHEN c3%NOTFOUND;
            DELETE      ben_cvrd_dpnt_ctfn_prvdd_f
            WHERE  CURRENT OF c3;
         END LOOP ben_cvrd_dpnt_ctfn_prvdd_f;
         CLOSE c3;
         hr_utility.set_location(l_proc, 35);
       /*  OPEN c4 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_elig_cvrd_dpnt_f>>
         LOOP
            FETCH c4 INTO l_id;
            EXIT WHEN c4%NOTFOUND;
            DELETE      ben_elig_cvrd_dpnt_f
            WHERE  CURRENT OF c4;
         END LOOP ben_elig_cvrd_dpnt_f;
         CLOSE c4; */
         hr_utility.set_location(l_proc, 40);
         OPEN c5 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_elig_dpnt>>
         LOOP
            FETCH c5 INTO l_id;
            EXIT WHEN c5%NOTFOUND;
            DELETE      ben_elig_dpnt
            WHERE  CURRENT OF c5;
         END LOOP ben_elig_dpnt;
         CLOSE c5;
         hr_utility.set_location(l_proc, 45);
         OPEN c6 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_ext_crit_val>>
         LOOP
            FETCH c6 INTO l_id;
            EXIT WHEN c6%NOTFOUND;
            DELETE FROM ben_ext_crit_val
            WHERE  CURRENT OF c6;
         END LOOP ben_ext_crit_val;
         CLOSE c6;
         hr_utility.set_location(l_proc, 50);
         OPEN c7 (
            l_ecd.elig_cvrd_dpnt_id
         );
         <<ben_elig_dpnt>>
         LOOP
            FETCH c7 INTO l_id;
            EXIT WHEN c7%NOTFOUND;
            DELETE      ben_elig_dpnt
            WHERE  CURRENT OF c7;
         END LOOP ben_elig_dpnt;
         CLOSE c7;
         DELETE      ben_elig_cvrd_dpnt_f
         WHERE  CURRENT OF c_ecd;
      END LOOP;
     hr_utility.set_location('Leaving: '||l_proc,999);
   END delete_dependent_information;

--
   PROCEDURE delete_communications (
      p_person_id   IN   NUMBER
   ) IS
 l_proc              varchar2(100):= g_package||'delete_communications';

--** C|c1
--** CN|c4|Fetch the per_cm_id from ben_per_cm_f associated with a person_id.
      CURSOR c1 IS
         SELECT DISTINCT per_cm_id
         FROM            ben_per_cm_f
         WHERE           person_id = p_person_id;

--
      CURSOR c2 (
         p_per_cm_id   NUMBER
      ) IS
         SELECT        per_cm_prvdd_id
         FROM          ben_per_cm_prvdd_f
         WHERE         per_cm_id = p_per_cm_id
         FOR UPDATE OF per_cm_prvdd_id;

--
      CURSOR c3 (
         p_per_cm_id   NUMBER
      ) IS
         SELECT        per_cm_trgr_id
         FROM          ben_per_cm_trgr_f
         WHERE         per_cm_id = p_per_cm_id
         FOR UPDATE OF per_cm_trgr_id;

--
      CURSOR c4 (
         p_per_cm_id   NUMBER
      ) IS
         SELECT        per_cm_usg_id
         FROM          ben_per_cm_usg_f
         WHERE         per_cm_id = p_per_cm_id
         FOR UPDATE OF per_cm_usg_id;
      l_id   NUMBER;
   BEGIN
     hr_utility.set_location('Entering: '||l_proc,20);
      FOR r1 IN c1 LOOP
         OPEN c2 (
            r1.per_cm_id
         );
         <<ben_per_cm_prvdd_f>>
         LOOP
            FETCH c2 INTO l_id;
            EXIT WHEN c2%NOTFOUND;
            DELETE FROM ben_per_cm_prvdd_f
            WHERE  CURRENT OF c2;
         END LOOP ben_per_cm_prvdd_f;
         CLOSE c2;
         OPEN c3 (
            r1.per_cm_id
         );
         <<ben_per_cm_trgr_f>>
         LOOP
            FETCH c3 INTO l_id;
            EXIT WHEN c3%NOTFOUND;
            DELETE FROM ben_per_cm_trgr_f
            WHERE  CURRENT OF c3;
         END LOOP ben_per_cm_trgr_f;
         CLOSE c3;
         OPEN c4 (
            r1.per_cm_id
         );
         <<ben_per_cm_usg_f>>
         LOOP
            FETCH c4 INTO l_id;
            EXIT WHEN c4%NOTFOUND;
            DELETE FROM ben_per_cm_usg_f
            WHERE  CURRENT OF c4;
         END LOOP ben_per_cm_usg_f;
         CLOSE c4;
      END LOOP;
     hr_utility.set_location('Leaving: '||l_proc,999);
   END delete_communications;

--
   PROCEDURE delete_life_events (
      p_person_id   IN   NUMBER
   ) IS
 l_proc              varchar2(100):= g_package||'delete_life_events';
      --** C|c1
      --** CN|c1|Fetch the per_in_ler_id from ben_per_in_ler associated with a person_id.
      CURSOR c1 IS
         SELECT DISTINCT per_in_ler_id
         FROM            ben_per_in_ler
         WHERE           person_id = p_person_id;
      --** C|c2|p_per_in_ler_id in number
      --** CN|c2|Fetch the prtt_prem_id from ben_prtt_prem_f associated with a per_in_ler_id.
      CURSOR c2 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT DISTINCT prtt_prem_id
         FROM            ben_prtt_prem_f
         WHERE           per_in_ler_id = p_per_in_ler_id;
      CURSOR c3 (
         p_prtt_prem_id   NUMBER
      ) IS
         SELECT        prtt_prem_by_mo_id
         FROM          ben_prtt_prem_by_mo_f
         WHERE         prtt_prem_id = p_prtt_prem_id
         FOR UPDATE OF prtt_prem_by_mo_id;
      --** C|c4|p_person_id in number
      --** CN|c4|Fetch the prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f associated with a per_in_ler_id.
      CURSOR c4 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT DISTINCT prtt_enrt_rslt_id
         FROM            ben_prtt_enrt_rslt_f
         WHERE           per_in_ler_id = p_per_in_ler_id;

--
      CURSOR c5 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prmry_care_prvdr_id
         FROM          ben_prmry_care_prvdr_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prmry_care_prvdr_id;

--
      CURSOR c6 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        bnft_prvdd_ldgr_id
         FROM          ben_bnft_prvdd_ldgr_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF bnft_prvdd_ldgr_id;

--
      CURSOR c7 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_elig_cvrd_dpnt_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c8 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_enrt_ctfn_prvdd_id
         FROM          ben_prtt_enrt_ctfn_prvdd_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_enrt_ctfn_prvdd_id;

--
      CURSOR c9 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_prem_id
         FROM          ben_prtt_prem_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_prem_id;

--
      CURSOR c10 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_rt_val_id
         FROM          ben_prtt_rt_val
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_rt_val_id;

--
      CURSOR c11 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_enrt_actn_id
         FROM          ben_prtt_enrt_actn_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_enrt_actn_id;
      --** C|c12|p_per_in_ler_id in number
      --** CN|c12|Fetch the prtt_enrt_actn_id from ben_prtt_enrt_actn_f associated with a per_in_ler_id.
      CURSOR c12 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT DISTINCT prtt_enrt_actn_id
         FROM            ben_prtt_enrt_actn_f
         WHERE           per_in_ler_id = p_per_in_ler_id;
      CURSOR c13 (
         p_prtt_enrt_actn_id   NUMBER
      ) IS
         SELECT        pl_bnf_ctfn_prvdd_id
         FROM          ben_pl_bnf_ctfn_prvdd_f
         WHERE         prtt_enrt_actn_id = p_prtt_enrt_actn_id
         FOR UPDATE OF pl_bnf_ctfn_prvdd_id;

--
      CURSOR c14 (
         p_prtt_enrt_actn_id   NUMBER
      ) IS
         SELECT        cvrd_dpnt_ctfn_prvdd_id
         FROM          ben_cvrd_dpnt_ctfn_prvdd_f
         WHERE         prtt_enrt_actn_id = p_prtt_enrt_actn_id
         FOR UPDATE OF cvrd_dpnt_ctfn_prvdd_id;
      --** C|c15|p_per_in_ler_id in number
      --** CN|c15|Fetch the enrt_bnft_id from ben_enrt_bnft associated with a per_in_ler_id and elig_per_elctbl_chc_id.
      CURSOR c15 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT DISTINCT enrt_bnft_id
         FROM            ben_elig_per_elctbl_chc b1, ben_enrt_bnft b2
         WHERE           b1.per_in_ler_id = p_per_in_ler_id
AND                      b2.elig_per_elctbl_chc_id =
                                                    b1.elig_per_elctbl_chc_id;

--
      CURSOR c16 (
         p_enrt_bnft_id   NUMBER
      ) IS
         SELECT        enrt_rt_id
         FROM          ben_enrt_rt
         WHERE         enrt_bnft_id = p_enrt_bnft_id
         FOR UPDATE OF enrt_rt_id;

--
   --** C|c17|p_per_in_ler_id in number
   --** CN|c17|Fetch the elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc associated with a per_in_ler_id.
      CURSOR c17 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT DISTINCT elig_per_elctbl_chc_id
         FROM            ben_elig_per_elctbl_chc
         WHERE           per_in_ler_id = p_per_in_ler_id;
      CURSOR c18 (
         p_elig_per_elctbl_chc_id   NUMBER
      ) IS
         SELECT        enrt_bnft_id
         FROM          ben_enrt_bnft
         WHERE         elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         FOR UPDATE OF enrt_bnft_id;

--
      CURSOR c19 (
         p_elig_per_elctbl_chc_id   NUMBER
      ) IS
         SELECT        enrt_prem_id
         FROM          ben_enrt_prem
         WHERE         elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         FOR UPDATE OF enrt_prem_id;

--
      CURSOR c20 (
         p_elig_per_elctbl_chc_id   NUMBER
      ) IS
         SELECT        enrt_rt_id
         FROM          ben_enrt_rt
         WHERE         elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         FOR UPDATE OF enrt_rt_id;

--
      CURSOR c21 (
         p_elig_per_elctbl_chc_id   NUMBER
      ) IS
         SELECT        elctbl_chc_ctfn_id
         FROM          ben_elctbl_chc_ctfn
         WHERE         elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         FOR UPDATE OF elctbl_chc_ctfn_id;

--
   --** C|c22|p_per_in_ler_id in number
   --** CN|c22|Fetch the elig_cvrd_dpnt_id from ben_elig_cvrd_dpnt associated with a per_in_ler_id and prtt_enrt_rslt_id.
      CURSOR c22 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT DISTINCT elig_cvrd_dpnt_id
         FROM            ben_prtt_enrt_rslt_f b1, ben_elig_cvrd_dpnt b2
         WHERE           b1.per_in_ler_id = p_per_in_ler_id
AND                      b2.prtt_enrt_rslt_id = b1.prtt_enrt_rslt_id;

--
      CURSOR c23 (
         p_elig_cvrd_dpnt_id   NUMBER
      ) IS
         SELECT        prmry_care_prvdr_id
         FROM          ben_prmry_care_prvdr_f
         WHERE         elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         FOR UPDATE OF prmry_care_prvdr_id;

--
      CURSOR c24 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        cbr_per_in_ler_id
         FROM          ben_cbr_per_in_ler
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF cbr_per_in_ler_id;

--
      CURSOR c25 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        elig_dpnt_id
         FROM          ben_elig_dpnt
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF elig_dpnt_id;

--
      CURSOR c26 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        elig_per_elctbl_chc_id
         FROM          ben_elig_per_elctbl_chc
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF elig_per_elctbl_chc_id;

--
      CURSOR c27 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        elig_per_opt_id
         FROM          ben_elig_per_opt_f
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF elig_per_opt_id;

--
      CURSOR c28 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        bkup_tbl_id
         FROM          ben_le_clsn_n_rstr
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF bkup_tbl_id;

--
      CURSOR c29 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        pil_elctbl_chc_popl_id
         FROM          ben_pil_elctbl_chc_popl
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF pil_elctbl_chc_popl_id;

--
      CURSOR c30 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        pl_bnf_id
         FROM          ben_pl_bnf_f
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF pl_bnf_id;

--
      CURSOR c31 (
         p_per_in_ler_id   IN   NUMBER
      ) IS
         SELECT        prtt_enrt_rslt_id
         FROM          ben_prtt_enrt_rslt_f
         WHERE         per_in_ler_id = p_per_in_ler_id
         FOR UPDATE OF prtt_enrt_rslt_id;

--
      l_id   NUMBER;
   BEGIN
     hr_utility.set_location('Entering: '||l_proc,10);
      FOR r1 IN c1 LOOP
         FOR r2 IN c2 (
                      r1.per_in_ler_id
                   ) LOOP
            OPEN c3 (
               r2.prtt_prem_id
            );
            <<ben_prtt_prem_by_mo_f>>
            LOOP
               FETCH c3 INTO l_id;
               EXIT WHEN c3%NOTFOUND;
               DELETE FROM ben_prtt_prem_by_mo_f
               WHERE  CURRENT OF c3;
            END LOOP ben_prtt_prem_by_mo_f;
            CLOSE c3;
         END LOOP;
         FOR r4 IN c4 (
                      r1.per_in_ler_id
                   ) LOOP
            OPEN c5 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_prmry_care_prvdr_f>>
            LOOP
               FETCH c5 INTO l_id;
               EXIT WHEN c5%NOTFOUND;
               DELETE FROM ben_prmry_care_prvdr_f
               WHERE  CURRENT OF c5;
            END LOOP ben_prmry_care_prvdr_f;
            CLOSE c5;
            OPEN c6 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_bnft_prvdd_ldgr_f>>
            LOOP
               FETCH c6 INTO l_id;
               EXIT WHEN c6%NOTFOUND;
               DELETE FROM ben_bnft_prvdd_ldgr_f
               WHERE  CURRENT OF c6;
            END LOOP ben_bnft_prvdd_ldgr_f;
            CLOSE c6;
            OPEN c7 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_elig_cvrd_dpnt_f>>
            LOOP
               FETCH c7 INTO l_id;
               EXIT WHEN c7%NOTFOUND;
               DELETE FROM ben_elig_cvrd_dpnt_f
               WHERE  CURRENT OF c7;
            END LOOP ben_elig_cvrd_dpnt_f;
            CLOSE c7;
            OPEN c8 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_prtt_enrt_ctfn_prvdd_f>>
            LOOP
               FETCH c8 INTO l_id;
               EXIT WHEN c8%NOTFOUND;
               DELETE FROM ben_prtt_enrt_ctfn_prvdd_f
               WHERE  CURRENT OF c8;
            END LOOP ben_prtt_enrt_ctfn_prvdd_f;
            CLOSE c8;
            OPEN c9 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_prtt_prem_f>>
            LOOP
               FETCH c9 INTO l_id;
               EXIT WHEN c9%NOTFOUND;
               DELETE FROM ben_prtt_prem_f
               WHERE  CURRENT OF c9;
            END LOOP ben_prtt_prem_f;
            CLOSE c9;
            OPEN c10 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_prtt_rt_val>>
            LOOP
               FETCH c10 INTO l_id;
               EXIT WHEN c10%NOTFOUND;
               DELETE FROM ben_prtt_rt_val
               WHERE  CURRENT OF c10;
            END LOOP ben_prtt_rt_val;
            CLOSE c10;
            OPEN c11 (
               r4.prtt_enrt_rslt_id
            );
            <<ben_prtt_enrt_actn_f>>
            LOOP
               FETCH c11 INTO l_id;
               EXIT WHEN c11%NOTFOUND;
               DELETE FROM ben_prtt_enrt_actn_f
               WHERE  CURRENT OF c11;
            END LOOP ben_prtt_enrt_actn_f;
            CLOSE c11;
         END LOOP;
         FOR r12 IN c12 (
                       r1.per_in_ler_id
                    ) LOOP
            OPEN c13 (
               r12.prtt_enrt_actn_id
            );
            <<ben_pl_bnf_ctfn_prvdd_f>>
            LOOP
               FETCH c13 INTO l_id;
               EXIT WHEN c13%NOTFOUND;
               DELETE FROM ben_pl_bnf_ctfn_prvdd_f
               WHERE  CURRENT OF c13;
            END LOOP ben_pl_bnf_ctfn_prvdd_f;
            CLOSE c13;
            OPEN c14 (
               r12.prtt_enrt_actn_id
            );
            <<ben_cvrd_dpnt_ctfn_prvdd_f>>
            LOOP
               FETCH c14 INTO l_id;
               EXIT WHEN c14%NOTFOUND;
               DELETE FROM ben_cvrd_dpnt_ctfn_prvdd_f
               WHERE  CURRENT OF c14;
            END LOOP ben_cvrd_dpnt_ctfn_prvdd_f;
            CLOSE c14;
         END LOOP;
         hr_utility.set_location(l_proc,50);
         FOR r15 IN c15 (
                       r1.per_in_ler_id
                    ) LOOP
            OPEN c16 (
               r15.enrt_bnft_id
            );
            <<ben_enrt_rt>>
            LOOP
               FETCH c16 INTO l_id;
               EXIT WHEN c16%NOTFOUND;
               DELETE FROM ben_enrt_rt
               WHERE  CURRENT OF c16;
            END LOOP;
            CLOSE c16;
         END LOOP;
         hr_utility.set_location(l_proc,55);
         FOR r17 IN c17 (
                       r1.per_in_ler_id
                    ) LOOP
            OPEN c18 (
               r17.elig_per_elctbl_chc_id
            );
            <<ben_enrt_bnft>>
            LOOP
               FETCH c18 INTO l_id;
               EXIT WHEN c18%NOTFOUND;
               DELETE FROM ben_enrt_bnft
               WHERE  CURRENT OF c18;
            END LOOP ben_enrt_bnft;
            CLOSE c18;
            --
         hr_utility.set_location(l_proc,60);
            OPEN c19 (
               r17.elig_per_elctbl_chc_id
            );
            <<ben_enrt_prem>>
            LOOP
               FETCH c19 INTO l_id;
               EXIT WHEN c19%NOTFOUND;
               DELETE FROM ben_enrt_prem
               WHERE  CURRENT OF c19;
            END LOOP;
            CLOSE c19;
            --
         hr_utility.set_location(l_proc,65);
            OPEN c20 (
               r17.elig_per_elctbl_chc_id
            );
            <<ben_enrt_rt>>
            LOOP
               FETCH c20 INTO l_id;
               EXIT WHEN c20%NOTFOUND;
               DELETE FROM ben_enrt_rt
               WHERE  CURRENT OF c20;
            END LOOP ben_enrt_rt;
            CLOSE c20;
            --
         hr_utility.set_location(l_proc,70);
            OPEN c21 (
               r17.elig_per_elctbl_chc_id
            );
            <<ben_elctbl_chc_ctfn>>
            LOOP
               FETCH c21 INTO l_id;
               EXIT WHEN c21%NOTFOUND;
               DELETE FROM ben_elctbl_chc_ctfn
               WHERE  CURRENT OF c21;
            END LOOP ben_elctbl_chc_ctfn;
            CLOSE c21;
         END LOOP;
         hr_utility.set_location(l_proc,70);
         FOR r22 IN c22 (
                       r1.per_in_ler_id
                    ) LOOP
            OPEN c23 (
               r22.elig_cvrd_dpnt_id
            );
            <<ben_prmry_care_prvdr_f>>
            LOOP
               FETCH c23 INTO l_id;
               EXIT WHEN c23%NOTFOUND;
               DELETE FROM ben_prmry_care_prvdr_f
               WHERE  CURRENT OF c23;
            END LOOP ben_prmry_care_prvdr_f;
            CLOSE c23;
         END LOOP;
         OPEN c24 (
            r1.per_in_ler_id
         );
         <<ben_cbr_per_in_ler>>
         LOOP
            FETCH c24 INTO l_id;
            EXIT WHEN c24%NOTFOUND;
            DELETE FROM ben_cbr_per_in_ler
            WHERE  CURRENT OF c24;
         END LOOP ben_cbr_per_in_ler;
         CLOSE c24;
         OPEN c25 (
            r1.per_in_ler_id
         );
         <<ben_elig_dpnt>>
         LOOP
            FETCH c25 INTO l_id;
            EXIT WHEN c25%NOTFOUND;
            DELETE FROM ben_elig_dpnt
            WHERE  CURRENT OF c25;
         END LOOP ben_elig_dpnt;
         CLOSE c25;
         OPEN c26 (
            r1.per_in_ler_id
         );
         hr_utility.set_location(l_proc,90);
         <<ben_elig_per_elctbl_chc>>
         LOOP
            FETCH c26 INTO l_id;
            EXIT WHEN c26%NOTFOUND;
            DELETE FROM ben_elig_per_elctbl_chc
            WHERE  CURRENT OF c26;
         END LOOP ben_elig_per_elctbl_chc;
         CLOSE c26;
         OPEN c27 (
            r1.per_in_ler_id
         );
         <<ben_elig_per_opt_f>>
         LOOP
            FETCH c27 INTO l_id;
            EXIT WHEN c27%NOTFOUND;
            DELETE FROM ben_elig_per_opt_f
            WHERE  CURRENT OF c27;
         END LOOP ben_elig_per_opt_f;
         CLOSE c27;
         OPEN c28 (
            r1.per_in_ler_id
         );
         <<ben_le_clsn_n_rstr>>
         LOOP
            FETCH c28 INTO l_id;
            EXIT WHEN c28%NOTFOUND;
            DELETE FROM ben_le_clsn_n_rstr
            WHERE  CURRENT OF c28;
         END LOOP ben_le_clsn_n_rstr;
         CLOSE c28;
         OPEN c29 (
            r1.per_in_ler_id
         );
         <<ben_pil_elctbl_chc_popl>>
         LOOP
            FETCH c29 INTO l_id;
            EXIT WHEN c29%NOTFOUND;
            DELETE FROM ben_pil_elctbl_chc_popl
            WHERE  CURRENT OF c29;
         END LOOP ben_pil_elctbl_chc_popl;
         CLOSE c29;
         OPEN c30 (
            r1.per_in_ler_id
         );
         <<ben_pl_bnf_f>>
         LOOP
            FETCH c30 INTO l_id;
            EXIT WHEN c30%NOTFOUND;
            DELETE FROM ben_pl_bnf_f
            WHERE  CURRENT OF c30;
         END LOOP ben_pl_bnf_f;
         CLOSE c30;
         OPEN c31 (
            r1.per_in_ler_id
         );
         <<ben_prtt_enrt_rslt_f>>
         LOOP
            FETCH c31 INTO l_id;
            EXIT WHEN c31%NOTFOUND;
            DELETE FROM ben_prtt_enrt_rslt_f
            WHERE  CURRENT OF c31;
         END LOOP ben_prtt_enrt_rslt_f;
         CLOSE c31;
      END LOOP;
     hr_utility.set_location('Leaving: '||l_proc,999);
   END delete_life_events;

--
   PROCEDURE delete_participant_information (
      p_person_id   IN   NUMBER
   ) IS
 l_proc              varchar2(100):= g_package||'delete_participant_information';

--** C|c2|p_person_id in number
--** CN|c2|Fetch the prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f associated with person_id.
      CURSOR c1 (
         p_person_id   IN   NUMBER
      ) IS
         SELECT DISTINCT prtt_enrt_rslt_id
         FROM            ben_prtt_enrt_rslt_f
         WHERE           person_id = p_person_id;

--
      CURSOR c2 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prmry_care_prvdr_id
         FROM          ben_prmry_care_prvdr_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prmry_care_prvdr_id;

--

      CURSOR c3 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        bnft_prvdd_ldgr_id
         FROM          ben_bnft_prvdd_ldgr_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF bnft_prvdd_ldgr_id;

--
      CURSOR c4 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        elig_cvrd_dpnt_id
         FROM          ben_elig_cvrd_dpnt_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF elig_cvrd_dpnt_id;

--
      CURSOR c5 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_enrt_ctfn_prvdd_id
         FROM          ben_prtt_enrt_ctfn_prvdd_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_enrt_ctfn_prvdd_id;

--

      CURSOR c6 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_prem_id
         FROM          ben_prtt_prem_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_prem_id;

--
      CURSOR c7 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_rt_val_id
         FROM          ben_prtt_rt_val
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_rt_val_id;
      CURSOR c8 (
         p_prtt_enrt_rslt_id   NUMBER
      ) IS
         SELECT        prtt_enrt_actn_id
         FROM          ben_prtt_enrt_actn_f
         WHERE         prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         FOR UPDATE OF prtt_enrt_actn_id;
      l_id   NUMBER;
   BEGIN
     hr_utility.set_location('Entering: '||l_proc,10);
      FOR r1 IN c1 (
                   p_person_id
                ) LOOP
         OPEN c2 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_prmry_care_prvdr_f>>
         LOOP
            FETCH c2 INTO l_id;
            EXIT WHEN c2%NOTFOUND;
            DELETE FROM ben_prmry_care_prvdr_f
            WHERE  CURRENT OF c2;
         END LOOP ben_prmry_care_prvdr_f;
         CLOSE c2;
         OPEN c3 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_bnft_prvdd_ldgr_f>>
         LOOP
            FETCH c3 INTO l_id;
            EXIT WHEN c3%NOTFOUND;
            DELETE FROM ben_bnft_prvdd_ldgr_f
            WHERE  CURRENT OF c3;
         END LOOP ben_bnft_prvdd_ldgr_f;
         CLOSE c3;
         OPEN c4 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_elig_cvrd_dpnt_f>>
         LOOP
            FETCH c4 INTO l_id;
            EXIT WHEN c4%NOTFOUND;
            DELETE FROM ben_elig_cvrd_dpnt_f
            WHERE  CURRENT OF c4;
         END LOOP ben_elig_cvrd_dpnt_f;
         CLOSE c4;
         OPEN c5 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_prtt_enrt_ctfn_prvdd_f>>
         LOOP
            FETCH c5 INTO l_id;
            EXIT WHEN c5%NOTFOUND;
            DELETE FROM ben_prtt_enrt_ctfn_prvdd_f
            WHERE  CURRENT OF c5;
         END LOOP ben_prtt_enrt_ctfn_prvdd_f;
         CLOSE c5;
         OPEN c6 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_prtt_prem_f>>
         LOOP
            FETCH c6 INTO l_id;
            EXIT WHEN c6%NOTFOUND;
            DELETE FROM ben_prtt_prem_f
            WHERE  CURRENT OF c6;
         END LOOP ben_prtt_prem_f;
         CLOSE c6;
         OPEN c7 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_prtt_rt_val>>
         LOOP
            FETCH c7 INTO l_id;
            EXIT WHEN c7%NOTFOUND;
            DELETE FROM ben_prtt_rt_val
            WHERE  CURRENT OF c7;
         END LOOP ben_prtt_rt_val;
         CLOSE c7;
         OPEN c8 (
            r1.prtt_enrt_rslt_id
         );
         <<ben_prtt_enrt_actn_f>>
         LOOP
            FETCH c8 INTO l_id;
            EXIT WHEN c8%NOTFOUND;
            DELETE FROM ben_prtt_enrt_actn_f
            WHERE  CURRENT OF c8;
         END LOOP ben_prtt_enrt_actn_f;
         CLOSE c8;
      END LOOP;
     hr_utility.set_location('Leaving: '||l_proc,999);
   END delete_participant_information;

--
   PROCEDURE delete_benefit_action_children (
      p_person_id   IN   NUMBER
   ) IS

 l_proc              varchar2(100):= g_package||'delete_benefit_action_children';
--** C|c1
--** CN|c1|Fetch the benefit_action_id from ben_benefit_actions associated with a person_id for a particular business group.
      CURSOR c1 IS
         SELECT DISTINCT benefit_action_id
         FROM            ben_benefit_actions
         WHERE           person_id = p_person_id;

--
      CURSOR c2 (
         p_benefit_action_id   NUMBER
      ) IS
         SELECT        reporting_id
         FROM          ben_reporting
         WHERE         benefit_action_id = p_benefit_action_id
         FOR UPDATE OF reporting_id;
      CURSOR c3 (
         p_benefit_action_id   NUMBER
      ) IS
         SELECT        person_action_id
         FROM          ben_person_actions
         WHERE         benefit_action_id = p_benefit_action_id
         FOR UPDATE OF person_action_id;
      CURSOR c4 (
         p_benefit_action_id   NUMBER
      ) IS
         SELECT        range_id
         FROM          ben_batch_ranges
         WHERE         benefit_action_id = p_benefit_action_id
         FOR UPDATE OF range_id;

--
      l_id   NUMBER;
   BEGIN
     hr_utility.set_location('Entering: '||l_proc,10);
      FOR r1 IN c1 LOOP
         OPEN c2 (
            r1.benefit_action_id
         );
         <<ben_reporting>>
         LOOP
            FETCH c2 INTO l_id;
            EXIT WHEN c2%NOTFOUND;
            DELETE FROM ben_reporting
            WHERE  CURRENT OF c2;
         END LOOP ben_reporting;
         CLOSE c2;
         OPEN c3 (
            r1.benefit_action_id
         );
         <<ben_person_actions>>
         LOOP
            FETCH c3 INTO l_id;
            EXIT WHEN c3%NOTFOUND;
            DELETE FROM ben_person_actions
            WHERE  CURRENT OF c3;
         END LOOP ben_person_actions;
         CLOSE c3;
         OPEN c4 (
            r1.benefit_action_id
         );
         <<ben_batch_ranges>>
         LOOP
            FETCH c4 INTO l_id;
            EXIT WHEN c4%NOTFOUND;
            DELETE FROM ben_batch_ranges
            WHERE  CURRENT OF c4;
         END LOOP ben_batch_ranges;
         CLOSE c4;
      END LOOP;
     hr_utility.set_location('Leaving: '||l_proc,999);
   END delete_benefit_action_children;

--
   PROCEDURE delete_reimbmt_rqst (
      p_person_id   NUMBER
   ) IS

--** C|c1
--** CN|c1|Fetch the prtt_reimbmt_rqst_id from ben_prtt_reimbmt_rqst_f associated with a person_id.
      CURSOR c1 IS
         SELECT        prtt_reimbmt_rqst_id
         FROM          ben_prtt_reimbmt_rqst_f
         WHERE         submitter_person_id = p_person_id
OR                     recipient_person_id = p_person_id
OR                     provider_person_id = p_person_id
OR                     provider_ssn_person_id = p_person_id
OR                     contact_relationship_id IN
                             (SELECT contact_relationship_id
                              FROM   per_contact_relationships
                              WHERE  person_id = p_person_id)
         FOR UPDATE OF prtt_reimbmt_rqst_id;

--
      CURSOR c2 (
         p_prtt_reimbmt_rqst_id   NUMBER
      ) IS
         SELECT        prtt_reimbmt_recon_id
         FROM          ben_prtt_reimbmt_recon
         WHERE         prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
         FOR UPDATE OF prtt_reimbmt_recon_id;
      l_id   NUMBER;
   BEGIN
      FOR r1 IN c1 LOOP
         OPEN c2 (
            r1.prtt_reimbmt_rqst_id
         );
         <<ben_prtt_reimbmt_recon>>
         LOOP
            FETCH c2 INTO l_id;
            EXIT WHEN c2%NOTFOUND;
            DELETE FROM ben_prtt_reimbmt_recon
            WHERE  CURRENT OF c2;
         END LOOP ben_prtt_reimbmt_recon;
         CLOSE c2;
         DELETE FROM ben_prtt_reimbmt_rqst_f
         WHERE  CURRENT OF c1;
      END LOOP;
   END delete_reimbmt_rqst;

--
   PROCEDURE delete_ben_rows (
      p_person_id   NUMBER
   ) IS
      --** C|c01
      CURSOR c01 (
         p_benefit_action_id   IN   NUMBER
      ) IS
         SELECT        benefit_action_id
         FROM          ben_reporting
         WHERE         benefit_action_id = p_benefit_action_id
         FOR UPDATE OF benefit_action_id;
      --** C|c7
      --** CN|c7|Fetch the elig_per_id from ben_elig_per_f associated with a person_id.
      CURSOR c7 IS
         SELECT DISTINCT elig_per_id
         FROM            ben_elig_per_f
         WHERE           person_id = p_person_id;
      --** C|c9
      --** CN|c9|Fetch the element_entry_id from pay_element_entries_f associated with a person_id.
      CURSOR c9 IS
         SELECT DISTINCT element_entry_id
         FROM            per_all_assignments_f paf, pay_element_entries_f pee
         WHERE           paf.person_id = p_person_id
AND                      pee.assignment_id = paf.assignment_id;
      CURSOR c20 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_actn_item_id
         FROM          ben_batch_actn_item_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_actn_item_id;

--
      CURSOR c21 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_benft_cert_id
         FROM          ben_batch_bnft_cert_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_benft_cert_id;

--
      CURSOR c22 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_commu_id
         FROM          ben_batch_commu_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_commu_id;

--
      CURSOR c23 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_dpnt_id
         FROM          ben_batch_dpnt_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_dpnt_id;

--
      CURSOR c24 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_elctbl_id
         FROM          ben_batch_elctbl_chc_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_elctbl_id;

--
      CURSOR c25 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_elig_id
         FROM          ben_batch_elig_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_elig_id;

--
      CURSOR c26 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_ler_id
         FROM          ben_batch_ler_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_ler_id;

--
      CURSOR c27 (
         p_person_id   NUMBER
      ) IS
         SELECT        batch_rt_id
         FROM          ben_batch_rate_info
         WHERE         person_id = p_person_id
         FOR UPDATE OF batch_rt_id;

--
      CURSOR c28 (
         p_person_id   NUMBER
      ) IS
         SELECT        reporting_id
         FROM          ben_reporting rep,
                       ben_person_actions pat
         WHERE         pat.person_id = p_person_id
           AND         rep.benefit_action_id = pat.benefit_action_id  /* Bug 4882374 : Perf */
         FOR UPDATE OF rep.reporting_id;

--
      CURSOR c29 (
         p_person_id   NUMBER
      ) IS
         SELECT        person_action_id
         FROM          ben_person_actions
         WHERE         person_id = p_person_id
         FOR UPDATE OF person_action_id;

--
      CURSOR c30 (
         p_person_id   NUMBER
      ) IS
         SELECT        benefit_action_id
         FROM          ben_benefit_actions
         WHERE         person_id = p_person_id
         FOR UPDATE OF benefit_action_id;

--
      CURSOR c31 (
         p_person_id   NUMBER
      ) IS
         SELECT        cbr_quald_bnf_id
         FROM          ben_cbr_quald_bnf
         WHERE         cvrd_emp_person_id = p_person_id
         FOR UPDATE OF cbr_quald_bnf_id;

--
      CURSOR c32 (
         p_person_id   NUMBER
      ) IS
         SELECT        crt_ordr_cvrd_per_id
         FROM          ben_crt_ordr_cvrd_per
         WHERE         crt_ordr_id IN (SELECT crt_ordr_id
                                       FROM   ben_crt_ordr
                                       WHERE  person_id = p_person_id)
         FOR UPDATE OF crt_ordr_cvrd_per_id;

--
      CURSOR c33 (
         p_person_id   NUMBER
      ) IS
         SELECT        crt_ordr_id
         FROM          ben_crt_ordr
         WHERE         person_id = p_person_id
         FOR UPDATE OF crt_ordr_id;

--
      CURSOR c34 (
         p_person_id   NUMBER
      ) IS
         SELECT        elig_per_id
         FROM          ben_elig_per_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF elig_per_id;

--
      CURSOR c35 (
         p_person_id   NUMBER
      ) IS
         SELECT        ext_chg_evt_log_id
         FROM          ben_ext_chg_evt_log
         WHERE         person_id = p_person_id
         FOR UPDATE OF ext_chg_evt_log_id;

--
      CURSOR c36 (
         p_person_id   NUMBER
      ) IS
         SELECT        ext_rslt_dtl_id
         FROM          ben_ext_rslt_dtl
         WHERE         person_id = p_person_id
         FOR UPDATE OF ext_rslt_dtl_id;

--
      CURSOR c37 (
         p_person_id   NUMBER
      ) IS
         SELECT        ext_rslt_err_id
         FROM          ben_ext_rslt_err
         WHERE         person_id = p_person_id
         FOR UPDATE OF ext_rslt_err_id;

--
      CURSOR c38 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_bnfts_bal_id
         FROM          ben_per_bnfts_bal_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_bnfts_bal_id;

--
      CURSOR c39 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_cm_id
         FROM          ben_per_cm_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_cm_id;

--
      CURSOR c40 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_dlvry_mthd_id
         FROM          ben_per_dlvry_mthd_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_dlvry_mthd_id;

--
      CURSOR c41 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_in_ler_id
         FROM          ben_per_in_ler
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_in_ler_id;

--
      CURSOR c42 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_in_lgl_enty_id
         FROM          ben_per_in_lgl_enty_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_in_lgl_enty_id;

--
      CURSOR c43 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_in_org_unit_id
         FROM          ben_per_in_org_unit_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_in_org_unit_id;

--
      CURSOR c44 (
         p_person_id   NUMBER
      ) IS
         SELECT        per_pin_id
         FROM          ben_per_pin_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF per_pin_id;

--
      CURSOR c45 (
         p_person_id   NUMBER
      ) IS
         SELECT        ptnl_ler_for_per_id
         FROM          ben_ptnl_ler_for_per
         WHERE         person_id = p_person_id
         FOR UPDATE OF ptnl_ler_for_per_id;

--
      CURSOR c46 (
         p_person_id   NUMBER
      ) IS
         SELECT        popl_org_id
         FROM          ben_popl_org_f
         WHERE         person_id = p_person_id
         FOR UPDATE OF popl_org_id;

--
      CURSOR c47 (
         p_person_id   NUMBER
      ) IS
         SELECT        ext_crit_val_id
         FROM          ben_ext_crit_val
         WHERE         ext_crit_val_id IN (SELECT DISTINCT ext_crit_val_id
                                           FROM            ben_ext_crit_val val,
                                                           ben_ext_crit_typ typ
                                           WHERE           typ.crit_typ_cd =
                                                                        'PID'
AND                                                        val.ext_crit_typ_id =
                                                              typ.ext_crit_typ_id
AND                                                        val.val_1 =
                                                              TO_CHAR (
                                                                 p_person_id
                                                              ))
         FOR UPDATE OF ext_crit_val_id;
--
       CURSOR c48 (
         p_person_id   NUMBER
      ) IS
         SELECT        pl_bnf_id
         FROM          ben_pl_bnf_f
         WHERE         bnf_person_id = p_person_id
         FOR UPDATE OF pl_bnf_id;

--
--Bug 4653271 For Deletion of BEn - CWB information
--
       CURSOR c49 (
         p_per_in_ler_id   NUMBER
      ) IS
         SELECT        PIL_ELCTBL_CHC_POPL_ID
         FROM          ben_pil_elctbl_chc_popl
         WHERE         per_in_ler_id = p_per_in_ler_id
	 FOR UPDATE OF PIL_ELCTBL_CHC_POPL_ID;



--

--
       CURSOR c50 (
         p_per_in_ler_id   NUMBER
      ) IS
         SELECT        ELIG_PER_ELCTBL_CHC_ID
         FROM          BEN_ELIG_PER_ELCTBL_CHC
         WHERE         per_in_ler_id = p_per_in_ler_id
	 FOR UPDATE OF ELIG_PER_ELCTBL_CHC_ID;

--
l_PIL_ELCTBL_CHC_POPL_ID Number;
l_ELIG_PER_ELCTBL_CHC_ID Number;
--End Bug 4653271

      l_id   NUMBER;

   BEGIN
      delete_dependent_information (
         p_person_id
      );
      delete_communications (
         p_person_id
      );
      delete_life_events (
         p_person_id
      );
      delete_participant_information (
         p_person_id
      );
      delete_benefit_action_children (
         p_person_id
      );
      FOR r7 IN c7 LOOP
         DELETE FROM ben_elig_per_wv_pl_typ_f
         WHERE       elig_per_id = r7.elig_per_id;
      END LOOP;
      FOR r9 IN c9 LOOP
         DELETE FROM ben_prtt_vstg_f
         WHERE       element_entry_id = r9.element_entry_id;
      END LOOP;
      delete_reimbmt_rqst (
         p_person_id
      );
      --
      OPEN c20 (
         p_person_id
      );
      <<ben_batch_actn_item_info>>
      LOOP
         FETCH c20 INTO l_id;
         EXIT WHEN c20%NOTFOUND;
         DELETE FROM ben_batch_actn_item_info
         WHERE  CURRENT OF c20;
      END LOOP ben_batch_actn_item_info;
      CLOSE c20;
      --
      OPEN c21 (
         p_person_id
      );
      <<ben_batch_bnft_cert_info>>
      LOOP
         FETCH c21 INTO l_id;
         EXIT WHEN c21%NOTFOUND;
         DELETE FROM ben_batch_bnft_cert_info
         WHERE  CURRENT OF c21;
      END LOOP ben_batch_bnft_cert_info;
      CLOSE c21;
      --
      OPEN c22 (
         p_person_id
      );
      <<ben_batch_commu_info>>
      LOOP
         FETCH c22 INTO l_id;
         EXIT WHEN c22%NOTFOUND;
         DELETE FROM ben_batch_commu_info
         WHERE  CURRENT OF c22;
      END LOOP ben_batch_commu_info;
      CLOSE c22;
      --
      OPEN c23 (
         p_person_id
      );
      <<ben_batch_dpnt_info>>
      LOOP
         FETCH c23 INTO l_id;
         EXIT WHEN c23%NOTFOUND;
         DELETE FROM ben_batch_dpnt_info
         WHERE  CURRENT OF c23;
      END LOOP ben_batch_dpnt_info;
      CLOSE c23;
      --
      OPEN c24 (
         p_person_id
      );
      <<ben_batch_elctbl_chc_info>>
      LOOP
         FETCH c24 INTO l_id;
         EXIT WHEN c24%NOTFOUND;
         DELETE FROM ben_batch_elctbl_chc_info
         WHERE  CURRENT OF c24;
      END LOOP ben_batch_elctbl_chc_info;
      CLOSE c24;
      OPEN c25 (
         p_person_id
      );
      <<ben_batch_elig_info>>
      LOOP
         FETCH c25 INTO l_id;
         EXIT WHEN c25%NOTFOUND;
         DELETE FROM ben_batch_elig_info
         WHERE  CURRENT OF c25;
      END LOOP ben_batch_elig_info;
      CLOSE c25;
      OPEN c26 (
         p_person_id
      );
      <<ben_batch_ler_info>>
      LOOP
         FETCH c26 INTO l_id;
         EXIT WHEN c26%NOTFOUND;
         DELETE FROM ben_batch_ler_info
         WHERE  CURRENT OF c26;
      END LOOP ben_batch_ler_info;
      CLOSE c26;
      OPEN c27 (
         p_person_id
      );
      <<ben_batch_rate_info>>
      LOOP
         FETCH c27 INTO l_id;
         EXIT WHEN c27%NOTFOUND;
         DELETE FROM ben_batch_rate_info
         WHERE  CURRENT OF c27;
      END LOOP ben_batch_rate_info;
      CLOSE c27;
      OPEN c28 (
         p_person_id
      );
      <<ben_reporting>>
      LOOP
         FETCH c28 INTO l_id;
         EXIT WHEN c28%NOTFOUND;
         DELETE FROM ben_reporting
         WHERE  CURRENT OF c28;
      END LOOP ben_reporting;
      CLOSE c28;
      OPEN c29 (
         p_person_id
      );
      <<ben_person_actions>>
      LOOP
         FETCH c29 INTO l_id;
         EXIT WHEN c29%NOTFOUND;
         DELETE FROM ben_person_actions
         WHERE  CURRENT OF c29;
      END LOOP ben_person_actions;
      CLOSE c29;
      OPEN c30 (
         p_person_id
      );
      <<ben_benefit_actions>>
      LOOP
         FETCH c30 INTO l_id;
         EXIT WHEN c30%NOTFOUND;
         DELETE FROM ben_benefit_actions
         WHERE  CURRENT OF c30;
      END LOOP ben_benefit_actions;
      CLOSE c30;
      OPEN c31 (
         p_person_id
      );
      <<ben_cbr_quald_bnf>>
      LOOP
         FETCH c31 INTO l_id;
         EXIT WHEN c31%NOTFOUND;
         DELETE FROM ben_cbr_quald_bnf
         WHERE  CURRENT OF c31;
      END LOOP ben_cbr_quald_bnf;
      CLOSE c31;
      OPEN c32 (
         p_person_id
      );
      <<ben_crt_ordr_cvrd_per>>
      LOOP
         FETCH c32 INTO l_id;
         EXIT WHEN c32%NOTFOUND;
         DELETE FROM ben_crt_ordr_cvrd_per
         WHERE  CURRENT OF c32;
      END LOOP ben_crt_ordr_cvrd_per;
      CLOSE c32;
      OPEN c33 (
         p_person_id
      );
      <<ben_crt_ordr>>
      LOOP
         FETCH c33 INTO l_id;
         EXIT WHEN c33%NOTFOUND;
         DELETE FROM ben_crt_ordr
         WHERE  CURRENT OF c33;
      END LOOP ben_crt_ordr;
      CLOSE c33;
      OPEN c34 (
         p_person_id
      );
      <<ben_elig_per_f>>
      LOOP
         FETCH c34 INTO l_id;
         EXIT WHEN c34%NOTFOUND;
         DELETE FROM ben_elig_per_f
         WHERE  CURRENT OF c34;
      END LOOP ben_elig_per_f;
      CLOSE c34;
      OPEN c35 (
         p_person_id
      );
      <<ben_ext_chg_evt_log>>
      LOOP
         FETCH c35 INTO l_id;
         EXIT WHEN c35%NOTFOUND;
         DELETE FROM ben_ext_chg_evt_log
         WHERE  CURRENT OF c35;
      END LOOP ben_ext_chg_evt_log;
      CLOSE c35;
      OPEN c36 (
         p_person_id
      );
      <<ben_ext_rslt_dtl>>
      LOOP
         FETCH c36 INTO l_id;
         EXIT WHEN c36%NOTFOUND;
         DELETE FROM ben_ext_rslt_dtl
         WHERE  CURRENT OF c36;
      END LOOP ben_ext_rslt_dtl;
      CLOSE c36;
      OPEN c37 (
         p_person_id
      );
      <<ben_ext_rslt_err>>
      LOOP
         FETCH c37 INTO l_id;
         EXIT WHEN c37%NOTFOUND;
         DELETE FROM ben_ext_rslt_err
         WHERE  CURRENT OF c37;
      END LOOP ben_ext_rslt_err;
      CLOSE c37;
      OPEN c38 (
         p_person_id
      );
      <<ben_per_bnfts_bal_f>>
      LOOP
         FETCH c38 INTO l_id;
         EXIT WHEN c38%NOTFOUND;
         DELETE FROM ben_per_bnfts_bal_f
         WHERE  CURRENT OF c38;
      END LOOP ben_per_bnfts_bal_f;
      CLOSE c38;
      OPEN c39 (
         p_person_id
      );
      <<ben_per_cm_f>>
      LOOP
         FETCH c39 INTO l_id;
         EXIT WHEN c39%NOTFOUND;
         DELETE FROM ben_per_cm_f
         WHERE  CURRENT OF c39;
      END LOOP ben_per_cm_f;
      CLOSE c39;
      OPEN c40 (
         p_person_id
      );
      <<ben_per_dlvry_mthd_f>>
      LOOP
         FETCH c40 INTO l_id;
         EXIT WHEN c40%NOTFOUND;
         DELETE FROM ben_per_dlvry_mthd_f
         WHERE  CURRENT OF c40;
      END LOOP ben_per_dlvry_mthd_f;
      CLOSE c40;
      OPEN c41 (
         p_person_id
      );
      <<ben_per_in_ler>>
      LOOP
         FETCH c41 INTO l_id;
         EXIT WHEN c41%NOTFOUND;
--Bug 4653271 Deletion of BEn - CWB information
	 DELETE FROM BEN_CWB_AUDIT WHERE group_per_in_ler_id=l_id;

	 DELETE FROM BEN_CWB_GROUP_HRCHY WHERE emp_per_in_ler_id=l_id;

 	 DELETE FROM BEN_CWB_PERSON_GROUPS WHERE group_per_in_ler_id=l_id;

	 DELETE FROM BEN_CWB_PERSON_TASKS WHERE group_per_in_ler_id=l_id;

	 OPEN c49(l_id);
	 <<ben_pil_elctbl_chc_popl>>
	 LOOP
	  FETCH c49 INTO l_pil_elctbl_chc_popl_id;
	  EXIT WHEN c49%NOTFOUND;
	  DELETE FROM BEN_CWB_HRCHY WHERE EMP_PIL_ELCTBL_CHC_POPL_ID = l_pil_elctbl_chc_popl_id;
	 END LOOP ben_pil_elctbl_chc_popl;
	 CLOSE c49;

	  OPEN c50(l_id);
	 <<ben_elig_per_elctbl_chc>>
	 LOOP
	  FETCH c50 INTO l_elig_per_elctbl_chc_id;
	  EXIT WHEN c50%NOTFOUND;
	  DELETE FROM BEN_CWB_MGR_HRCHY WHERE EMP_ELIG_PER_ELCTBL_CHC_ID = l_elig_per_elctbl_chc_id;
	  DELETE FROM BEN_CWB_MGR_HRCHY_RBV WHERE EMP_ELIG_PER_ELCTBL_CHC_ID = l_elig_per_elctbl_chc_id;
	 END LOOP ben_elig_per_elctbl_chc;
	 CLOSE c50;
-- End Bug 4653271
         DELETE FROM ben_per_in_ler
         WHERE  CURRENT OF c41;
      END LOOP ben_per_in_ler;
      CLOSE c41;

--Bug 4653271 Deletion of BEn - CWB information
      DELETE from BEN_CWB_PERSON_INFO where person_id = p_person_id;

      DELETE from BEN_CWB_PERSON_RATES where person_id = p_person_id;

      DELETE from BEN_CWB_SUMMARY where person_id = p_person_id;
-- End Bug 4653271

      OPEN c42 (
         p_person_id
      );
      <<ben_per_in_lgl_enty_f>>
      LOOP
         FETCH c42 INTO l_id;
         EXIT WHEN c42%NOTFOUND;
         DELETE FROM ben_per_in_lgl_enty_f
         WHERE  CURRENT OF c42;
      END LOOP ben_per_in_lgl_enty_f;
      CLOSE c42;
      OPEN c43 (
         p_person_id
      );
      <<ben_per_in_org_unit_f>>
      LOOP
         FETCH c43 INTO l_id;
         EXIT WHEN c43%NOTFOUND;
         DELETE FROM ben_per_in_org_unit_f
         WHERE  CURRENT OF c43;
      END LOOP ben_per_in_org_unit_f;
      CLOSE c43;

      OPEN c44 (
         p_person_id
      );
      <<ben_per_pin_f>>
      LOOP
         FETCH c44 INTO l_id;
         EXIT WHEN c44%NOTFOUND;
         DELETE FROM ben_per_pin_f
         WHERE  CURRENT OF c44;
      END LOOP ben_per_pin_f;
      CLOSE c44;

      OPEN c45 (
         p_person_id
      );
      <<ben_ptnl_ler_for_per>>
      LOOP
         FETCH c45 INTO l_id;
         EXIT WHEN c45%NOTFOUND;
         DELETE FROM ben_ptnl_ler_for_per
         WHERE  CURRENT OF c45;
      END LOOP ben_ptnl_ler_for_per;
      CLOSE c45;
      OPEN c46 (
         p_person_id
      );
      <<ben_popl_org_f>>
      LOOP
         FETCH c46 INTO l_id;
         EXIT WHEN c46%NOTFOUND;
         DELETE FROM ben_popl_org_f
         WHERE  CURRENT OF c46;
      END LOOP ben_popl_org_f;
      CLOSE c46;
      OPEN c47 (
         p_person_id
      );
      <<ben_ext_crit_val>>
      LOOP
         FETCH c47 INTO l_id;
         EXIT WHEN c47%NOTFOUND;
         DELETE FROM ben_ext_crit_val
         WHERE  CURRENT OF c47;
      END LOOP ben_ext_crit_val;
      CLOSE c47;

      OPEN c48 (
         p_person_id
      );
      <<ben_pl_bnf_f>>
      LOOP
         FETCH c48 INTO l_id;
         EXIT WHEN c48%NOTFOUND;
         DELETE FROM ben_pl_bnf_f
         WHERE  CURRENT OF c48;
      END LOOP ben_pl_bnf_f;
      CLOSE c48;

   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END delete_ben_rows;

   PROCEDURE check_ben_rows_before_delete(
                        p_person_id number ,
			p_effective_date date
                        ) is
      --
      l_proc  varchar2(200) := 'ben_person_delete.check_ben_rows_before_delete' ;
 /* Bug 7339987 : Modified c_pil,c_pen,c_prv,c_ecd,c_ecdpn,c_plbnf cursors to
 Allow Delete when UnRestricted LE is in STRTD state
 Do Not Allow Delete when Other types of LE is in STRTD state
 Do Not Allow Delete when Other types of LE is in PROCD state
 Allow Delete when Other types of LE is in BCKDT/VOIDD state
 */

      --cursor for the pils with STRTD status

      CURSOR c_pil( p_person_id number ,
                p_effective_date date
                ) is
        SELECT 'Y'
        FROM   ben_per_in_ler pil,
           ben_ler_f      ler
        WHERE  pil.person_id = p_person_id
        AND    pil.per_in_ler_stat_cd = 'STRTD'
        AND    pil.ler_id = ler.ler_id
        AND    pil.business_group_id = ler.business_group_id
        AND    p_effective_date between ler.effective_start_date and
                                    ler.effective_end_date
        AND    ler.typ_cd <> 'SCHEDDU' ;
      --
      --  cursor to get active pen records
      --
      CURSOR c_pen( p_person_id number ,
                p_effective_date date
                ) is
         SELECT 'Y'
         FROM   ben_prtt_enrt_rslt_f pen,
	        ben_ler_f      ler
         WHERE  pen.person_id=p_person_id and
                pen.prtt_enrt_rslt_stat_cd is null and
     --           pen.sspndd_flag='N' and            Needs to resolve suspended record also
                pen.effective_end_date = hr_api.g_eot and
                p_effective_date between pen.enrt_cvg_strt_dt and
                                         pen.enrt_cvg_thru_dt
	        and ler.ler_id=pen.ler_id
		AND pen.business_group_id = ler.business_group_id
                AND    p_effective_date between ler.effective_start_date and
                                    ler.effective_end_date
                AND    ler.typ_cd <> 'SCHEDDU';
      --
      --  cursor to get active rate records
      --
      CURSOR c_prv( p_person_id number ,
                    p_effective_date date
                    ) is
        SELECT 'Y'
        FROM   ben_prtt_rt_val prv,
               ben_prtt_enrt_rslt_f pen,
               ben_ler_f      ler
        WHERE
               pen.person_id=p_person_id and
               prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id and
               pen.prtt_enrt_rslt_stat_cd is null and
               p_effective_date between prv.rt_strt_dt and prv.rt_end_dt and
               prv.business_group_id = pen.business_group_id and
               prv.prtt_rt_val_stat_cd is null
	        and ler.ler_id=pen.ler_id
		AND pen.business_group_id = ler.business_group_id
                AND    p_effective_date between ler.effective_start_date and
                                    ler.effective_end_date
                AND    ler.typ_cd <> 'SCHEDDU';
      --
      --  cursor to get active dependents
      --
      CURSOR c_ecd( p_person_id number ,
                p_effective_date date
                ) is
        SELECT 'Y'
        FROM   ben_elig_cvrd_dpnt_f ecd,
               ben_per_in_ler pil,
	       ben_ler_f      ler,
	       ben_prtt_enrt_rslt_f pen
        WHERE
               pil.person_id=p_person_id and
               pil.per_in_ler_id = ecd.per_in_ler_id and
               pil.business_group_id = ecd.business_group_id and
               p_effective_date between ecd.cvg_strt_dt and cvg_thru_dt and
               ecd.effective_end_date = hr_api.g_eot
	       and ecd.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id and
               pen.prtt_enrt_rslt_stat_cd is null
	        AND    pil.ler_id = ler.ler_id
		AND    pil.business_group_id = ler.business_group_id
		AND    p_effective_date between ler.effective_start_date and
					    ler.effective_end_date
		AND    ler.typ_cd <> 'SCHEDDU';
      --
      -- if the person is dpnt then validate the cvrd dpnt
      --
        CURSOR c_ecdpn( p_person_id number ,
                p_effective_date date
                ) is
        SELECT 'Y'
        FROM   ben_elig_cvrd_dpnt_f ecd,
	       ben_per_in_ler pil,
	       ben_ler_f      ler,
	       ben_prtt_enrt_rslt_f pen
        WHERE
               ecd.dpnt_person_id = p_person_id and
               p_effective_date between ecd.cvg_strt_dt and cvg_thru_dt and
               ecd.effective_end_date = hr_api.g_eot
	        and pil.per_in_ler_id = ecd.per_in_ler_id
		and pil.business_group_id = ecd.business_group_id
		and ecd.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id and
                pen.prtt_enrt_rslt_stat_cd is null
		AND    pil.ler_id = ler.ler_id
		AND    pil.business_group_id = ler.business_group_id
		AND    p_effective_date between ler.effective_start_date and
					    ler.effective_end_date
		AND    ler.typ_cd <> 'SCHEDDU';

      --  if the person is dpnt and only beneficiary
      CURSOR c_plbnf( p_person_id number ,
                p_effective_date date
                ) is
        SELECT 'Y'
        FROM   ben_pl_bnf_f pbn,
	       ben_per_in_ler pil,
               ben_ler_f      ler,
	       ben_prtt_enrt_rslt_f pen
        WHERE
               pbn.bnf_person_id = p_person_id and
               p_effective_date between pbn.dsgn_strt_dt and pbn.dsgn_thru_dt and
               pbn.effective_end_date = hr_api.g_eot
	        and pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id and
                pen.prtt_enrt_rslt_stat_cd is null
	        and pil.per_in_ler_id=pbn.per_in_ler_id
		AND    pil.business_group_id = pbn.business_group_id
	        AND    pil.ler_id = ler.ler_id
		AND    pil.business_group_id = ler.business_group_id
		AND    p_effective_date between ler.effective_start_date and
					    ler.effective_end_date
		AND    ler.typ_cd <> 'SCHEDDU';



      l_dummy varchar2(1) := 'N' ;
    BEGIN
      hr_utility.set_location('Entering '||l_proc , 10);
      --check for per_in_ler in started status. Exclude the unrestricted cases
      open c_pil(p_person_id,p_effective_date) ;
        --
        fetch c_pil into l_dummy ;
        if c_pil%found then
          --
          hr_utility.set_location('Started Pil exist for person '||p_person_id , 20);
          close c_pil ;
          fnd_message.set_name('BEN', 'BEN_92720_BEN_DATA_EXISTS');
          fnd_message.set_token('BEN_ITEM','Life Event');
          fnd_message.raise_error;
          --
        end if;
        close c_pil ;
      --check for active enrollment result records
      open c_pen(p_person_id,p_effective_date);
        --
        fetch c_pen into l_dummy ;
        if c_pen%found then
          --
          hr_utility.set_location('Started pen exist for person '||p_person_id , 30);
          close c_pen ;
          fnd_message.set_name('BEN', 'BEN_92720_BEN_DATA_EXISTS');
          fnd_message.set_token('BEN_ITEM','Enrollment');
          fnd_message.raise_error;
          --
        end if;
        close c_pen ;
      --check for active rate records
      open c_prv(p_person_id,p_effective_date) ;
        --
        fetch c_prv into l_dummy ;
        if c_prv%found then
          --
          hr_utility.set_location('Started prv  exist for person '||p_person_id , 40);
          close c_prv ;
          fnd_message.set_name('BEN', 'BEN_92720_BEN_DATA_EXISTS');
          fnd_message.set_token('BEN_ITEM','Rate');
          fnd_message.raise_error;
          --
        end if;
        close c_prv ;
      --check for active dependents
      open c_ecd(p_person_id,p_effective_date) ;
        --
        fetch c_ecd into l_dummy ;
        if c_ecd%found then
          --
          hr_utility.set_location('Started ecd exist for person '||p_person_id , 50);
          close c_ecd ;
          fnd_message.set_name('BEN', 'BEN_92720_BEN_DATA_EXISTS');
          fnd_message.set_token('BEN_ITEM','Dependents');
          fnd_message.raise_error;
          --
        end if;
        close c_ecd ;
        --
        --check whether the operson coverd as dpnt
        open c_ecdpn(p_person_id,p_effective_date) ;
        --
        fetch c_ecdpn into l_dummy ;
        if c_ecdpn%found then
          --
          hr_utility.set_location('Started ecdpn exist for person '||p_person_id , 50);
          close c_ecdpn ;
          fnd_message.set_name('BEN', 'BEN_93910_DPTN_CVRD');
          fnd_message.raise_error;
          --
        end if;
        close c_ecdpn ;

        --check whether the operson coverd as beneficiary
        open c_plbnf(p_person_id,p_effective_date) ;
        --
        fetch c_plbnf into l_dummy ;
        if c_plbnf%found then
          --
          hr_utility.set_location('Started ecdpn exist for person '||p_person_id , 50);
          close c_plbnf ;
          fnd_message.set_name('BEN', 'BEN_93911_DPT_DESIG_BNF');
          fnd_message.raise_error;
          --
        end if;
        close c_plbnf ;


        --
      hr_utility.set_location('Leaving '||l_proc , 100);
      --
    EXCEPTION
    WHEN OTHERS THEN
         RAISE;
    END check_ben_rows_before_delete ;
    --
END ben_person_delete;

/
