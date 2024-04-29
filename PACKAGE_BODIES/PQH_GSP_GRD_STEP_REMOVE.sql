--------------------------------------------------------
--  DDL for Package Body PQH_GSP_GRD_STEP_REMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_GRD_STEP_REMOVE" As
/* $Header: pqgspsde.pkb 120.2.12010000.2 2009/04/10 12:06:11 lbodired ship $ */
--
--------------------------- get_ovn -----------------------------
--
   g_package   VARCHAR2 (30) := 'Pqh_Gsp_Grd_Step_Remove.';

   FUNCTION get_ovn (p_copy_entity_result_id IN NUMBER)
      RETURN NUMBER
   IS
      l_ovn    NUMBER;

      CURSOR csr_ovn IS
         SELECT object_version_number
           FROM ben_copy_entity_results
          WHERE copy_entity_result_id = p_copy_entity_result_id;
   BEGIN
      hr_utility.set_location ('Entering get_ovn', 10);
      OPEN csr_ovn;
      FETCH csr_ovn INTO l_ovn;
      CLOSE csr_ovn;
      hr_utility.set_location ('Leaving get_ovn'||l_ovn, 100);
      RETURN l_ovn;
   END get_ovn;
   --
   --------------------------- get_dml_operation -----------------------------
   --

   FUNCTION get_dml_operation (p_copy_entity_result_id IN NUMBER)
      RETURN VARCHAR
   IS
      l_dml_operation   VARCHAR2 (40);

      CURSOR csr_dml_operation IS
         SELECT dml_operation
           FROM ben_copy_entity_results
          WHERE copy_entity_result_id = p_copy_entity_result_id;
   BEGIN
      hr_utility.set_location ('Entering get_dml_operation', 10);
      OPEN csr_dml_operation;
      FETCH csr_dml_operation INTO l_dml_operation;
      CLOSE csr_dml_operation;
      hr_utility.set_location ('Leaving get_dml_operation '||l_dml_operation, 100);
      RETURN l_dml_operation;
   END get_dml_operation;

--
--------------------------- delete_rec -----------------------------
--

   PROCEDURE delete_rec (
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE,
      p_object_version_number   in   NUMBER default null
   )
   IS
      l_ovn    NUMBER;
   BEGIN
      hr_utility.set_location ('Entering  delete_rec', 10);
      if p_object_version_number is null then
         l_ovn := get_ovn (p_copy_entity_result_id => p_copy_entity_result_id);
      else
         l_ovn := p_object_version_number;
      end if;
      ben_copy_entity_results_api.delete_copy_entity_results (
         p_copy_entity_result_id      => p_copy_entity_result_id,
         p_effective_date             => p_effective_date,
         p_object_version_number      => l_ovn
      );
      hr_utility.set_location ('Purged the record Sucessfully...   :', 90);
      hr_utility.set_location ('Leaving delete_rec', 100);
   EXCEPTION
      WHEN OTHERS THEN
         hr_utility.set_location ('Errors in delete_rec ...', 100);
         raise;
   END delete_rec;

--
--------------------------- update_rec -----------------------------
--

   PROCEDURE update_rec (
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE
   )
   IS
      l_ovn    NUMBER;
   BEGIN
      hr_utility.set_location ('Entering update_rec', 10);
      l_ovn := get_ovn (p_copy_entity_result_id => p_copy_entity_result_id);
      ben_copy_entity_results_api.update_copy_entity_results (
         p_copy_entity_result_id      => p_copy_entity_result_id,
         p_effective_date             => p_effective_date,
         p_information104             => 'UNLINK',
         p_object_version_number      => l_ovn,
         p_information323             => NULL
      );
      hr_utility.set_location ('Marked for Deletion Sucessfully...   :', 90);
      hr_utility.set_location ('Leaving update_rec', 100);
   EXCEPTION
      WHEN OTHERS THEN
         hr_utility.set_location ('Errors in update_rec ...', 150);
   END update_rec;
   --
   --------------------------- purge_pay_scale-----------------------------
   --

   PROCEDURE purge_pay_scale (
      p_opt_result_id        IN   NUMBER,
      p_effective_date       IN   DATE,
      p_copy_entity_txn_id   IN   NUMBER
   )
   IS
      l_scale_cer_id   NUMBER;
      l_cet_id         NUMBER;
      l_count          NUMBER;

      CURSOR csr_scale_cer_id IS
         SELECT opt.copy_entity_txn_id, opt.information256 -- Pay Scale Cer Id
           FROM ben_copy_entity_results opt
          WHERE opt.copy_entity_result_id = p_opt_result_id
            AND opt.table_alias = 'OPT'
            AND NVL (opt.information104, 'PPP') <> 'UNLINK'
	    AND opt.copy_entity_txn_id = p_copy_entity_txn_id;

      -- Count the Number of Options attached to Pay Scale
      CURSOR csr_num_opts (l_scale_cer_id NUMBER) IS
         SELECT COUNT (opt.copy_entity_result_id)
           FROM ben_copy_entity_results opt
          WHERE opt.information256 = l_scale_cer_id
          AND opt.copy_entity_txn_id  = l_cet_id
          AND opt.table_alias = 'OPT';

      --And    Nvl(opt.Information104,'PPP') <> 'UNLINK';

      CURSOR csr_plip_cer_id (p_scale_cer_id IN NUMBER) IS
         SELECT copy_entity_result_id
           FROM ben_copy_entity_results
          WHERE information258 = p_scale_cer_id
          AND copy_entity_txn_id  = l_cet_id;
   BEGIN
      hr_utility.set_location ('Entering purge_pay_scale', 10);
      -- Get Pay Scale CER Id;
      OPEN csr_scale_cer_id;
      FETCH csr_scale_cer_id INTO l_cet_id,l_scale_cer_id;
      CLOSE csr_scale_cer_id;
      hr_utility.set_location ('Pay Scale CER ID ' || l_scale_cer_id, 10);
      hr_utility.set_location ('cet ID ' || l_cet_id, 10);
      IF (l_scale_cer_id IS NOT NULL and l_cet_id is not null) THEN
         OPEN csr_num_opts (l_scale_cer_id);
         FETCH csr_num_opts INTO l_count;
         CLOSE csr_num_opts;
         IF (l_count = 1) THEN
            delete_rec ( p_copy_entity_result_id      => l_scale_cer_id,
                         p_effective_date             => p_effective_date);
            FOR rec_plip_cer_id IN csr_plip_cer_id (l_scale_cer_id) LOOP
               hr_utility.set_location ( 'Plip Cer Id ' || rec_plip_cer_id.copy_entity_result_id, 10);
               UPDATE ben_copy_entity_results
                  SET information98 = NULL,
                      information255 = NULL,
                      information258 = NULL,
                      information259 = NULL,
                      information262 = NULL
                WHERE copy_entity_result_id = rec_plip_cer_id.copy_entity_result_id;
               hr_utility.set_location ('Plip updated successfully', 40);
            END LOOP;
         END IF;
      else
         hr_utility.set_location ('null data found ', 40);
      END IF;
      hr_utility.set_location ('Leaving purge_pay_scale', 100);
   EXCEPTION
      WHEN OTHERS THEN
         hr_utility.set_location ('Errors in purge_pay_scale ...', 100);
   END purge_pay_scale;
   --
   --------------------------- purge_opt_abr_hrrate_crrate -----------------------------
   --
   -- To purge
   --   Stdandard  Rates of Grade Step  i.e ABR, HRRATE
   --   Criteria  Rates of Grade Step  i.e CRRATE

   PROCEDURE purge_opt_abr_hrrate_crrate ( p_opt_result_id        IN   NUMBER,
                                           p_copy_entity_txn_id   IN   NUMBER,
                                           p_effective_date       IN   DATE) IS
      -- Get Standard Rates i.e HRRATE, ABR Attached to OPT
      CURSOR csr_std_rates IS
         SELECT stdrate.copy_entity_result_id, stdrate.object_version_number
           FROM ben_copy_entity_results stdrate
          WHERE stdrate.table_alias IN ('HRRATE', 'ABR')
            AND stdrate.information278 = p_opt_result_id
            AND stdrate.copy_entity_txn_id = p_copy_entity_txn_id;

      -- Get Criteria Rate GRRATE
      CURSOR csr_crrate IS
         SELECT crrate.copy_entity_result_id, crrate.object_version_number
           FROM ben_copy_entity_results crrate
          WHERE crrate.copy_entity_txn_id = p_copy_entity_txn_id
            AND crrate.table_alias = 'CRRATE'
            AND crrate.information169 = p_opt_result_id;
   BEGIN
      hr_utility.set_location ('Entering purge_opt_abr_hrrate_crrate', 10);
      -- purge HRRATE, ABR  Records
      FOR rec_std_rates IN csr_std_rates LOOP
         delete_rec ( p_copy_entity_result_id      => rec_std_rates.copy_entity_result_id,
                      p_effective_date             => p_effective_date,
                      p_object_version_number      => rec_std_rates.object_version_number);
      END LOOP;

      hr_utility.set_location ('Purged HRRATE, ABR Recs sucessully ', 40);

      -- purge CRRATE Records
      FOR rec_crrates IN csr_crrate LOOP
         delete_rec ( p_copy_entity_result_id      => rec_crrates.copy_entity_result_id,
                      p_effective_date             => p_effective_date,
            p_object_version_number      => rec_crrates.object_version_number
         );
      END LOOP;

      hr_utility.set_location ('Purged CRRATE Recs sucessully ', 55);
      hr_utility.set_location ('Leaving purge_opt_abr_hrrate_crrate', 100);
   EXCEPTION
      WHEN OTHERS THEN
         hr_utility.set_location ('purge_opt_abr_hrrate_crrate ', 110);
   END purge_opt_abr_hrrate_crrate;

--
--------------------------- remove_opt -----------------------------
--
-- To Remove OPT Rec
-- if opt.dml_operation = 'INSERT' then
--     1) Purge Standard Rates i.e ABR, HRRATE
--     2) Purge Crit Rates i.e CRRATE
--     3) Purge Pay Scale if the OPT is the last rec
--     4) Purge OPT Rec
-- else if opt.dml_operation in ('COPIED','UPD_INS','UPDATE')
--     1) copt.information104 = UNLINK

   PROCEDURE remove_opt (
      p_copy_entity_txn_id      IN   NUMBER,
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE
   )
   IS
      l_point_or_step   VARCHAR2 (20);
      l_dml_operation   VARCHAR2 (40);
   BEGIN
      hr_utility.set_location ('Entering remove_opt', 100);
      l_point_or_step :=
         pqh_gsp_utility.use_point_or_step (
            p_copy_entity_txn_id      => p_copy_entity_txn_id
         );
      l_dml_operation :=
         get_dml_operation (
            p_copy_entity_result_id      => p_copy_entity_result_id
         );
      hr_utility.set_location ('l_point_or_step :' || l_point_or_step, 40);
      hr_utility.set_location ('DML Operation   :' || l_dml_operation, 45);

        -- If GL Using Direct Steps
      --  if l_point_or_step= 'STEP' Then

      IF l_dml_operation = 'INSERT' THEN
         -- 1) Purge ABR,HRRATE, CRRATE
         hr_utility.set_location ( 'Calling purge_opt_abr_hrrate_crrate... :', 30);
         pqh_gsp_grd_step_remove.purge_opt_abr_hrrate_crrate (
            p_opt_result_id           => p_copy_entity_result_id,
            p_copy_entity_txn_id      => p_copy_entity_txn_id,
            p_effective_date          => p_effective_date
         );
         -- 2) Get The Number of Options attached to this Pay Scale Cer Id
         --    suppose only one then purge Pay Scale record.
         hr_utility.set_location ('Calling purge_pay_scale... :', 40);

         IF l_point_or_step = 'STEP'
         THEN
            pqh_gsp_grd_step_remove.purge_pay_scale (
               p_opt_result_id           => p_copy_entity_result_id,
               p_copy_entity_txn_id      => p_copy_entity_txn_id,
               p_effective_date          => p_effective_date
            );
         END IF; -- end of STEP
         -- 3) purge OPT Rec
         hr_utility.set_location ('Purge OPT ... :', 50);
         delete_rec (
            p_copy_entity_result_id      => p_copy_entity_result_id,
            p_effective_date             => p_effective_date
         );
      ELSE -- l_dml_operation is UPDATE/UPD_INS/COPIED


         pqh_gsp_grd_step_remove.unlink_opt_abr_hrrate_crrate (
            p_opt_result_id           => p_copy_entity_result_id,
            p_copy_entity_txn_id      => p_copy_entity_txn_id,
            p_effective_date          => p_effective_date
         );
         update_rec (
            p_copy_entity_result_id      => p_copy_entity_result_id,
            p_effective_date             => p_effective_date
         );
      END IF; -- end of dml_operation
      --  end if;  -- end of STEP
      hr_utility.set_location ('Leaving remove_opt', 100);
   END remove_opt;
   --
   ---------------------------remove_elig_profile-----------------------------
   --
   -- To Remove (Purage/Mark for Deletion)Eligibility Profiles


   PROCEDURE remove_elig_profile (
      p_copy_entity_txn_id      IN   NUMBER,
      p_copy_entity_result_id   IN   NUMBER
   )
   IS
      l_ovn          NUMBER;
      l_exits        VARCHAR2 (40);
      l_elp_cer_id   NUMBER;

      CURSOR csr_elp_cer_ids IS
         SELECT elp.copy_entity_result_id
           FROM ben_copy_entity_results elp
          WHERE elp.copy_entity_txn_id = p_copy_entity_txn_id
            AND elp.gs_parent_entity_result_id = p_copy_entity_result_id
            AND elp.table_alias = 'ELP';
   BEGIN
      hr_utility.set_location ('Entering remove_elig_profile', 10);
      -- Check Eligibility Profiles Exists for OIPL Rec
      l_exits := pqh_gsp_utility.chk_profile_exists ( p_copy_entity_result_id      => p_copy_entity_result_id,
                                                      p_copy_entity_txn_id         => p_copy_entity_txn_id);

      hr_utility.set_location ( 'Eligibility Profiles Exists (Y/N) :' || l_exits, 50);
      IF (l_exits = 'Y') THEN
         FOR elp_recs IN csr_elp_cer_ids LOOP
            pqh_gsp_prgrules.delete_eligibility (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => elp_recs.copy_entity_result_id
            );
         END LOOP;
      END IF;

      hr_utility.set_location ('Removed Elig Profiles sucessfully ... ', 60);
      hr_utility.set_location ('Leaving remove_elig_profile', 100);
   EXCEPTION
      WHEN OTHERS THEN
         hr_utility.set_location ( 'Error in Removing Elig Profiles ... ', 100);
   END remove_elig_profile;
   --
   ---------------------------remove_oipl_STEP_flavour -----------------------------
   --
   -- To Remove OIPL Rec in STEP Flavour
   /*

  if use_prg_points = 'STEP'
    if oipl.dml_operation = 'INSERT'
      1) Purge Rates Std Rates : ABR,HRRATE,GSRATE Crit Rates : CRRATE,GRRATE
      2) Purge Elig Profile  call procedure remove_elig_profile
      3) purge OIPL

   else if opt.dml_operation in ('COPIED','UPD_INS','UPDATE')
      1) Mark for deletion call procedure remove_elig_profile
      2) oipl.information104 = UNLINK

  */
   PROCEDURE remove_oipl_step_flavour (
      p_copy_entity_txn_id      IN   NUMBER,
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE,
      p_remove_opt              IN   VARCHAR2 DEFAULT 'Y'
   )
   IS
      l_point_or_step   VARCHAR2 (20);
      l_dml_operation   VARCHAR2 (40);
      l_opt_result_id   NUMBER;

      CURSOR csr_opt_result_id IS
         SELECT oipl.information262
           FROM ben_copy_entity_results oipl
          WHERE oipl.copy_entity_txn_id = p_copy_entity_txn_id
            AND oipl.table_alias = 'COP'
            AND oipl.copy_entity_result_id = p_copy_entity_result_id;
   BEGIN
      hr_utility.set_location ('Entering remove_oipl_STEP_flavour', 10);
      l_point_or_step := pqh_gsp_utility.use_point_or_step ( p_copy_entity_txn_id      => p_copy_entity_txn_id);
      l_dml_operation := get_dml_operation ( p_copy_entity_result_id      => p_copy_entity_result_id);

      -- Get OPT Cer ID
      OPEN csr_opt_result_id;
      FETCH csr_opt_result_id INTO l_opt_result_id;
      CLOSE csr_opt_result_id;
      hr_utility.set_location ('l_point_or_step :' || l_point_or_step, 40);
      hr_utility.set_location ('DML Operation   :' || l_dml_operation, 45);
      hr_utility.set_location ('OPT Result Id:' || l_opt_result_id, 46);
      hr_utility.set_location ('remove_opt value:' || p_remove_opt, 46);

      IF l_point_or_step = 'STEP' THEN

         /*IF l_dml_operation = 'INSERT'  OR l_dml_operation ='COPIED' OR l_dml_operation = 'UPD_INS' THEN */
	 --bug#8392638
         -- To divert control of execution to the else part during create mode of the grade ladder.
         -- In create mode dml_operation of the points is COPIED

           IF l_dml_operation = 'INSERT'  OR l_dml_operation = 'UPD_INS' THEN
            --  1) Call Pqh_Gsp_Grd_Step_Remove.remove_opt
            IF p_remove_opt = 'Y' THEN
               hr_utility.set_location ('Calling remove_opt... :', 60);
               pqh_gsp_grd_step_remove.remove_opt (
                  p_copy_entity_txn_id         => p_copy_entity_txn_id,
                  p_copy_entity_result_id      => l_opt_result_id,
                  p_effective_date             => p_effective_date);
            ELSE
               hr_utility.set_location ('Not calling remove_opt ', 60);
            END IF;

            --  2) Purge Elig Profile  call procedure remove_elig_profile
            hr_utility.set_location ('Calling remove_elig_profile... :', 70);
            pqh_gsp_grd_step_remove.remove_elig_profile (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => p_copy_entity_result_id
            );
            --  3) purge OIPL
            hr_utility.set_location ('Purge OIPL... :', 80);
            delete_rec (
               p_copy_entity_result_id      => p_copy_entity_result_id,
               p_effective_date             => p_effective_date
            );
         ELSE -- dml_operation = COPIED/UPD_INS/UPDATE
            --  1) Mark for deletion call procedure remove_elig_profile
            pqh_gsp_grd_step_remove.remove_elig_profile (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => p_copy_entity_result_id
            );

            -- UNLINK OPT
             IF p_remove_opt = 'Y' Then
                        pqh_gsp_grd_step_remove.remove_opt (
                  p_copy_entity_txn_id         => p_copy_entity_txn_id,
                  p_copy_entity_result_id      => l_opt_result_id,
                  p_effective_date             => p_effective_date);
             end if;

            --  2) oipl.information104 = UNLINK
            update_rec (
               p_copy_entity_result_id      => p_copy_entity_result_id,
               p_effective_date             => p_effective_date
            );
         END IF; -- end of dml_operation
      END IF; -- end of STEP
      hr_utility.set_location ('Leaving remove_oipl_STEP_flavour', 100);
   END remove_oipl_step_flavour;
   --
   --------------------------- remove_oipl_POINT_flavour-----------------------------
   --
   -- To Remove OIPL Rec in POINT Flavour
   /*
  if use_prg_points = 'POINT'
     if oipl.dml_operation = 'INSERT'
        1) Purge Standard Rates and Criteria Rates
              1.a) Purge Standard Rates i.e ABR, HRRATE
              1.b) Purge Criteria Rates i.e CRRATE
        2) Purge Elig Profile  call procedure Pqh_Gsp_Grd_Step_Remove.remove_elig_profile
        3) purge OIPL
     else if opt.dml_operation in ('COPIED','UPD_INS','UPDATE')
        1) Mark for deletion call procedure Pqh_Gsp_Grd_Step_Remove.remove_elig_profile
        2) oipl.information104 = UNLINK
  */
   PROCEDURE remove_oipl_point_flavour (
      p_copy_entity_txn_id      IN   NUMBER,
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE
   )
   IS
      l_point_or_step   VARCHAR2 (20);
      l_dml_operation   VARCHAR2 (40);
      l_opt_result_id   NUMBER;

      CURSOR csr_opt_result_id IS
         SELECT oipl.information262
           FROM ben_copy_entity_results oipl
          WHERE oipl.copy_entity_txn_id = p_copy_entity_txn_id
            AND oipl.table_alias = 'COP'
            AND oipl.copy_entity_result_id = p_copy_entity_result_id;
   BEGIN
      hr_utility.set_location ('Entering remove_oipl_POINT_flavour', 10);
      l_point_or_step := pqh_gsp_utility.use_point_or_step ( p_copy_entity_txn_id      => p_copy_entity_txn_id);
      l_dml_operation := get_dml_operation ( p_copy_entity_result_id      => p_copy_entity_result_id);

      -- Get OPT Cer ID
      OPEN csr_opt_result_id;
      FETCH csr_opt_result_id INTO l_opt_result_id;
      CLOSE csr_opt_result_id;
      hr_utility.set_location ('l_point_or_step :' || l_point_or_step, 40);
      hr_utility.set_location ('DML Operation   :' || l_dml_operation, 45);
      hr_utility.set_location ('OPT Result Id:' || l_opt_result_id, 46);

      IF l_point_or_step = 'POINT' THEN

      /*   IF l_dml_operation = 'INSERT' OR l_dml_operation ='COPIED' OR l_dml_operation = 'UPD_INS' THEN */
     --bug#8392638
     -- To divert control of execution to the else part during create mode of the grade ladder.
     -- In create mode dml_operation of the points is COPIED

           IF l_dml_operation = 'INSERT' OR l_dml_operation = 'UPD_INS' THEN
            --  1) Purge Standard Rates : ABR, HRRATE and Criteria Rates : CRRATE
        /*    hr_utility.set_location ( 'Calling purge_opt_abr_hrrate_crrate ... :', 70);
            pqh_gsp_grd_step_remove.purge_opt_abr_hrrate_crrate (
               p_opt_result_id           => l_opt_result_id,
               p_copy_entity_txn_id      => p_copy_entity_txn_id,
               p_effective_date          => p_effective_date
            );
        */
            --  2) Purge Elig Profile  call procedure Pqh_Gsp_Grd_Step_Remove.remove_elig_profile
            hr_utility.set_location ( 'Calling Pqh_Gsp_Grd_Step_Remove.remove_elig_profile... :', 75);
            pqh_gsp_grd_step_remove.remove_elig_profile (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => p_copy_entity_result_id
            );
            --  3) purge OIPL
            hr_utility.set_location ('Purge OIPL ... :', 80);
            delete_rec (
               p_copy_entity_result_id      => p_copy_entity_result_id,
               p_effective_date             => p_effective_date
            );
         ELSE -- dml_operation = COPIED/UPD_INS/UPDATE
            --  1) Mark for deletion call procedure Pqh_Gsp_Grd_Step_Remove.remove_elig_profile
            pqh_gsp_grd_step_remove.remove_elig_profile (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => p_copy_entity_result_id
            );
            --  2) oipl.information104 = UNLINK
            update_rec (
               p_copy_entity_result_id      => p_copy_entity_result_id,
               p_effective_date             => p_effective_date
            );
         END IF; -- end of dml_operation
      END IF; -- end of POINT
      hr_utility.set_location ('Leaving remove_oipl_POINT_flavour', 100);
   END remove_oipl_point_flavour;
   --
   --------------------------- remove_oipl -----------------------------
   --
   -- To Remove OIPL Rec

   PROCEDURE remove_oipl (
      p_copy_entity_txn_id      IN   NUMBER,
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE,
      p_remove_opt              IN   VARCHAR2 DEFAULT 'Y'
   )
   IS
      l_which_flavour   VARCHAR2 (20);
   BEGIN
      hr_multi_message.enable_message_list;
      hr_utility.set_location ('Entering remove_oipl', 10);
      l_which_flavour := pqh_gsp_utility.use_point_or_step ( p_copy_entity_txn_id      => p_copy_entity_txn_id);
      hr_utility.set_location ('POINT/STEP :' || l_which_flavour, 30);
      IF (l_which_flavour = 'POINT') THEN
         pqh_gsp_grd_step_remove.remove_oipl_point_flavour (
            p_copy_entity_txn_id         => p_copy_entity_txn_id,
            p_copy_entity_result_id      => p_copy_entity_result_id,
            p_effective_date             => p_effective_date
         );
      END IF;
      IF (l_which_flavour = 'STEP') THEN
         pqh_gsp_grd_step_remove.remove_oipl_step_flavour (
            p_copy_entity_txn_id         => p_copy_entity_txn_id,
            p_copy_entity_result_id      => p_copy_entity_result_id,
            p_effective_date             => p_effective_date,
            p_remove_opt                 => p_remove_opt
         );
      END IF;
      hr_utility.set_location ('Leaving remove_oipl', 100);
   Exception
    when others then
      hr_utility.set_location ('Caught an Exception', 100);
      hr_multi_message.add;
   END remove_oipl;
   --
   --------------------------- remove_plip -----------------------------
   --
   -- To Remove PLIP Rec

   PROCEDURE remove_plip (
      p_copy_entity_txn_id      IN   NUMBER,
      p_copy_entity_result_id   IN   NUMBER,
      p_effective_date          IN   DATE
   )
   IS
      l_which_flavour   VARCHAR2 (20);
      l_dml_operation   VARCHAR2 (20);
      l_pln_cer_id      NUMBER;

      CURSOR csr_plan_result_id IS
         SELECT pln.copy_entity_result_id
           FROM ben_copy_entity_results pln
          WHERE pln.gs_mirror_src_entity_result_id = p_copy_entity_result_id
            AND pln.copy_entity_txn_id = p_copy_entity_txn_id
            AND pln.table_alias = 'PLN';

      CURSOR csr_oipl_ids IS
         SELECT oipl.copy_entity_result_id
           FROM ben_copy_entity_results oipl
          WHERE oipl.gs_parent_entity_result_id = p_copy_entity_result_id
            AND oipl.table_alias = 'COP'
            AND oipl.copy_entity_txn_id = p_copy_entity_txn_id;

   BEGIN
      hr_utility.set_location ('Entering remove_plip', 10);

      l_which_flavour := pqh_gsp_utility.use_point_or_step ( p_copy_entity_txn_id      => p_copy_entity_txn_id);
      l_dml_operation := get_dml_operation ( p_copy_entity_result_id      => p_copy_entity_result_id);
      hr_utility.set_location ('POINT/STEP :' || l_which_flavour, 30);
      hr_utility.set_location ('DML Operation   :' || l_dml_operation, 45);

      --  Remove  Rates, Elig Profiles attahced to OIPL
      --  Remove OIPL
      FOR rec_oipls IN csr_oipl_ids LOOP
         IF (l_which_flavour = 'POINT') THEN
            pqh_gsp_grd_step_remove.remove_oipl_point_flavour (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => rec_oipls.copy_entity_result_id,
               p_effective_date             => p_effective_date
            );
         END IF;

         IF (l_which_flavour = 'STEP') THEN
            pqh_gsp_grd_step_remove.remove_oipl_step_flavour (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => rec_oipls.copy_entity_result_id,
               p_effective_date             => p_effective_date
            );
         END IF;
      END LOOP;

      IF l_dml_operation = 'INSERT' THEN
         --  1) Purge Elig Profile  call procedure remove_elig_profile
            hr_utility.set_location ('Calling remove_elig_profile... :', 70);
            pqh_gsp_grd_step_remove.remove_elig_profile (
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_copy_entity_result_id      => p_copy_entity_result_id
            );

         -- 2) Purge PLIP Rec
            OPEN csr_plan_result_id;
            FETCH csr_plan_result_id INTO l_pln_cer_id;
            IF csr_plan_result_id%FOUND THEN
               update ben_copy_entity_results
               set gs_mirror_src_entity_result_id =  null
               where copy_entity_result_id = l_pln_cer_id;
            END IF;
            CLOSE csr_plan_result_id;

            delete_rec ( p_copy_entity_result_id      => p_copy_entity_result_id,
                         p_effective_date             => p_effective_date);

         hr_utility.set_location ('Purged PLIP Rec Sucessfully...   :', 85);
      ELSE -- dml_operation = UPDATE/COPIED/UPD_INS
         -- Mark PLIP for Deletion
         update_rec (
            p_copy_entity_result_id      => p_copy_entity_result_id,
            p_effective_date             => p_effective_date
         );
         hr_utility.set_location ('Marked for Deletion PLIP Rec Sucessfully...   :',90);
      END IF; -- DML Operation
      hr_utility.set_location ('Leaving remove_plip', 100);
   END remove_plip;
   PROCEDURE unlink_opt_abr_hrrate_crrate (
      p_opt_result_id        IN   NUMBER,
      p_copy_entity_txn_id   IN   NUMBER,
      p_effective_date       IN   DATE
   )
   IS
      l_proc   VARCHAR2 (72) := g_package || 'purge_opt_abr_hrrate_crrate ';

      -- Get Standard Rates i.e HRRATE, ABR Attached to OPT
      CURSOR csr_std_rates
      IS
         SELECT stdrate.copy_entity_result_id, stdrate.object_version_number
           FROM ben_copy_entity_results stdrate
          WHERE stdrate.table_alias IN ('HRRATE', 'ABR')
            AND stdrate.information278 = p_opt_result_id
            AND stdrate.copy_entity_txn_id = p_copy_entity_txn_id;

      -- Get Criteria Rate GRRATE
      CURSOR csr_crrate
      IS
         SELECT crrate.copy_entity_result_id, crrate.object_version_number
           FROM ben_copy_entity_results crrate
          WHERE crrate.copy_entity_txn_id = p_copy_entity_txn_id
            AND crrate.table_alias = 'CRRATE'
            AND crrate.information169 = p_opt_result_id;
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);

      -- purge HRRATE, ABR  Records
      FOR rec_std_rates IN csr_std_rates
      LOOP
         update_rec (
            p_copy_entity_result_id      => rec_std_rates.copy_entity_result_id,
            p_effective_date             => p_effective_date
         );
      END LOOP;

      hr_utility.set_location ('Purged HRRATE, ABR Recs sucessully ', 40);

      -- purge CRRATE Records
      FOR rec_crrates IN csr_crrate
      LOOP
         update_rec (
            p_copy_entity_result_id      => rec_crrates.copy_entity_result_id,
            p_effective_date             => p_effective_date
         );
      END LOOP;

      hr_utility.set_location ('Purged CRRATE Recs sucessully ', 55);
      hr_utility.set_location ('Leaving ' || l_proc, 100);
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_location ('purge_opt_abr_hrrate_crrate ', 110);
   END unlink_opt_abr_hrrate_crrate;

END pqh_gsp_grd_step_remove;

/
