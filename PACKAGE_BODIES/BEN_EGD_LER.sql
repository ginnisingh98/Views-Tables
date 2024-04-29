--------------------------------------------------------
--  DDL for Package Body BEN_EGD_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGD_LER" AS
/* $Header: beegdtrg.pkb 120.2.12010000.2 2010/03/24 14:54:22 pvelvano ship $*/
  --
  -- Cached static values
  --
  g_trunc_sysdate     DATE;
  g_oabinstall_status VARCHAR2(1);
  --
  PROCEDURE ler_chk(p_old            in g_egd_ler_rec,
                    p_new            in g_egd_ler_rec,
                    p_effective_date in date) IS
--
    l_proc varchar2(72) :=  'ben_egd_ler.ler_chk';
--
    l_egdlertrg_set          ben_letrg_cache.g_egdlertrg_inst_tbl;
--
    l_session_date           DATE;
    l_system_date            DATE;
--
    CURSOR get_session_date IS
      SELECT   fs.effective_date
      FROM     fnd_sessions fs
      WHERE    fs.session_id = USERENV('SESSIONID');
--
    cursor get_ler(l_status varchar2) is
      SELECT   ler.ler_id,
               ler.ocrd_dt_det_cd
      FROM     ben_ler_f ler
      WHERE    ler.business_group_id = p_new.business_group_id
      AND      l_session_date BETWEEN ler.effective_start_date
                   AND ler.effective_end_date
      AND      (
                    (
                          EXISTS
                          (SELECT   1
                           FROM     ben_per_info_chg_cs_ler_f psl,
                                    ben_ler_per_info_cs_ler_f lpl
                           WHERE    psl.source_table = 'BEN_ELIG_DPNT'
                           AND      psl.per_info_chg_cs_ler_id =
                                                     lpl.per_info_chg_cs_ler_id
                           AND      l_session_date BETWEEN psl.effective_start_date
                                        AND psl.effective_end_date
                           AND      lpl.ler_id = ler.ler_id
                           AND      l_session_date BETWEEN lpl.effective_start_date
                                        AND lpl.effective_end_date)
                      )
                 OR (
                          EXISTS
                          (SELECT   1
                           FROM     ben_ler_rltd_per_cs_ler_f lrp,
                                    ben_rltd_per_chg_cs_ler_f rpc
                           WHERE    rpc.source_table = 'BEN_ELIG_DPNT'
                           AND      l_session_date BETWEEN rpc.effective_start_date
                                        AND rpc.effective_end_date
                           AND      rpc.rltd_per_chg_cs_ler_id =
                                                     lrp.rltd_per_chg_cs_ler_id
                           AND      lrp.ler_id = ler.ler_id
                           AND      l_session_date BETWEEN lrp.effective_start_date
                                        AND lrp.effective_end_date)
                      )
                );
 --

    CURSOR get_ler_col(p_ler_id IN ben_ler_f.ler_id%TYPE) IS
      SELECT   psl.source_column,
               psl.new_val,
               psl.old_val,
               'P',
               psl.per_info_chg_cs_ler_rl, psl.rule_overrides_flag, lpl.chg_mandatory_cd
      FROM     ben_ler_per_info_cs_ler_f lpl, ben_per_info_chg_cs_ler_f psl
      WHERE    lpl.ler_id = p_ler_id
      AND      lpl.business_group_id = p_new.business_group_id
      AND      lpl.business_group_id = psl.business_group_id
      AND      l_session_date BETWEEN psl.effective_start_date
                   AND psl.effective_end_date
      AND      l_session_date BETWEEN lpl.effective_start_date
                   AND lpl.effective_end_date
      AND      psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
      AND      source_table = 'BEN_ELIG_DPNT'
      UNION ALL
      SELECT   rpc.source_column,
               rpc.new_val,
               rpc.old_val,
               'R',
               rpc.rltd_per_chg_cs_ler_rl per_info_chg_cs_ler, rpc.rule_overrides_flag, lrp.chg_mandatory_cd
      FROM     ben_ler_rltd_per_cs_ler_f lrp, ben_rltd_per_chg_cs_ler_f rpc
      WHERE    lrp.ler_id = p_ler_id
      AND      lrp.business_group_id = p_new.business_group_id
      AND      lrp.business_group_id = rpc.business_group_id
      AND      l_session_date BETWEEN rpc.effective_start_date
                   AND rpc.effective_end_date
      AND      l_session_date BETWEEN lrp.effective_start_date
                   AND lrp.effective_end_date
      AND      rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
      AND      source_table = 'BEN_ELIG_DPNT'
      order by 1;
--
    CURSOR le_exists(
      p_person_id      IN per_all_people_f.person_id%TYPE,
      p_ler_id         IN ben_ler_f.ler_id%TYPE,
      p_lf_evt_ocrd_dt IN DATE) IS
      SELECT   'Y'
      FROM     ben_ptnl_ler_for_per bp
      WHERE    bp.person_id = p_person_id
      AND      bp.ler_id = p_ler_id
      AND      bp.ptnl_ler_for_per_stat_cd = 'DTCTD'
      AND      bp.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
--
    CURSOR get_contacts(p_person_id IN per_all_people_f.person_id%TYPE) IS
      SELECT   pcr.contact_person_id
      FROM     per_contact_relationships pcr
      WHERE    pcr.person_id = p_person_id
      AND      pcr.business_group_id = p_new.business_group_id
      AND      l_session_date BETWEEN NVL(pcr.date_start, l_session_date)
                   AND NVL(pcr.date_end, l_session_date);

--Bug 5630251    Fetch person_id from the p_new.per_in_ler_id
    cursor get_person  IS
      select person_id
      from ben_per_in_ler
      where per_in_ler_id = p_new.per_in_ler_id
      and per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      and business_Group_id = p_new.business_group_id;

      l_person_id number := -999999999;

--End Bug 5630251
--
    l_changed                BOOLEAN;
    l_ler_id                 NUMBER;
    l_typ_cd                 ben_ler_f.typ_cd%type ;
    l_column ben_rltd_per_chg_cs_ler_f.source_column%type;  -- VARCHAR2(30);
    l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;   -- VARCHAR2(30);
    l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;       -- VARCHAR2(30);
    l_ocrd_dt_cd             VARCHAR2(30);
    l_per_info_chg_cs_ler_rl NUMBER;
    l_rule_output            VARCHAR2(1);
    l_ovn                    NUMBER;
    l_ptnl_id                NUMBER;
    l_effective_start_date   DATE;
    l_lf_evt_ocrd_date       DATE;
    l_le_exists              VARCHAR2(1);
    l_elig_strt_dt           DATE;
    l_elig_thru_dt           DATE;
    l_create_dt              DATE;
    l_type                   VARCHAR2(1);
    l_hld_person_id          NUMBER;
--
    l_bool                   BOOLEAN;
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
--
    l_col_old_val            VARCHAR2(1000);
    l_col_new_val            VARCHAR2(1000);
--
    l_rule_overrides_flag VARCHAR2(1);
    l_chg_mandatory_cd VARCHAR2(1);
l_trigger boolean := TRUE;
--
--
    l_rec_business_group_id  ben_ler_f.business_group_id%TYPE
                      := NVL(p_new.business_group_id, p_old.business_group_id);
    l_rec_dpnt_person_id     per_all_people_f.person_id%TYPE
                            := NVL(p_new.dpnt_person_id, p_old.dpnt_person_id);


/*Bug 9500422: Add the dpnt_person_id to the list if there is a change in BEN_ELIG_DPNT data of a dependent.
Before creating the potential check whether the dpnt_person_id is in the list,if present then
create the potential*/
 TYPE g_dpnt_person_id_tab IS TABLE OF NUMBER;
 g_dpnt_person_id_list g_dpnt_person_id_tab := g_dpnt_person_id_tab();

 function is_present(p_dpnt_person_id number) return boolean is
      begin
         if(g_dpnt_person_id_list.FIRST is not NULL and g_dpnt_person_id_list.LAST is not NULL) then
	    FOR i IN g_dpnt_person_id_list.FIRST..g_dpnt_person_id_list.LAST LOOP
		IF g_dpnt_person_id_list(i) = p_dpnt_person_id THEN
		    return true;
		  EXIT;
		END IF;
	    END LOOP;
        end if;
	return false;
 end is_present;
 /*End Bug 9500422*/

--
  BEGIN
    --
    -- Bug 3320133
     benutils.set_data_migrator_mode;
    -- End of Bug 3320133

    -- Not to be called when Data Migrator is in progress
    --
    if hr_general.g_data_migrator_mode not in ( 'Y','P') then
      --
      hr_utility.set_location(' No DM ' || l_proc, 10);
      --
      -- Check if truncated sysdate global has previously been set
      -- if not then set it
      --
      if g_trunc_sysdate is null then
        --
        g_trunc_sysdate := TRUNC(SYSDATE);
        --
      end if;
      --
      l_system_date := g_trunc_sysdate;
      --
     /*
     -- Check if oab install status global has previously been set
      -- if not then set it
      --
      if g_oabinstall_status is null then
        --
        l_bool := fnd_installation.get
                    (appl_id     => 805
                    ,dep_appl_id => 805
                    ,status      => l_status
                    ,industry    => l_industry
                    );
        --
        g_oabinstall_status := l_status;
        --
      end if;
      --
      l_status := g_oabinstall_status;
      --
      IF l_status = 'I' THEN
      */
      -- commented since the L_status check is available in the beltrgch cursor itself.

        hr_utility.set_location(' Entering: ben_egd_trigger', 10);
        --
        -- Check if oab install status global has previously been set
        -- if not then set it
        --
        l_session_date := p_effective_date;
        --
        l_changed :=               FALSE;
        l_effective_start_date :=  l_session_date;
        -- in some situations the date we use for occured on date is null,
        -- use session date instead.
        l_elig_strt_dt :=          NVL(p_new.elig_strt_dt, l_session_date);
        l_elig_thru_dt :=          NVL(p_new.elig_thru_dt, l_session_date);
        l_create_dt :=             NVL(p_new.create_dt, l_session_date);
        hr_utility.set_location(' ben_egd_trigger', 20);
        --
        -- Get the ler details list
        --
        hr_utility.set_location(' LE EGD Cac ' || l_proc, 10);
        ben_letrg_cache.get_egdlertrg_dets
          (p_business_group_id => p_new.business_group_id
          ,p_effective_date    => l_session_date
          ,p_inst_set	     => l_egdlertrg_set
          );
        hr_utility.set_location(' Dn LE EGD Cac ' || l_proc, 10);
        --
        if l_egdlertrg_set.count > 0 then
          --
          for ler_row in l_egdlertrg_set.first..l_egdlertrg_set.last loop
            --
            l_ler_id := l_egdlertrg_set(ler_row).ler_id;
            l_typ_cd := l_egdlertrg_set(ler_row).typ_cd;
            --
            l_trigger := TRUE;
            IF l_egdlertrg_set(ler_row).ocrd_dt_det_cd IS NULL THEN
              l_lf_evt_ocrd_date :=  l_elig_strt_dt;
            ELSE
              --
              --   Call the common date procedure.
              --
              ben_determine_date.main(
                p_date_cd        => l_egdlertrg_set(ler_row).ocrd_dt_det_cd,
                p_effective_date => l_elig_strt_dt,
                p_lf_evt_ocrd_dt => p_new.elig_strt_dt,
                p_returned_date  => l_lf_evt_ocrd_date);
            END IF;
            --
            OPEN get_ler_col(l_egdlertrg_set(ler_row).ler_id);
            <<get_ler_col_loop>>
            LOOP
              FETCH get_ler_col INTO l_column,
                                     l_new_val,
                                     l_old_val,
                                     l_type,
                                     l_per_info_chg_cs_ler_rl, l_rule_overrides_flag, l_chg_mandatory_cd;
              EXIT get_ler_col_loop WHEN get_ler_col%NOTFOUND;
              hr_utility.set_location('LER ' || l_egdlertrg_set(ler_row).ler_id, 20);
              hr_utility.set_location('COLUMN ' || l_column, 20);
              hr_utility.set_location('NEWVAL ' || l_new_val, 20);
              hr_utility.set_location('OLDVAL ' || l_old_val, 20);
              hr_utility.set_location('TYPE ' || l_type, 20);
              hr_utility.set_location('CD ' || l_egdlertrg_set(ler_row).ocrd_dt_det_cd, 20);
              hr_utility.set_location('create dt' || l_create_dt, 20);
              hr_utility.set_location('elig strt dt ' || l_elig_strt_dt, 20);
              hr_utility.set_location('elig thru dt ' || l_elig_thru_dt, 20);
              l_changed := TRUE;
      			if get_ler_col%ROWCOUNT = 1 then
                l_changed :=  TRUE;
              END IF;
              hr_utility.set_location(' ben_egd_trigger', 50);
              --
              -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
              -- If it returns Y, then see the applicability of the data
              -- changes based on new and old values.
              --
              l_rule_output :=  'Y';
              --
              IF l_per_info_chg_cs_ler_rl IS NOT NULL THEN
                --
                IF l_column = 'DPNT_PERSON_ID' THEN
                  l_col_old_val :=  TO_CHAR(p_old.dpnt_person_id);
                  l_col_new_val :=  TO_CHAR(p_new.dpnt_person_id);
                ELSIF l_column = 'ELIG_STRT_DT' THEN
                  l_col_old_val :=
                              TO_CHAR(p_old.elig_strt_dt, 'YYYY/MM/DD HH24:MI:SS');
                  l_col_new_val :=
                              TO_CHAR(p_new.elig_strt_dt, 'YYYY/MM/DD HH24:MI:SS');
                ELSIF l_column = 'ELIG_THRU_DT' THEN
                  l_col_old_val :=
                              TO_CHAR(p_old.elig_thru_dt, 'YYYY/MM/DD HH24:MI:SS');
                  l_col_new_val :=
                              TO_CHAR(p_new.elig_thru_dt, 'YYYY/MM/DD HH24:MI:SS');
                ELSIF l_column = 'DPNT_INELIG_FLAG' THEN
                  l_col_old_val :=  p_old.dpnt_inelig_flag;
                  l_col_new_val :=  p_new.dpnt_inelig_flag;
                ELSIF l_column = 'OVRDN_FLAG' THEN
                  l_col_old_val :=  p_old.ovrdn_flag;
                  l_col_new_val :=  p_new.ovrdn_flag;
                ELSIF l_column = 'CREATE_DT' THEN
                  l_col_old_val :=
                                 TO_CHAR(p_old.create_dt, 'YYYY/MM/DD HH24:MI:SS');
                  l_col_new_val :=
                                 TO_CHAR(p_new.create_dt, 'YYYY/MM/DD HH24:MI:SS');
                ELSIF l_column = 'OVRDN_THRU_DT' THEN
                  l_col_old_val :=
                             TO_CHAR(p_old.ovrdn_thru_dt, 'YYYY/MM/DD HH24:MI:SS');
                  l_col_new_val :=
                             TO_CHAR(p_new.ovrdn_thru_dt, 'YYYY/MM/DD HH24:MI:SS');
                ELSIF l_column = 'INELG_RSN_CD' THEN
                  l_col_old_val :=  p_old.inelg_rsn_cd;
                  l_col_new_val :=  p_new.inelg_rsn_cd;
                ELSIF l_column = 'ELIG_PER_ELCTBL_CHC_ID' THEN
                  l_col_old_val :=  TO_CHAR(p_old.elig_per_elctbl_chc_id);
                  l_col_new_val :=  TO_CHAR(p_new.elig_per_elctbl_chc_id);
                ELSIF l_column = 'PER_IN_LER_ID' THEN
                  l_col_old_val :=  TO_CHAR(p_old.per_in_ler_id);
                  l_col_new_val :=  TO_CHAR(p_new.per_in_ler_id);
                ELSIF l_column = 'ELIG_PER_ID' THEN
                  l_col_old_val :=  TO_CHAR(p_old.elig_per_id);
                  l_col_new_val :=  TO_CHAR(p_new.elig_per_id);
                ELSIF l_column = 'ELIG_PER_OPT_ID' THEN
                  l_col_old_val :=  TO_CHAR(p_old.elig_per_opt_id);
                  l_col_new_val :=  TO_CHAR(p_new.elig_per_opt_id);
                ELSIF l_column = 'ELIG_CVRD_DPNT_ID' THEN
                  l_col_old_val :=  TO_CHAR(p_old.elig_cvrd_dpnt_id);
                  l_col_new_val :=  TO_CHAR(p_new.elig_cvrd_dpnt_id);
                END IF;
                --
                benutils.exec_rule(
                  p_formula_id        => l_per_info_chg_cs_ler_rl,
                  p_effective_date    => l_session_date,
                  p_lf_evt_ocrd_dt    => NULL,
                  p_business_group_id => l_rec_business_group_id,
                  p_person_id         => l_rec_dpnt_person_id,
                  p_new_value         => l_col_new_val,
                  p_old_value         => l_col_old_val,
                  p_column_name       => l_column,
                  p_param5            => 'BEN_EGD_IN_DPNT_PERSON_ID',
                  p_param5_value      => TO_CHAR(p_new.dpnt_person_id),
                  p_param6            => 'BEN_EGD_IO_DPNT_PERSON_ID',
                  p_param6_value      => TO_CHAR(p_old.dpnt_person_id),
                  p_param7            => 'BEN_EGD_IN_ELIG_STRT_DT',
                  p_param7_value      => TO_CHAR(
                                           p_new.elig_strt_dt,
                                           'YYYY/MM/DD HH24:MI:SS'),
                  p_param8            => 'BEN_EGD_IO_ELIG_STRT_DT',
                  p_param8_value      => TO_CHAR(
                                           p_old.elig_strt_dt,
                                           'YYYY/MM/DD HH24:MI:SS'),
                  p_param9            => 'BEN_EGD_IN_ELIG_THRU_DT',
                  p_param9_value      => TO_CHAR(
                                           p_new.elig_thru_dt,
                                           'YYYY/MM/DD HH24:MI:SS'),
                  p_param10           => 'BEN_EGD_IO_ELIG_THRU_DT',
                  p_param10_value     => TO_CHAR(
                                           p_old.elig_thru_dt,
                                           'YYYY/MM/DD HH24:MI:SS'),
                  p_param11           => 'BEN_EGD_IN_DPNT_INELIG_FLAG',
                  p_param11_value     => p_new.dpnt_inelig_flag,
                  p_param12           => 'BEN_EGD_IO_DPNT_INELIG_FLAG',
                  p_param12_value     => p_old.dpnt_inelig_flag,
                  p_param13           => 'BEN_EGD_IN_INELG_RSN_CD',
                  p_param13_value     => p_new.inelg_rsn_cd,
                  p_param14           => 'BEN_EGD_IO_INELG_RSN_CD',
                  p_param14_value     => p_old.inelg_rsn_cd,
                  p_param15           => 'BEN_EGD_IN_ELIG_PER_ELCTBL_CHC_ID',
                  p_param15_value     => TO_CHAR(p_new.elig_per_elctbl_chc_id),
                  p_param16           => 'BEN_EGD_IO_ELIG_PER_ELCTBL_CHC_ID',
                  p_param16_value     => TO_CHAR(p_old.elig_per_elctbl_chc_id),
                  p_param17           => 'BEN_EGD_IN_PER_IN_LER_ID',
                  p_param17_value     => TO_CHAR(p_new.per_in_ler_id),
                  p_param18           => 'BEN_EGD_IO_PER_IN_LER_ID',
                  p_param18_value     => TO_CHAR(p_old.per_in_ler_id),
                  p_param19           => 'BEN_EGD_IN_ELIG_PER_ID',
                  p_param19_value     => TO_CHAR(p_new.elig_per_id),
                  p_param20           => 'BEN_EGD_IO_ELIG_PER_ID',
                  p_param20_value     => TO_CHAR(p_old.elig_per_id),
                  p_param21           => 'BEN_EGD_IN_ELIG_PER_OPT_ID',
                  p_param21_value     => TO_CHAR(p_new.elig_per_opt_id),
                  p_param22           => 'BEN_EGD_IO_ELIG_PER_OPT_ID',
                  p_param22_value     => TO_CHAR(p_old.elig_per_opt_id),
                  p_param23           => 'BEN_EGD_IN_ELIG_CVRD_DPNT_ID',
                  p_param23_value     => TO_CHAR(p_new.elig_cvrd_dpnt_id),
                  p_param24           => 'BEN_EGD_IO_ELIG_CVRD_DPNT_ID',
                  p_param24_value     => TO_CHAR(p_old.elig_cvrd_dpnt_id),
                  p_param25           => 'BEN_IV_LER_ID',    /* Bug 3891096 */
                  p_param25_value     => to_char(l_ler_id),
                  p_pk_id             => TO_CHAR(p_new.elig_dpnt_id),
                  p_ret_val           => l_rule_output);
              --
              END IF;
              --
                              --
                IF l_column = 'ELIG_STRT_DT' THEN
                  l_changed :=
                   (
                         benutils.column_changed(
                           p_old.elig_strt_dt,
                           p_new.elig_strt_dt,
                           l_new_val)
                     AND benutils.column_changed(
                           p_new.elig_strt_dt,
                           p_old.elig_strt_dt,
                           l_old_val)
                     AND (l_changed));
                  hr_utility.set_location(' l_changed:', 40);
                ELSIF l_column = 'ELIG_THRU_DT' THEN
                  l_changed :=
                   (
                         benutils.column_changed(
                           p_old.elig_thru_dt,
                           p_new.elig_thru_dt,
                           l_new_val)
                     AND benutils.column_changed(
                           p_new.elig_thru_dt,
                           p_old.elig_thru_dt,
                           l_old_val)
                     AND (l_changed));
                  --
                  IF l_egdlertrg_set(ler_row).ocrd_dt_det_cd IS NULL THEN
                    l_lf_evt_ocrd_date :=  l_elig_thru_dt;
                  ELSE
                    --
                    --   Call the common date procedure.
                    --
                    ben_determine_date.main(
                      p_date_cd        => l_egdlertrg_set(ler_row).ocrd_dt_det_cd,
                      p_effective_date => l_elig_thru_dt,
                      p_lf_evt_ocrd_dt => p_new.elig_thru_dt,
                      p_returned_date  => l_lf_evt_ocrd_date);
                  END IF;
                --
                ELSIF l_column = 'DPNT_INELIG_FLAG' THEN
                  l_changed :=
                   (
                         benutils.column_changed(
                           p_old.dpnt_inelig_flag,
                           p_new.dpnt_inelig_flag,
                           l_new_val)
                     AND benutils.column_changed(
                           p_new.dpnt_inelig_flag,
                           p_old.dpnt_inelig_flag,
                           l_old_val)
                     AND (l_changed));
                  --
                  IF l_egdlertrg_set(ler_row).ocrd_dt_det_cd IS NULL THEN
                    l_lf_evt_ocrd_date :=  l_elig_thru_dt;
                  ELSE
                    --
                    --   Call the common date procedure.
                    --
                    ben_determine_date.main(
                      p_date_cd        => l_egdlertrg_set(ler_row).ocrd_dt_det_cd,
                      p_effective_date => l_elig_thru_dt,
                      p_lf_evt_ocrd_dt => p_new.elig_thru_dt,
                      p_returned_date  => l_lf_evt_ocrd_date);
                  END IF;
                --
                ELSIF l_column = 'OVRDN_THRU_DT' THEN
                  l_changed :=
                   (
                         benutils.column_changed(
                           p_old.ovrdn_thru_dt,
                           p_new.ovrdn_thru_dt,
                           l_new_val)
                     AND benutils.column_changed(
                           p_new.ovrdn_thru_dt,
                           p_old.ovrdn_thru_dt,
                           l_old_val)
                     AND (l_changed));
                  --
                  IF l_egdlertrg_set(ler_row).ocrd_dt_det_cd IS NULL THEN
                    l_lf_evt_ocrd_date :=  l_create_dt;
                  ELSE
                    --
                    --   Call the common date procedure.
                    --
                    ben_determine_date.main(
                      p_date_cd        => l_egdlertrg_set(ler_row).ocrd_dt_det_cd,
                      p_effective_date => l_create_dt,
                      p_lf_evt_ocrd_dt => p_new.create_dt,
                      p_returned_date  => l_lf_evt_ocrd_date);
                  END IF;
                --
                ELSIF l_column = 'OVRDN_FLAG' THEN
                  hr_utility.set_location(
                    'Old ovrdn_flag ' || p_old.ovrdn_flag,
                    20);
                  hr_utility.set_location(
                    'New ovrdn_flag ' || p_new.ovrdn_flag,
                    20);
                  hr_utility.set_location('lodt ' || l_lf_evt_ocrd_date, 20);
                  l_changed :=
                   (
                         benutils.column_changed(
                           p_old.ovrdn_flag,
                           p_new.ovrdn_flag,
                           l_new_val)
                     AND benutils.column_changed(
                           p_new.ovrdn_flag,
                           p_old.ovrdn_flag,
                           l_old_val)
                     AND (l_changed));
                  --
                  IF l_egdlertrg_set(ler_row).ocrd_dt_det_cd IS NULL THEN
                    l_lf_evt_ocrd_date :=  l_create_dt;
                  ELSE
                    --
                    --   Call the common date procedure.
                    --
                    ben_determine_date.main(
                      p_date_cd        => l_egdlertrg_set(ler_row).ocrd_dt_det_cd,
                      p_effective_date => l_create_dt,
                      p_lf_evt_ocrd_dt => p_new.create_dt,
                      p_returned_date  => l_lf_evt_ocrd_date);
                  END IF;
                END IF;
              -- End of all Column checkings

              --
			--
			-- Checking the rule output and the rule override flag.
			-- Whether the rule is mandatory or not, rule output should return 'Y'
			-- Rule Mandatory flag is just to override the column data change.

				if l_rule_output = 'Y' and l_rule_overrides_flag = 'Y' then
				   l_changed := TRUE ;
				elsif l_rule_output = 'Y' and l_rule_overrides_flag = 'N' then
				   l_changed := l_changed AND TRUE;
				elsif l_rule_output = 'N' then
					  hr_utility.set_location(' Rule output is N, so we should not trigger LE', 20.01);
				   l_changed := FALSE;
				end if;

				hr_utility.set_location('After the rule Check ',20.05);
				if l_changed then
				   hr_utility.set_location('     l_change TRUE l_rule_overrides_flag '||l_rule_overrides_flag, 20.1);
				else
				   hr_utility.set_location('     l_change FALSE l_rule_overrides_flag '||l_rule_overrides_flag, 20.1);
				end if;
			-- Check for Column Mandatory Change
			-- If column change is mandatory and data change has failed then dont trigger
			-- If column change is non-mandatory and the data change has passed, then trigger.

                           /*Bug 9500422: if there is a change, add the dpnt_person_id to the list*/
                           if(l_changed) then
			           hr_utility.set_location('Adding p_new.DPNT_PERSON_ID  '||p_new.DPNT_PERSON_ID,855);
				   g_dpnt_person_id_list.extend;
				   g_dpnt_person_id_list(g_dpnt_person_id_list.last) := p_new.DPNT_PERSON_ID;
			   end if;
			   /*End Bug 9500422*/


				if l_chg_mandatory_cd = 'Y' and not l_changed then
					hr_utility.set_location('Found Mandatory and its failed ', 20.1);
					l_changed := FALSE;
					l_trigger := FALSE;
					exit;
				 elsif l_chg_mandatory_cd = 'Y' and l_changed then
					hr_utility.set_location('Found Mandatory and its passed ', 20.1);
					l_changed := TRUE;
				--	exit; */
				elsif l_chg_mandatory_cd = 'N' and l_changed then
					hr_utility.set_location('Found First Non-Mandatory and its passed ', 20.1);
					l_changed := TRUE;
					l_trigger := TRUE;
					exit;
				end if;

				hr_utility.set_location('After the Mandatory code check ',20.05);
				if l_changed then
					hr_utility.set_location('       l_change TRUE ', 20.1);
				else
					hr_utility.set_location('        l_change FALSE ', 20.1);
				end if;
				--
				/* if not l_changed then
								exit;
				end if; */

            END LOOP get_ler_col_loop;
            hr_utility.set_location('  ben_egd_trigger', 50);
            l_ptnl_id :=  0;
            l_ovn :=      NULL;

	    --Bug 5630251
	    open get_person;
	    fetch get_person into l_person_id;

		if get_person%notfound then
		  l_person_id := -999999999;
	         end if;

            hr_utility.set_location('l_person_id' || l_person_id , 50);
            hr_utility.set_location('per_in_ler_id' || p_new.per_in_ler_id, 50);

	    close get_person;
	    --End Bug 5630251

            if l_trigger and (l_person_id <> -999999999) then  --Bug 5630251
              IF l_type = 'P' THEN
                OPEN le_exists(l_person_id, l_ler_id, l_lf_evt_ocrd_date);  --Bug 5630251
                FETCH le_exists INTO l_le_exists;
                IF le_exists%NOTFOUND THEN
                  hr_utility.set_location(' Entering: ben_egd_trigger5', 60);

                  ben_create_ptnl_ler_for_per.create_ptnl_ler_event(
                  --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per(
                    p_validate                 => FALSE,
                    p_ptnl_ler_for_per_id      => l_ptnl_id,
                    p_ntfn_dt                  => l_system_date,
                    p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_date,
                    p_ptnl_ler_for_per_stat_cd => 'DTCTD',
                    p_ler_id                   => l_ler_id,
                    p_ler_typ_cd               => l_typ_cd,
                    p_person_id                => l_person_id, --Bug 5630251
                    p_business_group_id        => p_new.business_group_id,
                    p_object_version_number    => l_ovn,
                    p_effective_date           => l_effective_start_date,
                    p_dtctd_dt                 => l_effective_start_date);
                END IF;
                CLOSE le_exists;
              ELSIF l_type = 'R' THEN
                hr_utility.set_location(' Entering: ben_egd_trigger5-', 65);
                OPEN get_contacts(l_person_id);  --Bug 5630251
                <<get_contacts_loop>>
                LOOP
                  FETCH get_contacts INTO l_hld_person_id;
                  EXIT get_contacts_loop WHEN get_contacts%NOTFOUND;
		  /*Bug 9500422: Added below if.else condition. If dpnt_person_id is present in the list,
		  then create the potential*/
		  if(is_present(l_hld_person_id)) then
		          hr_utility.set_location(' Creating ptnl for dep', 60);
			  OPEN le_exists(l_hld_person_id, l_ler_id, l_lf_evt_ocrd_date);
			  FETCH le_exists INTO l_le_exists;
			  IF le_exists%NOTFOUND THEN
			    hr_utility.set_location(' Entering: ben_egd_trigger5', 60);

			    ben_create_ptnl_ler_for_per.create_ptnl_ler_event(
			    --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per(
			      p_validate                 => FALSE,
			      p_ptnl_ler_for_per_id      => l_ptnl_id,
			      p_ntfn_dt                  => l_system_date,
			      p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_date,
			      p_ptnl_ler_for_per_stat_cd => 'DTCTD',
			      p_ler_id                   => l_ler_id,
			      p_ler_typ_cd               => l_typ_cd,
			      p_person_id                => l_hld_person_id,
			      p_business_group_id        => p_new.business_group_id,
			      p_object_version_number    => l_ovn,
			      p_effective_date           => l_effective_start_date,
			      p_dtctd_dt                 => l_effective_start_date);
			  END IF;
			  l_ptnl_id :=  0;
			  l_ovn :=      NULL;
			  CLOSE le_exists;
		  end if;
                END LOOP get_contacts_loop;
                CLOSE get_contacts;
              END IF;
              --
              -- reset the variables.
              --
              l_changed :=               FALSE;
              l_ovn :=                   NULL;
              l_trigger   := TRUE;
              l_effective_start_date :=  l_session_date;
            --      l_lf_evt_ocrd_date := l_session_date;
            END IF;
            CLOSE get_ler_col;
          END LOOP get_ler_loop;
          hr_utility.set_location(' Dn get_ler loop ' || l_proc, 10);
--        END IF;
      END IF;
    END IF;
  END ler_chk;

END ben_egd_ler;

/
