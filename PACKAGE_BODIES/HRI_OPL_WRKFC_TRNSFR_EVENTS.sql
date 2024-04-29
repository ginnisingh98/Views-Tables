--------------------------------------------------------
--  DDL for Package Body HRI_OPL_WRKFC_TRNSFR_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_WRKFC_TRNSFR_EVENTS" AS
/* $Header: hriowevttrn.pkb 120.1.12000000.2 2007/04/12 13:24:20 smohapat noship $ */

TYPE g_chain_rec_type IS RECORD
 (node_from_sk        NUMBER,
  node_to_sk          NUMBER,
  node_from_exists    BOOLEAN,
  node_to_exists      BOOLEAN,
  direct_node_before  NUMBER,
  direct_node_after   NUMBER);

TYPE g_chain_cache_type IS TABLE OF g_chain_rec_type INDEX BY BINARY_INTEGER;

-- Simple table types
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;

-- PLSQL table of tables representing database table
g_mgrh_sup_psn_id          g_number_tab_type;
g_mgrh_sup_sc_fk           g_number_tab_type;
g_mgrh_psn_id              g_number_tab_type;
g_mgrh_trn_id              g_number_tab_type;
g_mgrh_asg_id              g_number_tab_type;
g_mgrh_wty_fk              g_varchar2_tab_type;
g_mgrh_date                g_date_tab_type;
g_mgrh_in_ind              g_number_tab_type;
g_mgrh_out_ind             g_number_tab_type;
g_mgrh_dir_ind             g_number_tab_type;
g_mgrh_dir_rec             g_number_tab_type;
g_mgrh_row_count           PLS_INTEGER;

-- PLSQL table of tables representing database table
g_orgh_sup_org_id          g_number_tab_type;
g_orgh_psn_id              g_number_tab_type;
g_orgh_asg_id              g_number_tab_type;
g_orgh_wty_fk              g_varchar2_tab_type;
g_orgh_date                g_date_tab_type;
g_orgh_in_ind              g_number_tab_type;
g_orgh_out_ind             g_number_tab_type;
g_orgh_dir_ind             g_number_tab_type;
g_orgh_hdc_trn             g_number_tab_type;
g_orgh_fte_trn             g_number_tab_type;
g_orgh_row_count           PLS_INTEGER;


-- ----------------------------------------------------------------------------
-- Resets globals
-- ----------------------------------------------------------------------------
PROCEDURE initialize_globals IS

BEGIN

  g_mgrh_row_count := 0;
  g_orgh_row_count := 0;

END initialize_globals;


-- ----------------------------------------------------------------------------
-- Deletes manager hierarchy transfers to be maintained incrementally
-- ----------------------------------------------------------------------------
PROCEDURE delete_transfers_mgrh(p_start_object_id   IN NUMBER,
                                p_end_object_id     IN NUMBER) IS

BEGIN

  -- Delete primary assignment changes
  DELETE FROM hri_mdp_mgrh_transfers_ct  mgrh_trn
  WHERE mgrh_trn.rowid IN
   (SELECT mgrh_trn2.rowid
    FROM
     hri_mdp_mgrh_transfers_ct  mgrh_trn2
    ,hri_eq_sprvsr_hrchy_chgs   eq
    WHERE mgrh_trn2.asg_assgnmnt_fk = eq.assignment_id
    AND eq.person_id BETWEEN p_start_object_id AND p_end_object_id
    AND mgrh_trn2.time_day_evt_fk >= eq.erlst_evnt_effective_date);

  -- Delete inherited secondary assignment changes
  DELETE FROM hri_mdp_mgrh_transfers_ct  mgrh_trn
  WHERE mgrh_trn.rowid IN
   (SELECT mgrh_trn2.rowid
    FROM
     hri_mdp_mgrh_transfers_ct  mgrh_trn2
    ,hri_eq_sprvsr_hrchy_chgs   eq
    WHERE mgrh_trn2.per_person_trn_fk = eq.person_id
    AND eq.person_id BETWEEN p_start_object_id AND p_end_object_id
    AND mgrh_trn2.time_day_evt_fk >= eq.erlst_evnt_effective_date);

END delete_transfers_mgrh;

-- ----------------------------------------------------------------------------
-- Deletes transfers to be maintained incrementally
-- ----------------------------------------------------------------------------
PROCEDURE delete_transfers(p_start_object_id   IN NUMBER,
                           p_end_object_id     IN NUMBER) IS

BEGIN

  DELETE FROM hri_mdp_mgrh_transfers_ct  mgrh_trn
  WHERE mgrh_trn.rowid IN
   (SELECT mgrh_trn2.rowid
    FROM
     hri_mdp_mgrh_transfers_ct  mgrh_trn2
    ,hri_eq_asgn_evnts          eq
    WHERE mgrh_trn2.asg_assgnmnt_fk = eq.assignment_id
    AND eq.assignment_id BETWEEN p_start_object_id AND p_end_object_id
    AND mgrh_trn2.time_day_evt_fk >= eq.erlst_evnt_effective_date
    AND mgrh_trn2.sec_asg_ind IS NULL);

  DELETE FROM hri_mdp_orgh_transfers_ct  orgh_trn
  WHERE orgh_trn.rowid IN
   (SELECT orgh_trn2.rowid
    FROM
     hri_mdp_orgh_transfers_ct  orgh_trn2
    ,hri_eq_asgn_evnts          eq
    WHERE orgh_trn2.asg_assgnmnt_fk = eq.assignment_id
    AND eq.assignment_id BETWEEN p_start_object_id AND p_end_object_id
    AND orgh_trn2.time_day_evt_fk >= eq.erlst_evnt_effective_date);

END delete_transfers;


-- ----------------------------------------------------------------------------
-- Bulk inserts stored rows for all transfers
-- ----------------------------------------------------------------------------
PROCEDURE bulk_insert_transfers IS

  l_user_id        NUMBER;
  l_current_time   DATE;

BEGIN

  -- Insert manager hierarchy transfers
  IF (g_mgrh_row_count > 0) THEN

    l_user_id := fnd_global.user_id;
    l_current_time := SYSDATE;

    -- Insert rows all at once
    -- Exception may occur if unique index is violated - it is possible
    -- for a transfer to be picked up twice if it is part of two simultaneous
    -- "team transfers" e.g. if 2 managers in a chain are simultaneously promoted,
    -- the lower promotion occurring "within" the higher level one.
    BEGIN

      FORALL i IN 1..g_mgrh_row_count
        INSERT INTO hri_mdp_mgrh_transfers_ct
         (mgr_sup_person_fk
         ,mgr_sup_mngrsc_fk
         ,per_person_fk
         ,per_person_trn_fk
         ,asg_assgnmnt_fk
         ,ptyp_wrktyp_fk
         ,time_day_evt_fk
         ,transfer_in_ind
         ,transfer_out_ind
         ,direct_ind
         ,direct_record_ind
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date)
          VALUES
           (g_mgrh_sup_psn_id(i)
           ,g_mgrh_sup_sc_fk(i)
           ,g_mgrh_psn_id(i)
           ,g_mgrh_trn_id(i)
           ,g_mgrh_asg_id(i)
           ,g_mgrh_wty_fk(i)
           ,g_mgrh_date(i)
           ,g_mgrh_in_ind(i)
           ,g_mgrh_out_ind(i)
           ,g_mgrh_dir_ind(i)
           ,g_mgrh_dir_rec(i)
           ,l_current_time
           ,l_user_id
           ,l_user_id
           ,l_user_id
           ,l_current_time);

    EXCEPTION WHEN OTHERS THEN

      -- Loop through inserting rows 1 at a time
      -- Skip any exceptions that occur
      FOR i IN 1..g_mgrh_row_count LOOP
        BEGIN
          INSERT INTO hri_mdp_mgrh_transfers_ct
           (mgr_sup_person_fk
           ,mgr_sup_mngrsc_fk
           ,per_person_fk
           ,per_person_trn_fk
           ,asg_assgnmnt_fk
           ,ptyp_wrktyp_fk
           ,time_day_evt_fk
           ,transfer_in_ind
           ,transfer_out_ind
           ,direct_ind
           ,direct_record_ind
           ,last_update_date
           ,last_update_login
           ,last_updated_by
           ,created_by
           ,creation_date)
            VALUES
             (g_mgrh_sup_psn_id(i)
             ,g_mgrh_sup_sc_fk(i)
             ,g_mgrh_psn_id(i)
             ,g_mgrh_trn_id(i)
             ,g_mgrh_asg_id(i)
             ,g_mgrh_wty_fk(i)
             ,g_mgrh_date(i)
             ,g_mgrh_in_ind(i)
             ,g_mgrh_out_ind(i)
             ,g_mgrh_dir_ind(i)
             ,g_mgrh_dir_rec(i)
             ,l_current_time
             ,l_user_id
             ,l_user_id
             ,l_user_id
             ,l_current_time);
        EXCEPTION WHEN OTHERS THEN
          null;
        END;
      END LOOP;

    END;

    g_mgrh_row_count := 0;

  END IF;

  -- Insert organization hierarchy transfers
  IF (g_orgh_row_count > 0) THEN

    l_user_id := fnd_global.user_id;
    l_current_time := SYSDATE;

    FORALL i IN 1..g_orgh_row_count
      INSERT INTO hri_mdp_orgh_transfers_ct
       (org_sup_organztn_fk
       ,per_person_fk
       ,asg_assgnmnt_fk
       ,ptyp_wrktyp_fk
       ,time_day_evt_fk
       ,transfer_in_ind
       ,transfer_out_ind
       ,direct_ind
       ,headcount_trn
       ,fte_trn
       ,last_update_date
       ,last_update_login
       ,last_updated_by
       ,created_by
       ,creation_date)
        VALUES
         (g_orgh_sup_org_id(i)
         ,g_orgh_psn_id(i)
         ,g_orgh_asg_id(i)
         ,g_orgh_wty_fk(i)
         ,g_orgh_date(i)
         ,g_orgh_in_ind(i)
         ,g_orgh_out_ind(i)
         ,g_orgh_dir_ind(i)
         ,g_orgh_hdc_trn(i)
         ,g_orgh_fte_trn(i)
         ,l_current_time
         ,l_user_id
         ,l_user_id
         ,l_user_id
         ,l_current_time);

    g_orgh_row_count := 0;

  END IF;

END bulk_insert_transfers;


-- ----------------------------------------------------------------------------
-- Inserts row into global pl/sql table
-- ----------------------------------------------------------------------------
PROCEDURE insert_mgrh_transfer_row(p_sup_person_id     IN NUMBER
                                  ,p_sup_mngrsc_fk     IN NUMBER
                                  ,p_trn_person_id     IN NUMBER
                                  ,p_transferee_id     IN NUMBER
                                  ,p_trn_assignment_id IN NUMBER
                                  ,p_trn_wrktyp_fk     IN VARCHAR2
                                  ,p_transfer_date     IN DATE
                                  ,p_transfer_in_ind   IN NUMBER
                                  ,p_transfer_out_ind  IN NUMBER
                                  ,p_direct_ind        IN NUMBER
                                  ,p_direct_rec        IN NUMBER) IS

BEGIN

  -- Add row
  g_mgrh_row_count := g_mgrh_row_count + 1;
  g_mgrh_sup_psn_id(g_mgrh_row_count) := p_sup_person_id;
  g_mgrh_sup_sc_fk(g_mgrh_row_count)  := p_sup_mngrsc_fk;
  g_mgrh_psn_id(g_mgrh_row_count)     := p_trn_person_id;
  g_mgrh_trn_id(g_mgrh_row_count)     := p_transferee_id;
  g_mgrh_asg_id(g_mgrh_row_count)     := p_trn_assignment_id;
  g_mgrh_wty_fk(g_mgrh_row_count)     := p_trn_wrktyp_fk;
  g_mgrh_date(g_mgrh_row_count)       := p_transfer_date;
  g_mgrh_in_ind(g_mgrh_row_count)     := p_transfer_in_ind;
  g_mgrh_out_ind(g_mgrh_row_count)    := p_transfer_out_ind;
  g_mgrh_dir_ind(g_mgrh_row_count)    := p_direct_ind;
  g_mgrh_dir_rec(g_mgrh_row_count)    := p_direct_rec;

END insert_mgrh_transfer_row;


-- ----------------------------------------------------------------------------
-- Inserts row into global pl/sql table
-- ----------------------------------------------------------------------------
PROCEDURE insert_orgh_transfer_row(p_sup_organization_id  IN NUMBER
                                  ,p_trn_person_id        IN NUMBER
                                  ,p_trn_assignment_id    IN NUMBER
                                  ,p_trn_wrktyp_fk        IN VARCHAR2
                                  ,p_transfer_date        IN DATE
                                  ,p_transfer_in_ind      IN NUMBER
                                  ,p_transfer_out_ind     IN NUMBER
                                  ,p_direct_ind           IN NUMBER
                                  ,p_hdc_trn              IN NUMBER
                                  ,p_fte_trn              IN NUMBER) IS

BEGIN

  -- Add row
  g_orgh_row_count := g_orgh_row_count + 1;
  g_orgh_sup_org_id(g_orgh_row_count) := p_sup_organization_id;
  g_orgh_psn_id(g_orgh_row_count)     := p_trn_person_id;
  g_orgh_asg_id(g_orgh_row_count)     := p_trn_assignment_id;
  g_orgh_wty_fk(g_orgh_row_count)     := p_trn_wrktyp_fk;
  g_orgh_date(g_orgh_row_count)       := p_transfer_date;
  g_orgh_in_ind(g_orgh_row_count)     := p_transfer_in_ind;
  g_orgh_out_ind(g_orgh_row_count)    := p_transfer_out_ind;
  g_orgh_dir_ind(g_orgh_row_count)    := p_direct_ind;
  g_orgh_hdc_trn(g_orgh_row_count)    := p_hdc_trn;
  g_orgh_fte_trn(g_orgh_row_count)    := p_fte_trn;

END insert_orgh_transfer_row;


-- ----------------------------------------------------------------------------
-- Processes supervisor change event to determine manager hierarchy transfers
-- ----------------------------------------------------------------------------
PROCEDURE process_mgrh_transfer(p_manager_from_id   IN NUMBER,
                                p_manager_to_id     IN NUMBER,
                                p_transfer_psn_id   IN NUMBER,
                                p_transfer_asg_id   IN NUMBER,
                                p_transfer_wty_fk   IN VARCHAR2,
                                p_transfer_date     IN DATE,
                                p_transfer_hdc      IN NUMBER,
                                p_transfer_fte      IN NUMBER) IS

  CURSOR chain_csr(v_person_id  IN NUMBER,
                   v_date       IN DATE) IS
  SELECT
   suph.sup_person_id
  ,chn.mgrs_mngrsc_pk
  FROM
   hri_cs_suph       suph
  ,hri_cs_mngrsc_ct  chn
  WHERE suph.sub_person_id = v_person_id
  AND suph.sub_person_id = chn.mgrs_person_fk
  AND v_date BETWEEN suph.effective_start_date
             AND suph.effective_end_date
  AND v_date BETWEEN chn.mgrs_date_start
             AND chn.mgrs_date_end;

  l_chain_cache        g_chain_cache_type;
  l_index              NUMBER;
  l_transfer_in_ind    NUMBER;
  l_transfer_out_ind   NUMBER;
  l_node_sk            NUMBER;
  l_direct_ind         NUMBER;

BEGIN

  -- Populate cache with chain nodes before transfer
  FOR mgr_from_rec IN chain_csr(p_manager_from_id, p_transfer_date - 1) LOOP
    l_chain_cache(mgr_from_rec.sup_person_id).node_from_exists := TRUE;
    l_chain_cache(mgr_from_rec.sup_person_id).node_from_sk := mgr_from_rec.mgrs_mngrsc_pk;
    IF mgr_from_rec.sup_person_id = p_manager_from_id THEN
      l_chain_cache(mgr_from_rec.sup_person_id).direct_node_before := 1;
    ELSE
      l_chain_cache(mgr_from_rec.sup_person_id).direct_node_before := 0;
    END IF;
  END LOOP;

  -- Populate cache with chain nodes after transfer
  FOR mgr_to_rec IN chain_csr(p_manager_to_id, p_transfer_date) LOOP

    l_chain_cache(mgr_to_rec.sup_person_id).node_to_exists := TRUE;
    l_chain_cache(mgr_to_rec.sup_person_id).node_to_sk := mgr_to_rec.mgrs_mngrsc_pk;
    IF mgr_to_rec.sup_person_id = p_manager_to_id THEN
      l_chain_cache(mgr_to_rec.sup_person_id).direct_node_after := 1;
    ELSE
      l_chain_cache(mgr_to_rec.sup_person_id).direct_node_after := 0;
    END IF;
  END LOOP;

  BEGIN
    l_index := l_chain_cache.FIRST;
  EXCEPTION WHEN OTHERS THEN
    l_index := to_number(null);
  END;

  WHILE l_index IS NOT NULL LOOP

    -- If node exists before and after transfer it is a transfer within
    -- the hierarchy, so do not do anything
    IF (l_chain_cache(l_index).node_from_exists AND
        l_chain_cache(l_index).node_to_exists) THEN
      null;

    ELSE

      -- If node exists before (but not after) then it is a transfer out
      IF (l_chain_cache(l_index).node_from_exists) THEN

        l_transfer_in_ind  := 0;
        l_transfer_out_ind := 1;
        l_node_sk          := l_chain_cache(l_index).node_from_sk;
        l_direct_ind       := l_chain_cache(l_index).direct_node_before;

      -- If node exists after (but not before) then it is a transfer in
      ELSE

        l_transfer_in_ind  := 1;
        l_transfer_out_ind := 0;
        l_node_sk          := l_chain_cache(l_index).node_to_sk;
        l_direct_ind       := l_chain_cache(l_index).direct_node_after;

      END IF;

      -- Insert records for transfer person
      insert_mgrh_transfer_row
       (p_sup_person_id     => l_index
       ,p_sup_mngrsc_fk     => l_node_sk
       ,p_trn_person_id     => p_transfer_psn_id
       ,p_transferee_id     => p_transfer_psn_id
       ,p_trn_assignment_id => p_transfer_asg_id
       ,p_trn_wrktyp_fk     => p_transfer_wty_fk
       ,p_transfer_date     => p_transfer_date
       ,p_transfer_in_ind   => l_transfer_in_ind
       ,p_transfer_out_ind  => l_transfer_out_ind
       ,p_direct_ind        => l_direct_ind
       ,p_direct_rec        => 0);

    END IF;

    -- Filter out direct record transfers within
    IF (l_chain_cache(l_index).direct_node_before = 1 AND
        l_chain_cache(l_index).direct_node_after = 1) THEN

      null;

    ELSE

      -- If node is a direct manager before but not after it is a direct record transfer out
      IF (l_chain_cache(l_index).direct_node_before = 1) THEN

        insert_mgrh_transfer_row
         (p_sup_person_id     => l_index
         ,p_sup_mngrsc_fk     => l_node_sk
         ,p_trn_person_id     => p_transfer_psn_id
         ,p_transferee_id     => p_transfer_psn_id
         ,p_trn_assignment_id => p_transfer_asg_id
         ,p_trn_wrktyp_fk     => p_transfer_wty_fk
         ,p_transfer_date     => p_transfer_date
         ,p_transfer_in_ind   => 0
         ,p_transfer_out_ind  => 1
         ,p_direct_ind        => 1
         ,p_direct_rec        => 1);

      -- If node is a direct manager after but not before it is a direct record transfer in
      ELSIF (l_chain_cache(l_index).direct_node_after = 1) THEN

        insert_mgrh_transfer_row
         (p_sup_person_id     => l_index
         ,p_sup_mngrsc_fk     => l_node_sk
         ,p_trn_person_id     => p_transfer_psn_id
         ,p_transferee_id     => p_transfer_psn_id
         ,p_trn_assignment_id => p_transfer_asg_id
         ,p_trn_wrktyp_fk     => p_transfer_wty_fk
         ,p_transfer_date     => p_transfer_date
         ,p_transfer_in_ind   => 1
         ,p_transfer_out_ind  => 0
         ,p_direct_ind        => 1
         ,p_direct_rec        => 1);

      END IF;

    END IF;

    l_index := l_chain_cache.NEXT(l_index);

  END LOOP;

END process_mgrh_transfer;


-- ----------------------------------------------------------------------------
-- Processes organization change event to determine org hierarchy transfers
-- ----------------------------------------------------------------------------
PROCEDURE process_orgh_transfer(p_organization_from_id  IN NUMBER,
                                p_organization_to_id    IN NUMBER,
                                p_transfer_psn_id       IN NUMBER,
                                p_transfer_asg_id       IN NUMBER,
                                p_transfer_wty_fk       IN VARCHAR2,
                                p_transfer_date         IN DATE,
                                p_transfer_hdc          IN NUMBER,
                                p_transfer_fte          IN NUMBER) IS

  CURSOR chain_csr(v_organization_id  IN NUMBER) IS
  SELECT
   orgh_sup_organztn_fk
  ,orgh_relative_level
  FROM hri_cs_orgh_ct
  WHERE orgh_organztn_fk = v_organization_id;

  l_chain_cache    g_chain_cache_type;
  l_index          NUMBER;

BEGIN

  -- Populate cache with chain nodes before transfer
  FOR org_from_rec IN chain_csr(p_organization_from_id) LOOP
    l_chain_cache(org_from_rec.orgh_sup_organztn_fk).node_from_exists := TRUE;
    IF org_from_rec.orgh_relative_level = 1 THEN
      l_chain_cache(org_from_rec.orgh_sup_organztn_fk).direct_node_before := 1;
    ELSE
      l_chain_cache(org_from_rec.orgh_sup_organztn_fk).direct_node_before := 0;
    END IF;
  END LOOP;

  -- Populate cache with chain nodes after transfer
  FOR org_to_rec IN chain_csr(p_organization_to_id) LOOP
    l_chain_cache(org_to_rec.orgh_sup_organztn_fk).node_to_exists := TRUE;
    IF org_to_rec.orgh_relative_level = 1 THEN
      l_chain_cache(org_to_rec.orgh_sup_organztn_fk).direct_node_after := 1;
    ELSE
      l_chain_cache(org_to_rec.orgh_sup_organztn_fk).direct_node_after := 0;
    END IF;
  END LOOP;

  l_index := l_chain_cache.FIRST;

  WHILE l_index IS NOT NULL LOOP

    -- If node exists before and after transfer it is a transfer within
    -- the hierarchy, so do not do anything
    IF (l_chain_cache(l_index).node_from_exists AND
        l_chain_cache(l_index).node_to_exists) THEN
      null;

    -- If node exists before (but not after) then it is a transfer out
    ELSIF (l_chain_cache(l_index).node_from_exists) THEN

      insert_orgh_transfer_row
       (p_sup_organization_id => l_index
       ,p_trn_person_id       => p_transfer_psn_id
       ,p_trn_assignment_id   => p_transfer_asg_id
       ,p_trn_wrktyp_fk       => p_transfer_wty_fk
       ,p_transfer_date       => p_transfer_date
       ,p_transfer_in_ind     => 0
       ,p_transfer_out_ind    => 1
       ,p_direct_ind          => l_chain_cache(l_index).direct_node_before
       ,p_hdc_trn             => p_transfer_hdc
       ,p_fte_trn             => p_transfer_fte);

    -- If node exists after (but not before) then it is a transfer in
    ELSE

      insert_orgh_transfer_row
       (p_sup_organization_id => l_index
       ,p_trn_person_id       => p_transfer_psn_id
       ,p_trn_assignment_id   => p_transfer_asg_id
       ,p_trn_wrktyp_fk       => p_transfer_wty_fk
       ,p_transfer_date       => p_transfer_date
       ,p_transfer_in_ind     => 1
       ,p_transfer_out_ind    => 0
       ,p_direct_ind          => l_chain_cache(l_index).direct_node_after
       ,p_hdc_trn             => p_transfer_hdc
       ,p_fte_trn             => p_transfer_fte);

    END IF;

    l_index := l_chain_cache.NEXT(l_index);

  END LOOP;

EXCEPTION WHEN OTHERS THEN

  null;

END process_orgh_transfer;

END hri_opl_wrkfc_trnsfr_events;

/
